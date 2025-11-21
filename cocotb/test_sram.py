
import os
import math
import random
import logging
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Edge, RisingEdge, FallingEdge, ClockCycles
from cocotb_tools.runner import get_runner

from hachure_defaults import *

TEST_MODULE = "test_sram"
FIRMWARE = '../firmware/test_sram/build/firmware.hex'

FULL_CHIP = os.getenv("SIM_FULL_CHIP", "1") == "1"

first_test = True

@cocotb.parametrize(core=["1", "2", "4", "8", "4ccx", "1bram", "8bram"])
async def test_sram(dut, core):
    global first_test
    logger = logging.getLogger(TEST_MODULE)
    logger.info("Startup sequence...")
    await start_up(dut, core, from_reset=first_test)
    first_test = False
    logger.info("Running the test...")

    await ClockCycles(dut.clk, 300000//int(math.log2(1+int(core[0]))))
    
    if not FULL_CHIP:
        assert int(dut.gpo.value) == 7
    else:
        assert int(dut.gpio.value) == 7
    
if __name__ == "__main__":
    sim_setup(TEST_MODULE, FIRMWARE)