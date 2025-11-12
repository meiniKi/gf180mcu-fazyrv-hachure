# SPDX-FileCopyrightText: © 2025 Project Template Contributors
# SPDX-License-Identifier: Apache-2.0

import os
import random
import logging
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, Edge, RisingEdge, FallingEdge, ClockCycles
from cocotb_tools.runner import get_runner

sim = os.getenv("SIM", "icarus")
pdk_root = os.getenv("PDK_ROOT", Path("~/.ciel").expanduser())
pdk = os.getenv("PDK", "gf180mcuD")
scl = os.getenv("SCL", "gf180mcu_fd_sc_mcu7t5v0")
gl = os.getenv("GL", False)

hdl_toplevel = "globefish_tb"

simple_test = { 'firmware': '../firmware/simple/build/simple.hex' }

enabled = simple_test

async def set_defaults(dut):
    #dut.input_PAD.value = 0
    pass

async def enable_power(dut):
    dut.VDD.value = 1
    dut.VSS.value = 0

async def start_clock(clock, freq=50):
    """Start the clock @ freq MHz"""
    c = Clock(clock, 1 / freq * 1000, "ns")
    cocotb.start_soon(c.start())


async def reset(reset, active_low=True, time_ns=1000):
    """Reset dut"""
    cocotb.log.info("Reset asserted...")

    reset.value = not active_low
    await Timer(time_ns, "ns")
    reset.value = active_low

    cocotb.log.info("Reset deasserted.")


async def start_up(dut):
    """Startup sequence"""
    await set_defaults(dut)
    if gl:
        await enable_power(dut)
    await start_clock(dut.clk)
    await reset(dut.rst_n)


@cocotb.test(skip=enabled!=simple_test)
async def test_simple(dut):
    """Run the simple test"""
    logger = logging.getLogger("test_simple")
    logger.info("Startup sequence...")
    await start_up(dut)
    logger.info("Running the test...")

    # Wait for some time...
    await ClockCycles(dut.clk, int(10000))

    logger.info("Check Traces!")


def chip_top_runner():

    proj_path = Path(__file__).resolve().parent

    sources = []
    defines = {}
    includes = [
        proj_path / "../ip/rggen-verilog-rtl"
    ]

    if gl:
        # SCL models
        sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / f"{scl}.v")
        sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / "primitives.v")

        # We use the powered netlist
        sources.append(proj_path / f"../final/pnl/{hdl_toplevel}.pnl.v")

        defines = {"FUNCTIONAL": True, "USE_POWER_PINS": True}
    else:
        #sources.append(proj_path / "../src/chip_top.sv")
        #sources.append(proj_path / "../src/chip_core.sv")
        sources.append(proj_path / "../macros/frv_1/frv_1_nl.sv")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_mux.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_bit_field.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_default_register.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_adapter_common.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_register_common.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_wishbone_adapter.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_address_decoder.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_or_reducer.v")
        sources.append(proj_path / "../src/gen/CSR.v")
        sources.append(proj_path / "../ip/verilog-arbiter/src/arbiter.v")
        sources.append(proj_path / "../ip/wb_intercon/rtl/verilog/wb_cdc.v")
        sources.append(proj_path / "../ip/wb_intercon/rtl/verilog/wb_arbiter.v")
        sources.append(proj_path / "../ip/wb_intercon/rtl/verilog/wb_data_resize.v")
        sources.append(proj_path / "../ip/wb_intercon/rtl/verilog/wb_mux.v")        
        sources.append(proj_path / "../src/gen/wb_intercon.v")
        sources.append(proj_path / "../src/ram512x8.sv")
        sources.append(proj_path / "../src/ram512x32.sv")
        sources.append(proj_path / "../src/wb_ram.sv")
        sources.append(proj_path / "../src/wb_spi.sv")
        sources.append(proj_path / "../src/wb_qspi_mem.sv")
        sources.append(proj_path / "../src/tiny_wb_dma_oled_spi.sv")
        sources.append(proj_path / "../src/globefish_soc.sv")

    sources += [
        # IO pad models
        Path(pdk_root) / pdk / "libs.ref/gf180mcu_fd_io/verilog/gf180mcu_fd_io.v",
        Path(pdk_root) / pdk / "libs.ref/gf180mcu_fd_io/verilog/gf180mcu_ws_io.v",
        
        # SRAM macros
        Path(pdk_root) / pdk / "libs.ref/gf180mcu_fd_ip_sram/verilog/gf180mcu_fd_ip_sram__sram512x8m8wm1.v",
        
        # Custom IP
        proj_path / "../ip/gf180mcu_ws_ip__id/vh/gf180mcu_ws_ip__id.v",
        proj_path / "../ip/gf180mcu_ws_ip__logo/vh/gf180mcu_ws_ip__logo.v",
        
        # UART IP
        proj_path / "../ip/EF_IP_UTIL/hdl/ef_util_lib.v",
        proj_path / "../ip/EF_UART/hdl/rtl/EF_UART.v",
        proj_path / "../ip/EF_UART/hdl/rtl/bus_wrappers/EF_UART_WB.v",
        
        # Testbench and helpers
        "spiflash.v",
        "qspi_psram.sv",
        "globefish_tb.sv",
    ]

    build_args = []

    if sim == "icarus":
        # For debugging
        # build_args = ["-Winfloop", "-pfileline=1"]
        pass

    if sim == "verilator":
        build_args = ["--timing", "--trace", "--trace-fst", "--trace-structs"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel=hdl_toplevel,
        defines=defines,
        always=True,
        includes=includes,
        build_args=build_args,
        waves=True,
    )

    plusargs = ['-fst', f'+firmware={enabled["firmware"]}']

    runner.test(
        hdl_toplevel=hdl_toplevel,
        test_module="globefish_tb,",
        plusargs=plusargs,
        waves=True,
    )


if __name__ == "__main__":
    chip_top_runner()
