
import os
import math
import random
import logging
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Edge, RisingEdge, FallingEdge, ClockCycles, ReadOnly
from collections import deque
from cocotb.triggers import Edge
from cocotb.triggers import First
from cocotb.queue import Queue

from hachure_defaults import *

TEST_MODULE = "test_spi"
FIRMWARE = '../firmware/test_spi/build/firmware.hex'

FULL_CHIP = os.getenv("SIM_FULL_CHIP", "1") == "1"

first_test = True

from cocotb.queue import Queue


class SpiDevice:
    """
    Minimal SPI slave device:
      * CPOL=0, CPHA=0 (sample MOSI on rising SCLK)
      * Loopback = drive same bits on MISO
      * Collect bits MSB-first
      * On rising edge of CS -> end of frame -> assertion/logging
    """

    def __init__(self, dut):
        self.dut = dut
        self.bit_buffer = []
        self.frame_done = Queue()

    async def run(self):
        """Main coroutine to handle SPI traffic."""
        dut = self.dut
     
        cocotb.start_soon(self._monitor_cs())
        cocotb.start_soon(self._monitor_sclk())
        cocotb.start_soon(self._loopback())
        
    async def _loopback(self):
        dut = self.dut
        while True:
            await First(Edge(dut.spi_sck), Edge(dut.spi_cs))
            await RisingEdge(dut.clk)
            await RisingEdge(dut.clk)
            dut.spi_sdi.value = dut.spi_sdo.value
    
    
    async def _monitor_sclk(self):
        dut = self.dut
        while True:
            await RisingEdge(dut.spi_sck)
            
            if dut.spi_cs.value == 0:  # active low
                bit = int(dut.spi_sdo.value)
                self.bit_buffer.append(bit)


    async def _monitor_cs(self):
        dut = self.dut

        while True:
            await RisingEdge(dut.spi_cs)

            if self.bit_buffer:
                # Convert list of bits to integer (MSB-first)
                value = 0
                for b in self.bit_buffer:
                    value = (value << 1) | b

                dut._log.info(f"SPI frame received: {len(self.bit_buffer)} bits -> 0x{value:X}")
                await self.frame_done.put(value)

                self.bit_buffer = []


    
async def wait_until_nonzero(signal):
    while True:
        await Edge(signal)
        await ReadOnly()
        if int(signal.value) != 0:
            return int(signal.value)


@cocotb.parametrize(core=["1", "2", "4", "8", "4ccx", "1bram", "8bram"])
async def test_spi(dut, core):
    global first_test
    logger = logging.getLogger(TEST_MODULE)
    logger.info("Startup sequence...")
    await start_up(dut, core, from_reset=first_test)
    first_test = False
    spi = SpiDevice(dut)
    cocotb.start_soon(spi.run())
    
    logger.info("Running the test...")
    
    received_value = await spi.frame_done.get()

    assert received_value == 0x1D
    
    await ClockCycles(dut.clk, 10000//int(math.log2(1+int(core[0]))))

    #if FULL_CHIP:
    #    val = await wait_until_nonzero(dut.gpio)
    #else:
    #    val = await wait_until_nonzero(dut.gpo)
    #
    #assert val == 1

        
if __name__ == "__main__":
    sim_setup(TEST_MODULE, FIRMWARE)