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

async def set_defaults(dut, core):
    assert core in [1,2,4,8]
    dut.en_p.value = 1
    dut.en_wb.value = 1

    dut.en_frv1.value = 0
    dut.en_frv2.value = 0
    dut.en_frv4.value = 0
    dut.en_frv8.value = 0
    
    if core == 1:
        dut.en_frv1.value = 1
    if core == 2:
        dut.en_frv2.value = 1
    if core == 4:
        dut.en_frv4.value = 1
    if core == 8:
        dut.en_frv8.value = 1

async def enable_power(dut):
    dut.VDD.value = 1
    dut.VSS.value = 0

async def start_clock(clock, freq=100):
    """Start the clock @ freq MHz"""
    c = Clock(clock, 1 / freq * 1000, "ns")
    cocotb.start_soon(c.start())


async def reset(reset, active_low=True, time_ns=1005):
    """Reset dut"""
    cocotb.log.info("Reset asserted...")

    reset.value = not active_low
    await Timer(time_ns, "ns")
    reset.value = active_low

    cocotb.log.info("Reset deasserted.")


async def start_up(dut, core, from_reset=False):
    """Startup sequence"""
    await set_defaults(dut, core)
    if gl:
        await enable_power(dut)
    await start_clock(dut.clk)
    if from_reset:
        await reset(dut.rst_n)



def sim_setup(test_module, firmware):

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
        if True:
            sources.append(proj_path / "../macros/frv_1/frv_1_nl.sv")
            sources.append(proj_path / "../macros/frv_2/frv_2_nl.sv")
            sources.append(proj_path / "../macros/frv_4/frv_4_nl.sv")
            sources.append(proj_path / "../macros/frv_8/frv_8_nl.sv")
        else:
            sources.append(proj_path / "../macros/frv_1/frv_1.sv")
            sources.append(proj_path / "../macros/frv_2/frv_2.sv")
            sources.append(proj_path / "../macros/frv_4/frv_4.sv")
            sources.append(proj_path / "../macros/frv_8/frv_8.sv")
            
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_hadd.v")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_fadd.v")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_cmp.v")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_decode.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_decode_mem1.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_alu.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_cntrl.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_spm_a.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_spm_d.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_pc.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_shftreg.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_ram_sp.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_ram_dp.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_rf_lut.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_rf.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_csr.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_core.sv")
            sources.append(proj_path / "../ip/FazyRV/rtl/fazyrv_top.sv")

            
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

    plusargs = ['-fst', '+firmware={}'.format(os.path.abspath(firmware))]

    runner.test(
        hdl_toplevel=hdl_toplevel,
        test_module=test_module,
        plusargs=plusargs,
        waves=True,
    )
