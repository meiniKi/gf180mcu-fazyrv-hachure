
import os
import math
import random
import logging
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Edge, RisingEdge, FallingEdge, ClockCycles

from hachure_defaults import *

TEST_MODULE = "test_toggle"
FIRMWARE = '../firmware/test_toggle/build/firmware.hex'

FULL_CHIP = os.getenv("SIM_FULL_CHIP", "1") == "1"

first_test = True

@cocotb.parametrize(core=["1", "2", "4", "8", "4ccx", "1bram", "8bram"])
async def test_toggle(dut, core):
    global first_test
    logger = logging.getLogger(TEST_MODULE)
    logger.info("Startup sequence...")
    await start_up(dut, core, from_reset=first_test)
    first_test = False
    logger.info("Running the test...")
    
    if FULL_CHIP and first_test:
        gpio_val = str(dut.gpio.value)
        assert all(bit == 'Z' for bit in gpio_val)

    toggle_count = 0
    async def mon():
        nonlocal toggle_count
        
        if FULL_CHIP:
            val = dut.gpio.value[0]
            if "Z" in str(val):
                prev_val = 0
            else:
                prev_val = int(val)
        else:
            prev_val = int(dut.gpo.value[0])
        
        while True:
            await RisingEdge(dut.clk)
            if FULL_CHIP:
                val = dut.gpio.value[0]
                if "Z" in str(val):
                    curr_val = 0
                else:
                    curr_val = int(val)
            else:
                curr_val = int(dut.gpo.value[0])
            if curr_val != prev_val:
                toggle_count += 1
            prev_val = curr_val
    
    monitor_task = cocotb.start_soon(mon())
    await ClockCycles(dut.clk, 15000//int(math.log2(1+int(core[0]))))
    monitor_task.cancel()

    logger.info("[RESULT] GPO[0] toggled {} times.".format(toggle_count))
    assert toggle_count > 10
    
if __name__ == "__main__":
    sim_setup(TEST_MODULE, FIRMWARE)