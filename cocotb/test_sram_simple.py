
import os
import math
import random
import logging
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Edge, RisingEdge, FallingEdge, ClockCycles
from cocotb_tools.runner import get_runner

from globefish_defaults import *

TEST_MODULE = "test_sram_simple"
FIRMWARE = '../firmware/test_sram_simple/build/firmware.hex'

first_test = True

@cocotb.parametrize(core=[1,2,4,8])
async def test_sram_simple(dut, core):
    global first_test
    logger = logging.getLogger(TEST_MODULE)
    logger.info("Startup sequence...")
    await start_up(dut, core, from_reset=first_test)
    first_test = False
    logger.info("Running the test...")

    await ClockCycles(dut.clk, 30000//int(math.log2(1+core)))
    
    assert int(dut.gpo.value) == 5
    
if __name__ == "__main__":
    sim_setup(TEST_MODULE, FIRMWARE)