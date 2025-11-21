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

FULL_CHIP = os.getenv("SIM_FULL_CHIP", "1") == "1"
hdl_toplevel = "chip_top_tb" if FULL_CHIP is True else "hachure_tb"

async def set_defaults(dut, core):
    assert core in ["1", "2", "4", "8", "4ccx", "1bram", "8bram"]
    dut.en_p.value = 1
    dut.en_p2.value = 1
    dut.en_wb.value = 1

    dut.en_frv1.value = 0
    dut.en_frv2.value = 0
    dut.en_frv4.value = 0
    dut.en_frv8.value = 0
    dut.en_frv4ccx.value = 0
    dut.ccx4_res.value = 0
       
    if core == "1":
        dut.en_frv1.value = 1
    elif core == "2":
        dut.en_frv2.value = 1
    elif core == "4":
        dut.en_frv4.value = 1
    elif core == "8":
        dut.en_frv8.value = 1
    elif core == "4ccx":
        dut.en_frv4ccx.value = 1
    elif core == "1bram":
        # if en_frv4ccx == 0 -> ccx4_res[0] is en_1bram
        dut.ccx4_res.value = 1
    elif core == "8bram":
        # if en_frv4ccx == 0 -> ccx4_res[1] is en_8bram
        dut.ccx4_res.value = 2
    else:
        raise NotImplementedError("Unknown")

async def enable_power(dut):
    dut.VDD.value = 1
    dut.VSS.value = 0

async def start_clock(clock, freq=100):
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

    # SCL models
    sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / "primitives.v")
    sources.append(Path(pdk_root) / pdk / "libs.ref" / scl / "verilog" / f"{scl}.v")
    
    if gl:
        # We use the powered netlist
        sources.append(proj_path / f"../final/pnl/chip_top.pnl.v")
        
        # Use powered macros
        sources.append(proj_path / "../macros/frv_1/final/pnl/frv_1.pnl.v")
        sources.append(proj_path / "../macros/frv_2/final/pnl/frv_2.pnl.v")
        sources.append(proj_path / "../macros/frv_4/final/pnl/frv_4.pnl.v")
        sources.append(proj_path / "../macros/frv_8/final/pnl/frv_8.pnl.v")
        sources.append(proj_path / "../macros/frv_4ccx/final/pnl/frv_4ccx.pnl.v")
        sources.append(proj_path / "../macros/frv_1bram/final/pnl/frv_1bram.pnl.v")
        sources.append(proj_path / "../macros/frv_8bram/final/pnl/frv_8bram.pnl.v")

        defines = {"FUNCTIONAL": True, "USE_POWER_PINS": True}
    else:
        #sources.append(proj_path / "../src/chip_top.sv")
        #sources.append(proj_path / "../src/chip_core.sv")
        if True:
            sources.append(proj_path / "../macros/frv_1/frv_1_nl.sv")
            sources.append(proj_path / "../macros/frv_2/frv_2_nl.sv")
            sources.append(proj_path / "../macros/frv_4/frv_4_nl.sv")
            sources.append(proj_path / "../macros/frv_8/frv_8_nl.sv")
            sources.append(proj_path / "../macros/frv_4ccx/frv_4ccx_nl.sv")
            sources.append(proj_path / "../macros/frv_1bram/frv_1bram_nl.sv")
            sources.append(proj_path / "../macros/frv_8bram/frv_8bram_nl.sv")
        else:
            sources.append(proj_path / "../macros/frv_1/frv_1.sv")
            sources.append(proj_path / "../macros/frv_2/frv_2.sv")
            sources.append(proj_path / "../macros/frv_4/frv_4.sv")
            sources.append(proj_path / "../macros/frv_8/frv_8.sv")
            sources.append(proj_path / "../macros/frv_1bram/frv_1bram.sv")
            sources.append(proj_path / "../macros/frv_8bram/frv_8bram.sv")
            # For frv4ccx we keep the nl to avoid issues with uniquification
            #sources.append(proj_path / "../macros/frv_8/frv_4ccx_nl.sv")
            
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

        if FULL_CHIP:
            sources += [proj_path / "../src/chip_core.sv",
                        proj_path / "../src/chip_top.sv"]
            
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_mux.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_bit_field.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_default_register.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_adapter_common.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_register_common.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_wishbone_adapter.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_address_decoder.v")
        sources.append(proj_path / "../ip/rggen-verilog-rtl/rggen_or_reducer.v")
        sources.append(proj_path / "../src/reset_sync.sv")
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
        sources.append(proj_path / "../src/hachure_soc.sv")

    sources += [
        # IO pad models
        Path(pdk_root) / pdk / "libs.ref/gf180mcu_fd_io/verilog/gf180mcu_fd_io.v",
        Path(pdk_root) / pdk / "libs.ref/gf180mcu_fd_io/verilog/gf180mcu_ws_io.v",
        
        # SRAM macros
        Path(pdk_root) / pdk / "libs.ref/gf180mcu_fd_ip_sram/verilog/gf180mcu_fd_ip_sram__sram512x8m8wm1.v",
        
        # Custom IP
        proj_path / "../ip/gf180mcu_ws_ip__id/vh/gf180mcu_ws_ip__id.v",
        proj_path / "../ip/gf180mcu_ws_ip__logo/vh/gf180mcu_ws_ip__logo.v",
        proj_path / "../ip/gf180mcu_hachure_ip__logo/vh/gf180mcu_hachure_ip__logo.v",
        
        # UART IP
        proj_path / "../ip/EF_IP_UTIL/hdl/ef_util_lib.v",
        proj_path / "../ip/EF_UART/hdl/rtl/EF_UART.v",
        proj_path / "../ip/EF_UART/hdl/rtl/bus_wrappers/EF_UART_WB.v",
        proj_path / "../ip/EF_SPI/hdl/rtl/spi_master.v",
        proj_path / "../ip/EF_SPI/hdl/rtl/EF_SPI.v",
        proj_path / "../ip/EF_SPI/hdl/rtl/bus_wrappers/EF_SPI_WB.v",
        proj_path / "../ip/ahb3lite_wb_bridge/wb_to_ahb3lite.v",
        proj_path / "../ip/MS_QSPI_XIP_CACHE/hdl/rtl/MS_QSPI_XIP_CACHE.v",
        proj_path / "../ip/MS_QSPI_XIP_CACHE/hdl/rtl/bus_wrappers/MS_QSPI_XIP_CACHE_ahbl.v",
        
        # Testbench and helpers
        "spiflash.v",
        "qspi_psram.sv",
        "chip_top_tb.sv" if FULL_CHIP is True else "hachure_tb.sv",
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
        results_xml=test_module.lower() + "_results.xml",
        plusargs=plusargs,
        waves=True,
    )
