
import os
import math
import random
import logging
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Edge, RisingEdge, FallingEdge, ClockCycles
from cocotb_tools.runner import get_runner
from cocotbext.uart import UartSource, UartSink

from hachure_defaults import *

TEST_MODULE = "test_uart"
FIRMWARE = '../firmware/test_uart/build/firmware.hex'

first_test = True

@cocotb.parametrize(core=["1", "2", "4", "8", "4ccx", "1bram", "8bram"])
async def test_uart(dut, core):
    global first_test
    logger = logging.getLogger(TEST_MODULE)
    logger.info("Startup sequence...")
    await start_up(dut, core, from_reset=first_test)
    first_test = False
    logger.info("Running the test...")
    
    uart_source = UartSource(dut.uart_rx, baud=115200, bits=8)
    uart_sink = UartSink(dut.uart_tx, baud=115200, bits=8)

    await ClockCycles(dut.clk, 50000//int(math.log2(1+int(core[0]))))
        
    await uart_source.write(b'C')
    
    await ClockCycles(dut.clk, 40000)
    
    data = await uart_sink.read(1)

    assert data == b'C'


if __name__ == "__main__":
    sim_setup(TEST_MODULE, FIRMWARE)