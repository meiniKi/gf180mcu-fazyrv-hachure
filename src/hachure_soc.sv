// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  hachure_soc.sv
// Usage :  FazyRV hachure SoC
//
// Ports
//  - clk_i               System clock
//  - rst_in              System reset (low active)
//  - en_p_i              Enable peripherals
//  - en_p2_i             Enable redundant peripherals
//  - en_wb_i             Enable Wishbone bus
//  - en_frv1_i           Enable FazyRV 1-bit
//  - en_frv2_i           Enable FazyRV 2-bit
//  - en_frv4_i           Enable FazyRV 4-bit
//  - en_frv8_i           Enable FazyRV 8-bit
//  - en_frv4ccx_i        Enable FazyRV 4-bit with CCX interface
//  - qspi_mem_cs_ram_on  Chip enable: QSPI RAM
//  - qspi_mem_cs_rom_on  Chip enable: QSPI ROM
//  - qspi_mem_sck_o      QSPI serial clock
//  - qspi_mem_sd_i       QSPI data in
//  - qspi_mem_sd_o       QSPI data out
//  - qspi_mem_oen_o      QSPI output enable
//  - ccx4_rs_a_o         CCX operand a chunk
//  - ccx4_rs_b_o         CCX operand b chunk
//  - ccx4_res_i          CCX result
//  - ccx4_sel_o          CCX select
//  - ccx4_req_o          CCX request
//  - ccx4_resp_i         CCX response
//  - uart_tx_o           UART transmit
//  - uart_rx_i           UART receive
//  - spi_oled_sck_o      OLED serial clock
//  - spi_oled_sdo_o      OLED data out
//  - gpi_i               GPIO: input
//  - gpo_o               GPIO: output
//  - gpeo_o              GPIO: output enable
//  - gpcs_o              GPIO: cmos buffer / schmidt trigger
//  - gpsl_o              GPIO: slew rate
//  - gppu_o              GPIO: pull up
//  - gppd_o              GPIO: pull down
//  - spi_cs_o            SPI chip select
//  - spi_sck_o           SPI serial clock
//  - spi_sdo_o           SPI data out
//  - spi_sdi_i           SPI data in
//  - efspi_cs_o          EF SPI chip select
//  - efspi_sck_o         EF SPI serial clock
//  - efspi_sdo_o         EF SPI data out
//  - efspi_sdi_i         EF SPI data in
//  - xip_cs_on           XIP chip select
//  - xip_sck_o           XIP serial clock
//  - xip_sd_i            XIP data in
//  - xip_sd_o            XIP data out
//  - xip_oen_o           XIP output enable
//  - csr_slew_o          Ouputs slew rate setting
//  - csr_pu_o            Inputs pull up setting
//  - csr_pd_o            Inputs pull down setting
// -----------------------------------------------------------------------------

`timescale 1ns/1ps
`default_nettype none

module hachure_soc (
  `ifdef USE_POWER_PINS
  inout  wire         VDD,
  inout  wire         VSS,
  `endif
  input  logic        clk_i,
  input  logic        rst_in,
  // Enables
  input  logic        en_p_i,
  input  logic        en_p2_i,
  input  logic        en_wb_i,
  input  logic        en_frv1_i,
  input  logic        en_frv2_i,
  input  logic        en_frv4_i,
  input  logic        en_frv8_i,
  input  logic        en_frv4ccx_i,
  // QSPI XIP Memory
  output logic        qspi_mem_cs_ram_on,
  output logic        qspi_mem_cs_rom_on,
  output logic        qspi_mem_sck_o,
  input  logic [ 3:0] qspi_mem_sd_i,
  output logic [ 3:0] qspi_mem_sd_o,
  output logic [ 3:0] qspi_mem_oen_o,
  // FazyRV CCX
  output logic [ 3:0] ccx4_rs_a_o,
  output logic [ 3:0] ccx4_rs_b_o,
  input  logic [ 3:0] ccx4_res_i,
  output logic [ 1:0] ccx4_sel_o,
  output logic        ccx4_req_o,
  input  logic        ccx4_resp_i,
  // UART
  output logic        uart_tx_o,
  input  logic        uart_rx_i,
  // OLED
  output logic        spi_oled_sck_o,
  output logic        spi_oled_sdo_o,
  // GPIO
  input  logic [ 3:0] gpi_i,
  output logic [ 3:0] gpo_o,
  output logic [ 3:0] gpeo_o,
  output logic [ 3:0] gpcs_o,
  output logic [ 3:0] gpsl_o,
  output logic [ 3:0] gppu_o,
  output logic [ 3:0] gppd_o,
  // SPI
  output logic        spi_cs_o,
  output logic        spi_sck_o,
  output logic        spi_sdo_o,
  input  logic        spi_sdi_i,
  // EF SPI
  output logic        efspi_cs_o,
  output logic        efspi_sck_o,
  output logic        efspi_sdo_o,
  input  logic        efspi_sdi_i,
  //
  output logic        xip_cs_on,
  output logic        xip_sck_o,
  input  logic [ 3:0] xip_sd_i,
  output logic [ 3:0] xip_sd_o,
  output logic [ 3:0] xip_oen_o,
  // Misc slew and pull configs
  output logic [19:0] csr_slew_o,
  output logic [ 3:0] csr_pu_o,
  output logic [ 3:0] csr_pd_o
);

                                   
// mmmmm    mm   mmmmm    mm   m    m
// #   "#   ##   #   "#   ##   ##  ##
// #mmm#"  #  #  #mmmm"  #  #  # ## #
// #       #mm#  #   "m  #mm#  # "" #
// #      #    # #    " #    # #    #
//
//####################################                                 
                                   

localparam MAX_SPI_LENGTH = 1024*64/8;
// Note: 14-bit address hard-coded in CSR bitfield

localparam SPI_PREFETCH   = 0;


// Clocks
logic clk_p;
logic clk_p2;
logic clk_wb;
logic clk_c_frv_1;
logic clk_c_frv_2;
logic clk_c_frv_4;
logic clk_c_frv_8;
logic clk_c_frv_4ccx;
logic clk_c_frv_1bram;
logic clk_c_frv_8bram;

// Resets
logic rst_p_n;
logic rst_wb_n;
logic rst_c_frv_1_n;
logic rst_c_frv_2_n;
logic rst_c_frv_4_n;
logic rst_c_frv_8_n;
logic rst_c_frv_4ccx_n;
logic rst_c_frv_1bram_n;
logic rst_c_frv_8bram_n;

// Sync clock gating such that once controller cannot block the bus
logic en_frv1_sync_r;
logic en_frv2_sync_r;
logic en_frv4_sync_r;
logic en_frv8_sync_r;
logic en_frv4ccx_sync_r;
logic en_frv1bram_sync_r;
logic en_frv8bram_sync_r;

//  m     m   "                        
//  #  #  # mmm     m mm   mmm    mmm  
//  " #"# #   #     #"  " #"  #  #   " 
//   ## ##"   #     #     #""""   """m 
//   #   #  mm#mm   #     "#mm"  "mmm" 
//
//####################################

// FazyRV 1-bit
logic        wb_c_frv_1_imem_stb;
logic        wb_c_frv_1_imem_cyc;
logic        wb_c_frv_1_imem_ack;
logic [31:0] wb_c_frv_1_imem_adr;
logic [31:0] wb_c_frv_1_imem_rdat;

logic        wb_c_frv_1_dmem_cyc;
logic        wb_c_frv_1_dmem_stb;
logic        wb_c_frv_1_dmem_we;
logic        wb_c_frv_1_dmem_ack;
logic [ 3:0] wb_c_frv_1_dmem_be;
logic [31:0] wb_c_frv_1_dmem_adr;
logic [31:0] wb_c_frv_1_dmem_rdat;
logic [31:0] wb_c_frv_1_dmem_wdat;

logic        wb_c_frv_1_cyc;
logic        wb_c_frv_1_stb;
logic        wb_c_frv_1_we;
logic        wb_c_frv_1_ack;
logic [ 3:0] wb_c_frv_1_be;
logic [31:0] wb_c_frv_1_adr;
logic [31:0] wb_c_frv_1_rdat;
logic [31:0] wb_c_frv_1_wdat;

assign wb_c_frv_1_cyc  = en_frv1_sync_r & (wb_c_frv_1_imem_cyc | wb_c_frv_1_dmem_cyc);
assign wb_c_frv_1_stb  = en_frv1_sync_r & (wb_c_frv_1_imem_stb | wb_c_frv_1_dmem_stb);
assign wb_c_frv_1_be   = wb_c_frv_1_imem_stb ? 4'b1111 : wb_c_frv_1_dmem_be;
assign wb_c_frv_1_adr  = wb_c_frv_1_imem_stb ? wb_c_frv_1_imem_adr : wb_c_frv_1_dmem_adr;
assign wb_c_frv_1_we   = wb_c_frv_1_dmem_stb & wb_c_frv_1_dmem_we;
assign wb_c_frv_1_wdat = wb_c_frv_1_dmem_wdat;

assign wb_c_frv_1_imem_ack  = wb_c_frv_1_ack & wb_c_frv_1_imem_stb;
assign wb_c_frv_1_dmem_ack  = wb_c_frv_1_ack & wb_c_frv_1_dmem_stb;
assign wb_c_frv_1_imem_rdat = wb_c_frv_1_rdat;
assign wb_c_frv_1_dmem_rdat = wb_c_frv_1_rdat;


// FazyRV 1-bit BRAM
logic        wb_c_frv_1bram_imem_stb;
logic        wb_c_frv_1bram_imem_cyc;
logic        wb_c_frv_1bram_imem_ack;
logic [31:0] wb_c_frv_1bram_imem_adr;
logic [31:0] wb_c_frv_1bram_imem_rdat;

logic        wb_c_frv_1bram_dmem_cyc;
logic        wb_c_frv_1bram_dmem_stb;
logic        wb_c_frv_1bram_dmem_we;
logic        wb_c_frv_1bram_dmem_ack;
logic [ 3:0] wb_c_frv_1bram_dmem_be;
logic [31:0] wb_c_frv_1bram_dmem_adr;
logic [31:0] wb_c_frv_1bram_dmem_rdat;
logic [31:0] wb_c_frv_1bram_dmem_wdat;

logic        wb_c_frv_1bram_cyc;
logic        wb_c_frv_1bram_stb;
logic        wb_c_frv_1bram_we;
logic        wb_c_frv_1bram_ack;
logic [ 3:0] wb_c_frv_1bram_be;
logic [31:0] wb_c_frv_1bram_adr;
logic [31:0] wb_c_frv_1bram_rdat;
logic [31:0] wb_c_frv_1bram_wdat;

assign wb_c_frv_1bram_cyc  = en_frv1bram_sync_r & (wb_c_frv_1bram_imem_cyc | wb_c_frv_1bram_dmem_cyc);
assign wb_c_frv_1bram_stb  = en_frv1bram_sync_r & (wb_c_frv_1bram_imem_stb | wb_c_frv_1bram_dmem_stb);
assign wb_c_frv_1bram_be   = wb_c_frv_1bram_imem_stb ? 4'b1111 : wb_c_frv_1bram_dmem_be;
assign wb_c_frv_1bram_adr  = wb_c_frv_1bram_imem_stb ? wb_c_frv_1bram_imem_adr : wb_c_frv_1bram_dmem_adr;
assign wb_c_frv_1bram_we   = wb_c_frv_1bram_dmem_stb & wb_c_frv_1bram_dmem_we;
assign wb_c_frv_1bram_wdat = wb_c_frv_1bram_dmem_wdat;

assign wb_c_frv_1bram_imem_ack  = wb_c_frv_1bram_ack & wb_c_frv_1bram_imem_stb;
assign wb_c_frv_1bram_dmem_ack  = wb_c_frv_1bram_ack & wb_c_frv_1bram_dmem_stb;
assign wb_c_frv_1bram_imem_rdat = wb_c_frv_1bram_rdat;
assign wb_c_frv_1bram_dmem_rdat = wb_c_frv_1bram_rdat;


// FazyRV 2-bit
logic        wb_c_frv_2_imem_stb;
logic        wb_c_frv_2_imem_cyc;
logic        wb_c_frv_2_imem_ack;
logic [31:0] wb_c_frv_2_imem_adr;
logic [31:0] wb_c_frv_2_imem_rdat;

logic        wb_c_frv_2_dmem_cyc;
logic        wb_c_frv_2_dmem_stb;
logic        wb_c_frv_2_dmem_we;
logic        wb_c_frv_2_dmem_ack;
logic [ 3:0] wb_c_frv_2_dmem_be;
logic [31:0] wb_c_frv_2_dmem_adr;
logic [31:0] wb_c_frv_2_dmem_rdat;
logic [31:0] wb_c_frv_2_dmem_wdat;

logic        wb_c_frv_2_cyc;
logic        wb_c_frv_2_stb;
logic        wb_c_frv_2_we;
logic        wb_c_frv_2_ack;
logic [ 3:0] wb_c_frv_2_be;
logic [31:0] wb_c_frv_2_adr;
logic [31:0] wb_c_frv_2_rdat;
logic [31:0] wb_c_frv_2_wdat;

assign wb_c_frv_2_cyc  = en_frv2_sync_r & (wb_c_frv_2_imem_cyc | wb_c_frv_2_dmem_cyc);
assign wb_c_frv_2_stb  = en_frv2_sync_r & (wb_c_frv_2_imem_stb | wb_c_frv_2_dmem_stb);
assign wb_c_frv_2_be   = wb_c_frv_2_imem_stb ? 4'b1111 : wb_c_frv_2_dmem_be;
assign wb_c_frv_2_adr  = wb_c_frv_2_imem_stb ? wb_c_frv_2_imem_adr : wb_c_frv_2_dmem_adr;
assign wb_c_frv_2_we   = wb_c_frv_2_dmem_stb & wb_c_frv_2_dmem_we;
assign wb_c_frv_2_wdat = wb_c_frv_2_dmem_wdat;

assign wb_c_frv_2_imem_ack  = wb_c_frv_2_ack & wb_c_frv_2_imem_stb;
assign wb_c_frv_2_dmem_ack  = wb_c_frv_2_ack & wb_c_frv_2_dmem_stb;
assign wb_c_frv_2_imem_rdat = wb_c_frv_2_rdat;
assign wb_c_frv_2_dmem_rdat = wb_c_frv_2_rdat;


// FazyRV 4-bit
logic        wb_c_frv_4_imem_stb;
logic        wb_c_frv_4_imem_cyc;
logic        wb_c_frv_4_imem_ack;
logic [31:0] wb_c_frv_4_imem_adr;
logic [31:0] wb_c_frv_4_imem_rdat;

logic        wb_c_frv_4_dmem_cyc;
logic        wb_c_frv_4_dmem_stb;
logic        wb_c_frv_4_dmem_we;
logic        wb_c_frv_4_dmem_ack;
logic [ 3:0] wb_c_frv_4_dmem_be;
logic [31:0] wb_c_frv_4_dmem_adr;
logic [31:0] wb_c_frv_4_dmem_rdat;
logic [31:0] wb_c_frv_4_dmem_wdat;

logic        wb_c_frv_4_cyc;
logic        wb_c_frv_4_stb;
logic        wb_c_frv_4_we;
logic        wb_c_frv_4_ack;
logic [ 3:0] wb_c_frv_4_be;
logic [31:0] wb_c_frv_4_adr;
logic [31:0] wb_c_frv_4_rdat;
logic [31:0] wb_c_frv_4_wdat;

assign wb_c_frv_4_cyc  = en_frv4_sync_r & (wb_c_frv_4_imem_cyc | wb_c_frv_4_dmem_cyc);
assign wb_c_frv_4_stb  = en_frv4_sync_r & (wb_c_frv_4_imem_stb | wb_c_frv_4_dmem_stb);
assign wb_c_frv_4_be   = wb_c_frv_4_imem_stb ? 4'b1111 : wb_c_frv_4_dmem_be;
assign wb_c_frv_4_adr  = wb_c_frv_4_imem_stb ? wb_c_frv_4_imem_adr : wb_c_frv_4_dmem_adr;
assign wb_c_frv_4_we   = wb_c_frv_4_dmem_stb & wb_c_frv_4_dmem_we;
assign wb_c_frv_4_wdat = wb_c_frv_4_dmem_wdat;

assign wb_c_frv_4_imem_ack  = wb_c_frv_4_ack & wb_c_frv_4_imem_stb;;
assign wb_c_frv_4_dmem_ack  = wb_c_frv_4_ack & wb_c_frv_4_dmem_stb;;
assign wb_c_frv_4_imem_rdat = wb_c_frv_4_rdat;
assign wb_c_frv_4_dmem_rdat = wb_c_frv_4_rdat;


// FazyRV 8-bit
logic        wb_c_frv_8_imem_stb;
logic        wb_c_frv_8_imem_cyc;
logic        wb_c_frv_8_imem_ack;
logic [31:0] wb_c_frv_8_imem_adr;
logic [31:0] wb_c_frv_8_imem_rdat;

logic        wb_c_frv_8_dmem_cyc;
logic        wb_c_frv_8_dmem_stb;
logic        wb_c_frv_8_dmem_we;
logic        wb_c_frv_8_dmem_ack;
logic [ 3:0] wb_c_frv_8_dmem_be;
logic [31:0] wb_c_frv_8_dmem_adr;
logic [31:0] wb_c_frv_8_dmem_rdat;
logic [31:0] wb_c_frv_8_dmem_wdat;

logic        wb_c_frv_8_cyc;
logic        wb_c_frv_8_stb;
logic        wb_c_frv_8_we;
logic        wb_c_frv_8_ack;
logic [ 3:0] wb_c_frv_8_be;
logic [31:0] wb_c_frv_8_adr;
logic [31:0] wb_c_frv_8_rdat;
logic [31:0] wb_c_frv_8_wdat;

assign wb_c_frv_8_cyc  = en_frv8_sync_r & (wb_c_frv_8_imem_cyc | wb_c_frv_8_dmem_cyc);
assign wb_c_frv_8_stb  = en_frv8_sync_r & (wb_c_frv_8_imem_stb | wb_c_frv_8_dmem_stb);
assign wb_c_frv_8_be   = wb_c_frv_8_imem_stb ? 4'b1111 : wb_c_frv_8_dmem_be;
assign wb_c_frv_8_adr  = wb_c_frv_8_imem_stb ? wb_c_frv_8_imem_adr : wb_c_frv_8_dmem_adr;
assign wb_c_frv_8_we   = wb_c_frv_8_dmem_stb & wb_c_frv_8_dmem_we;
assign wb_c_frv_8_wdat = wb_c_frv_8_dmem_wdat;

assign wb_c_frv_8_imem_ack  = wb_c_frv_8_ack & wb_c_frv_8_imem_stb;;
assign wb_c_frv_8_dmem_ack  = wb_c_frv_8_ack & wb_c_frv_8_dmem_stb;;
assign wb_c_frv_8_imem_rdat = wb_c_frv_8_rdat;
assign wb_c_frv_8_dmem_rdat = wb_c_frv_8_rdat;

// FazyRV 8-bit BRAM
logic        wb_c_frv_8bram_imem_stb;
logic        wb_c_frv_8bram_imem_cyc;
logic        wb_c_frv_8bram_imem_ack;
logic [31:0] wb_c_frv_8bram_imem_adr;
logic [31:0] wb_c_frv_8bram_imem_rdat;

logic        wb_c_frv_8bram_dmem_cyc;
logic        wb_c_frv_8bram_dmem_stb;
logic        wb_c_frv_8bram_dmem_we;
logic        wb_c_frv_8bram_dmem_ack;
logic [ 3:0] wb_c_frv_8bram_dmem_be;
logic [31:0] wb_c_frv_8bram_dmem_adr;
logic [31:0] wb_c_frv_8bram_dmem_rdat;
logic [31:0] wb_c_frv_8bram_dmem_wdat;

logic        wb_c_frv_8bram_cyc;
logic        wb_c_frv_8bram_stb;
logic        wb_c_frv_8bram_we;
logic        wb_c_frv_8bram_ack;
logic [ 3:0] wb_c_frv_8bram_be;
logic [31:0] wb_c_frv_8bram_adr;
logic [31:0] wb_c_frv_8bram_rdat;
logic [31:0] wb_c_frv_8bram_wdat;

assign wb_c_frv_8bram_cyc  = en_frv8bram_sync_r & (wb_c_frv_8bram_imem_cyc | wb_c_frv_8bram_dmem_cyc);
assign wb_c_frv_8bram_stb  = en_frv8bram_sync_r & (wb_c_frv_8bram_imem_stb | wb_c_frv_8bram_dmem_stb);
assign wb_c_frv_8bram_be   = wb_c_frv_8bram_imem_stb ? 4'b1111 : wb_c_frv_8bram_dmem_be;
assign wb_c_frv_8bram_adr  = wb_c_frv_8bram_imem_stb ? wb_c_frv_8bram_imem_adr : wb_c_frv_8bram_dmem_adr;
assign wb_c_frv_8bram_we   = wb_c_frv_8bram_dmem_stb & wb_c_frv_8bram_dmem_we;
assign wb_c_frv_8bram_wdat = wb_c_frv_8bram_dmem_wdat;

assign wb_c_frv_8bram_imem_ack  = wb_c_frv_8bram_ack & wb_c_frv_8bram_imem_stb;;
assign wb_c_frv_8bram_dmem_ack  = wb_c_frv_8bram_ack & wb_c_frv_8bram_dmem_stb;;
assign wb_c_frv_8bram_imem_rdat = wb_c_frv_8bram_rdat;
assign wb_c_frv_8bram_dmem_rdat = wb_c_frv_8bram_rdat;

// FazyRV 4-bit CCX
logic        wb_c_frv_4ccx_imem_stb;
logic        wb_c_frv_4ccx_imem_cyc;
logic        wb_c_frv_4ccx_imem_ack;
logic [31:0] wb_c_frv_4ccx_imem_adr;
logic [31:0] wb_c_frv_4ccx_imem_rdat;

logic        wb_c_frv_4ccx_dmem_cyc;
logic        wb_c_frv_4ccx_dmem_stb;
logic        wb_c_frv_4ccx_dmem_we;
logic        wb_c_frv_4ccx_dmem_ack;
logic [ 3:0] wb_c_frv_4ccx_dmem_be;
logic [31:0] wb_c_frv_4ccx_dmem_adr;
logic [31:0] wb_c_frv_4ccx_dmem_rdat;
logic [31:0] wb_c_frv_4ccx_dmem_wdat;

logic        wb_c_frv_4ccx_cyc;
logic        wb_c_frv_4ccx_stb;
logic        wb_c_frv_4ccx_we;
logic        wb_c_frv_4ccx_ack;
logic [ 3:0] wb_c_frv_4ccx_be;
logic [31:0] wb_c_frv_4ccx_adr;
logic [31:0] wb_c_frv_4ccx_rdat;
logic [31:0] wb_c_frv_4ccx_wdat;

assign wb_c_frv_4ccx_cyc  = en_frv4ccx_sync_r & (wb_c_frv_4ccx_imem_cyc | wb_c_frv_4ccx_dmem_cyc);
assign wb_c_frv_4ccx_stb  = en_frv4ccx_sync_r & (wb_c_frv_4ccx_imem_stb | wb_c_frv_4ccx_dmem_stb);
assign wb_c_frv_4ccx_be   = wb_c_frv_4ccx_imem_stb ? 4'b1111 : wb_c_frv_4ccx_dmem_be;
assign wb_c_frv_4ccx_adr  = wb_c_frv_4ccx_imem_stb ? wb_c_frv_4ccx_imem_adr : wb_c_frv_4ccx_dmem_adr;
assign wb_c_frv_4ccx_we   = wb_c_frv_4ccx_dmem_stb & wb_c_frv_4ccx_dmem_we;
assign wb_c_frv_4ccx_wdat = wb_c_frv_4ccx_dmem_wdat;

assign wb_c_frv_4ccx_imem_ack  = wb_c_frv_4ccx_ack & wb_c_frv_4ccx_imem_stb;;
assign wb_c_frv_4ccx_dmem_ack  = wb_c_frv_4ccx_ack & wb_c_frv_4ccx_dmem_stb;;
assign wb_c_frv_4ccx_imem_rdat = wb_c_frv_4ccx_rdat;
assign wb_c_frv_4ccx_dmem_rdat = wb_c_frv_4ccx_rdat;

// Wishbone CSR
logic        wb_p_csr_cyc;
logic        wb_p_csr_stb;
logic        wb_p_csr_ack;
logic        wb_p_csr_we;
logic [31:0] wb_p_csr_adr;
logic [31:0] wb_p_csr_wdat;
logic [31:0] wb_p_csr_rdat;
logic [ 3:0] wb_p_csr_sel;

logic [3:0] spi_presc;
logic [1:0] spi_size;
logic       spi_cpol;
logic       spi_auto_cs;
logic       spi_rdy;

// Wishbone SPI
logic        wb_p_spi_cyc;
logic        wb_p_spi_stb;
logic        wb_p_spi_ack;
logic        wb_p_spi_we;
logic [31:0] wb_p_spi_adr;
logic [31:0] wb_p_spi_wdat;
logic [31:0] wb_p_spi_rdat;
logic [ 3:0] wb_p_spi_sel;


// Wishbone EF SPI
logic        wb_p_efspi_cyc;
logic        wb_p_efspi_stb;
logic        wb_p_efspi_ack;
logic        wb_p_efspi_we;
logic [31:0] wb_p_efspi_adr;
logic [31:0] wb_p_efspi_wdat;
logic [31:0] wb_p_efspi_rdat;
logic [ 3:0] wb_p_efspi_sel;

logic        efspi_irq;

// Wishbone RAM
logic        wb_p_ram_cyc;
logic        wb_p_ram_stb;
logic        wb_p_ram_ack;
logic        wb_p_ram_we;
logic [31:0] wb_p_ram_adr;
logic [31:0] wb_p_ram_wdat;
logic [31:0] wb_p_ram_rdat;
logic [ 3:0] wb_p_ram_sel;

// OLED DMA
logic        wb_c_oled_dma_stb;
logic        wb_c_oled_dma_cyc;
logic        wb_c_oled_dma_ack;
logic [31:0] wb_c_oled_dma_adr;
logic [31:0] wb_c_oled_dma_rdat;

logic        oled_start;
logic [ 3:0] oled_presc;
logic [31:0] oled_spi_adr;
logic        oled_spi_inc;
logic [$clog2(MAX_SPI_LENGTH+1)-1:0] oled_size;
logic        oled_rdy;

// QSPI Memory
logic        wb_p_qspi_mem_cyc;
logic        wb_p_qspi_mem_stb;
logic        wb_p_qspi_mem_ack;
logic        wb_p_qspi_mem_we;
logic [31:0] wb_p_qspi_mem_adr;
logic [31:0] wb_p_qspi_mem_wdat;
logic [31:0] wb_p_qspi_mem_rdat;
logic [ 3:0] wb_p_qspi_mem_sel;

// EF XIP
logic        wb_p_ef_xip_cyc;
logic        wb_p_ef_xip_stb;
logic        wb_p_ef_xip_ack;
logic        wb_p_ef_xip_we;
logic [31:0] wb_p_ef_xip_adr;
logic [31:0] wb_p_ef_xip_wdat;
logic [31:0] wb_p_ef_xip_rdat;
logic [ 3:0] wb_p_ef_xip_sel;

logic        guard_xip;

logic [31:0] xip_wb_brdg_mHRDATA;
logic        xip_wb_brdg_mHREADY;
logic        xip_wb_brdg_mHSEL;
logic        xip_wb_brdg_mHWRITE;
logic [31:0] xip_wb_brdg_mHADDR;
logic [ 1:0] xip_wb_brdg_mHTRANS;
logic        xip_wb_brdg_mHREADYOUT;

// UART
logic        wb_p_uart_cyc;
logic        wb_p_uart_stb;
logic        wb_p_uart_ack;
logic        wb_p_uart_we;
logic [31:0] wb_p_uart_adr;
logic [31:0] wb_p_uart_wdat;
logic [31:0] wb_p_uart_rdat;
logic [ 3:0] wb_p_uart_sel;

logic uart_irq;


// mmmmm           m             mmm           mmm  ""#    #     
// #   "#  mmm   mm#mm          #            m"   "   #    #   m 
// #mmmm" #   "    #            ##           #        #    # m"  
// #   "m  """m    #           #  #m#        #        #    #"#   
// #    " "mmm"    "mm         "#mm#m         "mmm"   "mm  #  "m 
//
//################################################################                                                             
                                                               
logic [4:0] rst_delay_cnt;
logic       rst_dly_n;
logic       rst_sync_n;

reset_sync i_reset_sync (
  .clk_i          ( clk_i       ),
  .async_reset_on ( rst_in      ),
  .sync_reset_on  ( rst_sync_n  )
);

always_ff @(posedge clk_i or negedge rst_sync_n) begin
  if (!rst_sync_n) begin
    rst_delay_cnt <= '0;
    rst_dly_n     <= 1'b0;
  end else begin
    if (rst_delay_cnt != 5'd15)
      rst_delay_cnt <= rst_delay_cnt + 1'b1;
    else
      rst_dly_n <= 1'b1;
  end
end

assign rst_wb_n           = rst_sync_n;
assign rst_p_n            = rst_sync_n;
assign rst_c_frv_1_n      = rst_dly_n;
assign rst_c_frv_2_n      = rst_dly_n;
assign rst_c_frv_4_n      = rst_dly_n;
assign rst_c_frv_8_n      = rst_dly_n;
assign rst_c_frv_4ccx_n   = rst_dly_n;
assign rst_c_frv_1bram_n  = rst_dly_n;
assign rst_c_frv_8bram_n  = rst_dly_n;

//  mmm    mmmm 
// #"  "  #" "# 
// #      #   # 
// "#mm"  "#m"# 
//         m  # 
//          "" 
//############### 

localparam N_CLOCKS = 10;


// We don't have any IO left, so we take the
// CCX result if the CCX variant is not enabled
logic en_frv1bram;
logic en_frv8bram;

assign en_frv1bram = ~en_frv4ccx_i & ccx4_res_i[0];
assign en_frv8bram = ~en_frv4ccx_i & ccx4_res_i[1];

always_ff @(posedge clk_i) begin
  if (~rst_sync_n) begin
    en_frv1_sync_r      <= 1'b1;
    en_frv2_sync_r      <= 1'b1;
    en_frv4_sync_r      <= 1'b1;
    en_frv8_sync_r      <= 1'b1;
    en_frv4ccx_sync_r   <= 1'b1;
    en_frv1bram_sync_r  <= 1'b1;
    en_frv8bram_sync_r  <= 1'b1;
   end else begin
    if (en_frv1_i)    en_frv1_sync_r <= 1'b1;
    else              en_frv1_sync_r <= en_frv1_sync_r & wb_c_frv_1_stb;
    if (en_frv2_i)    en_frv2_sync_r <= 1'b1;
    else              en_frv2_sync_r <= en_frv2_sync_r & wb_c_frv_2_stb;
    if (en_frv4_i)    en_frv4_sync_r <= 1'b1;
    else              en_frv4_sync_r <= en_frv4_sync_r & wb_c_frv_4_stb;
    if (en_frv8_i)    en_frv8_sync_r <= 1'b1;
    else              en_frv8_sync_r <= en_frv8_sync_r & wb_c_frv_8_stb;
    if (en_frv4ccx_i) en_frv4ccx_sync_r <= 1'b1;
    else              en_frv4ccx_sync_r <= en_frv4ccx_sync_r & wb_c_frv_4ccx_stb;
    if (en_frv1bram)  en_frv1bram_sync_r <= 1'b1;
    else              en_frv1bram_sync_r <= en_frv1bram_sync_r & wb_c_frv_1bram_stb;
    if (en_frv8bram)  en_frv8bram_sync_r <= 1'b1;
    else              en_frv8bram_sync_r <= en_frv8bram_sync_r & wb_c_frv_8bram_stb;
  end
end

logic [N_CLOCKS-1:0] cg_enables;
logic [N_CLOCKS-1:0] cg_clks;

assign cg_enables = { en_p2_i, 
                      en_p_i, 
                      en_wb_i,
                      en_frv1_sync_r,
                      en_frv2_sync_r,
                      en_frv4_sync_r,
                      en_frv8_sync_r,
                      en_frv4ccx_sync_r,
                      en_frv1bram_sync_r,
                      en_frv8bram_sync_r };

assign {  clk_p2,
          clk_p,
          clk_wb,
          clk_c_frv_1,
          clk_c_frv_2,
          clk_c_frv_4,
          clk_c_frv_8,
          clk_c_frv_4ccx,
          clk_c_frv_1bram,
          clk_c_frv_8bram } = cg_clks;

`ifndef NO_CLOCK_GATES
genvar i;
generate
  for (i = 0; i < N_CLOCKS; i = i + 1) begin : i_cg
    gf180mcu_fd_sc_mcu7t5v0__icgtp_4 i_cg ( 
      `ifdef USE_POWER_PINS
      .VDD  ( VDD           ),
      .VSS  ( VSS           ),
      .VNW  ( VDD           ),
      .VPW  ( VSS           ),
      `endif
      .TE   ( 1'b0          ),
      .E    ( cg_enables[i] ),
      .CLK  ( clk_i         ),
      .Q    ( cg_clks[i]    )
    );
  end
endgenerate

`else
genvar i;
generate
for (i = 0; i < N_CLOCKS; i = i + 1) begin : i_cg
  assign cg_clks[i] = cg_enables[i] & clk_i;
end
endgenerate

`endif


//                                                                             
// mmmmm                  "           #                           ""#          
// #   "#  mmm    m mm  mmm    mmmm   # mm    mmm    m mm   mmm     #     mmm  
// #mmm#" #"  #   #"  "   #    #" "#  #"  #  #"  #   #"  " "   #    #    #   " 
// #      #""""   #       #    #   #  #   #  #""""   #     m"""#    #     """m 
// #      "#mm"   #     mm#mm  ##m#"  #   #  "#mm"   #     "mm"#    "mm  "mmm" 
//                             #                                               
//                             "              
//##############################################################################    
                                              
                            
                                                                             
//   mmm   mmmm  mmmmm                  mmm           mmm  mmmmm  mmmmm   mmmm 
// m"   " #"   " #   "#  mmm           #            m"   " #   "#   #    m"  "m
// #      "#mmm  #mmmm" #   "          ##           #   mm #mmm#"   #    #    #
// #          "# #   "m  """m         #  #m#        #    # #        #    #    #
//  "mmm" "mmm#" #    " "mmm"         "#mm#m         "mmm" #      mm#mm   #mm# 
                                                                                                                                                          
/* verilator lint_off PINCONNECTEMPTY */
CSR #(
  .USE_STALL ( 0 )
) i_CSR (
  .i_clk                          ( clk_p               ),
  .i_rst_n                        ( rst_p_n             ),
  .i_wb_cyc                       ( wb_p_csr_cyc        ),
  .i_wb_stb                       ( wb_p_csr_stb        ),
  .o_wb_stall                     ( /* nc */            ),
  .i_wb_adr                       ( wb_p_csr_adr[5:0]   ),
  .i_wb_we                        ( wb_p_csr_we         ),
  .i_wb_dat                       ( wb_p_csr_wdat       ),
  .i_wb_sel                       ( wb_p_csr_sel        ),
  .o_wb_ack                       ( wb_p_csr_ack        ),
  .o_wb_err                       ( /* nc */            ),
  .o_wb_rty                       ( /* nc */            ),
  .o_wb_dat                       ( wb_p_csr_rdat       ),
  .i_GPI_gpi                      ( gpi_i               ),
  .o_GPO_gpo                      ( gpo_o               ),
  .o_GPOE_gpoe                    ( gpeo_o              ),
  .o_GPCS_gpcs                    ( gpcs_o              ),
  .o_GPSL_gpsl                    ( gpsl_o              ),
  .o_GPPU_gppu                    ( gppu_o              ),
  .o_GPPD_gppd                    ( gppd_o              ),
  .o_SPI_Conf_presc               ( spi_presc           ),
  .o_SPI_Conf_cpol                ( spi_cpol            ),
  .o_SPI_Conf_auto_cs             ( spi_auto_cs         ),
  .o_SPI_Conf_size                ( spi_size            ),
  .o_OLED_Start_Status_start_rdy  ( oled_start          ),
  .i_OLED_Start_Status_start_rdy  ( oled_rdy            ),
  .o_OLED_Conf_presc              ( oled_presc          ),
  .o_OLED_Conf_inc                ( oled_spi_inc        ),
  .o_OLED_Conf_size               ( oled_size           ),
  .o_OLED_Dma_addr                ( oled_spi_adr        ),
  .i_Irqs_uart_irq                ( uart_irq            ),
  .i_Irqs_spi_irq                 ( efspi_irq           ),
  .i_Irqs_spi_rdy                 ( spi_rdy             ),
  .o_Guard_gd_ef_xip              ( guard_xip           ),
  .o_Misc_Slew_Rate_bidir_sl      ( csr_slew_o          ),
  .o_Misc_Pull_pu                 ( csr_pu_o            ),
  .o_Misc_Pull_pd                 ( csr_pd_o            )
);

/* verilator lint_on PINCONNECTEMPTY */

//          mmmm  mmmmm  mmmmm 
//         #"   " #   "#   #   
//         "#mmm  #mmm#"   #   
//             "# #        #   
//         "mmm#" #      mm#mm 


wb_spi i_wb_spi (
  .rst_in         ( rst_p_n       ),
  .clk_i          ( clk_p         ),
  // Wishbone
  .wb_spi_cyc_i   ( wb_p_spi_cyc  ),
  .wb_spi_stb_i   ( wb_p_spi_stb  ),
  .wb_spi_we_i    ( wb_p_spi_we   ),
  .wb_spi_ack_o   ( wb_p_spi_ack  ),
  .wb_spi_dat_i   ( wb_p_spi_wdat ),
  .wb_spi_dat_o   ( wb_p_spi_rdat ),
  // SPI Config
  .presc_i        ( spi_presc     ),
  .size_i         ( spi_size      ),
  .cpol_i         ( spi_cpol      ),
  .auto_cs_i      ( spi_auto_cs   ),
  .rdy_o          ( spi_rdy       ),
  // SPI Interface
  .spi_cs_o       ( spi_cs_o      ),
  .spi_sck_o      ( spi_sck_o     ),
  .spi_sdo_o      ( spi_sdo_o     ),
  .spi_sdi_i      ( spi_sdi_i     )
);

                                         
//           mmmmmm mmmmmm         mmmm  mmmmm  mmmmm        
//           #      #             #"   " #   "#   #          
//           #mmmmm #mmmmm        "#mmm  #mmm#"   #          
//           #      #                 "# #        #          
//           #mmmmm #             "mmm#" #      mm#mm        
                                                 
EF_SPI_WB #(
  .CDW ( 8 ),
  .FAW ( 4 )
) i_EF_SPI_WB (
  `ifdef USE_POWER_PINS
  .vpwr   ( VDD             ),
  .vgnd   ( VSS             ),
  `endif
  .clk_i  ( clk_p2          ),
  .rst_i  ( ~rst_p_n        ),
  .adr_i  ( wb_p_efspi_adr  ),
  .dat_i  ( wb_p_efspi_wdat ),
  .dat_o  ( wb_p_efspi_rdat ),
  .sel_i  ( wb_p_efspi_sel  ),
  .cyc_i  ( wb_p_efspi_cyc  ),
  .stb_i  ( wb_p_efspi_stb  ),
  .ack_o  ( wb_p_efspi_ack  ),
  .we_i   ( wb_p_efspi_we   ),
  .IRQ    ( efspi_irq       ),
  .miso   ( efspi_sdi_i     ),
  .mosi   ( efspi_sdo_o     ),
  .csb    ( efspi_cs_o      ),
  .sclk   ( efspi_sck_o     )
);   

        
//           m    m mmmmm  mmmmm          mmmm   mmmm  mmmmm  mmmmm 
//            #  #    #    #   "#        m"  "m #"   " #   "#   #   
//             ##     #    #mmm#"        #    # "#mmm  #mmm#"   #   
//            m""m    #    #             #    #     "# #        #   
//           m"  "m mm#mm  #              #mm#" "mmm#" #      mm#mm 
//                                          #                      
                                                        
wb_qspi_mem i_wb_qspi_mem (
  .clk_i          ( clk_p   ),                                                                    
  .rst_in         ( rst_p_n ),
  // select mem before, one module to reduce area
  .sel_rom_ram_i  ( wb_p_qspi_mem_adr[28]   ),
  // wishbone
  .wb_mem_stb_i   ( wb_p_qspi_mem_stb & wb_p_qspi_mem_cyc ),
  .wb_mem_we_i    ( wb_p_qspi_mem_we        ),
  .wb_mem_ack_o   ( wb_p_qspi_mem_ack       ),
  .wb_mem_be_i    ( wb_p_qspi_mem_sel       ),
  .wb_mem_dat_i   ( wb_p_qspi_mem_wdat      ),
  .wb_mem_adr_i   ( wb_p_qspi_mem_adr[23:2] ), // word address
  .wb_mem_dat_o   ( wb_p_qspi_mem_rdat      ),
  // qspi peripherals
  .cs_ram_on      ( qspi_mem_cs_ram_on  ),
  .cs_rom_on      ( qspi_mem_cs_rom_on  ),
  .sck_o          ( qspi_mem_sck_o      ),
  .sd_i           ( qspi_mem_sd_i       ),
  .sd_o           ( qspi_mem_sd_o       ),
  .sd_oen_o       ( qspi_mem_oen_o      )
);

          
//           mmmmmm mmmmmm        m    m mmmmm  mmmmm        
//           #      #              #  #    #    #   "#       
//           #mmmmm #mmmmm          ##     #    #mmm#"       
//           #      #              m""m    #    #            
//           #mmmmm #             m"  "m mm#mm  #                              

logic gd_wb_xip_ack;
assign wb_p_ef_xip_ack = gd_wb_xip_ack & guard_xip;

/* verilator lint_off PINCONNECTEMPTY */
wb_to_ahb3lite i_wb_to_ahb3lite (
  .clk_i            ( clk_p2                  ),
  .rst_n_i          ( rst_p_n                 ),
  // Wishbone; Note: suffix is invered in this ip
  .from_m_wb_adr_o  ( wb_p_ef_xip_adr         ),
  .from_m_wb_sel_o  ( wb_p_ef_xip_sel         ),
  .from_m_wb_we_o   ( wb_p_ef_xip_we          ),
  .from_m_wb_dat_o  ( wb_p_ef_xip_wdat        ),
  .from_m_wb_cyc_o  ( wb_p_ef_xip_cyc         ),
  .from_m_wb_stb_o  ( wb_p_ef_xip_stb         ),
  .to_m_wb_ack_i    ( gd_wb_xip_ack           ),
  .to_m_wb_err_i    ( /* nc */                ),
  .to_m_wb_dat_i    ( wb_p_ef_xip_rdat        ),
  .from_m_wb_cti_o  ( 3'b0                    ),
  .from_m_wb_bte_o  ( 2'b0                    ),
  // to ahb3lite
  .mHSEL            ( xip_wb_brdg_mHSEL       ),
  .mHSIZE           ( /* nc */                ),
  .mHRDATA          ( xip_wb_brdg_mHRDATA     ),
  .mHRESP           ( 1'b0                    ),
  .mHREADY          ( xip_wb_brdg_mHREADY     ),
  .mHREADYOUT       ( xip_wb_brdg_mHREADYOUT  ),
  .mHWRITE          ( xip_wb_brdg_mHWRITE     ),
  .mHBURST          ( /* nc */                ),
  .mHADDR           ( xip_wb_brdg_mHADDR      ),
  .mHTRANS          ( xip_wb_brdg_mHTRANS     ),
  .mHWDATA          ( /* nc */                ),
  .mHPROT           ( /* nc */                )
);
/* verilator lint_on PINCONNECTEMPTY */

MS_QSPI_XIP_CACHE_ahbl #(
  .NUM_LINES ( 32 ),
  .LINE_SIZE ( 32 )
) i_MS_QSPI_XIP_CACHE_ahbl (
    // AHB-Lite Interface
    .HCLK       ( clk_p2                  ),
    .HRESETn    ( rst_p_n                 ),
    .HSEL       ( xip_wb_brdg_mHSEL       ),
    .HADDR      ( xip_wb_brdg_mHADDR      ),
    .HTRANS     ( xip_wb_brdg_mHTRANS     ),
    .HWRITE     ( xip_wb_brdg_mHWRITE     ),
    .HREADY     ( xip_wb_brdg_mHREADYOUT  ),
    .HREADYOUT  ( xip_wb_brdg_mHREADY     ),
    .HRDATA     ( xip_wb_brdg_mHRDATA     ),
    // Quad I/O
    .sck        ( xip_sck_o               ),
    .ce_n       ( xip_cs_on               ),
    .din        ( xip_sd_i                ),
    .dout       ( xip_sd_o                ),
    .douten     ( xip_oen_o               )     
);

   
//           m    m   mm   mmmmm mmmmmmm
//           #    #   ##   #   "#   #   
//           #    #  #  #  #mmmm"   #   
//           #    #  #mm#  #   "m   #   
//           "mmmm" #    # #    "   #   

EF_UART_WB #(
  .SC    ( 8 ),
  .MDW   ( 9 ),
  .GFLEN ( 8 ),
  .FAW   ( 4 )
) i_uart (
  `ifdef USE_POWER_PINS
  .vpwr   ( VDD             ),
  .vgnd   ( VSS             ),
  `endif
  .clk_i  ( clk_p           ),
  .rst_i  ( ~rst_p_n        ),
  .adr_i  ( wb_p_uart_adr   ),
  .dat_i  ( wb_p_uart_wdat  ),
  .dat_o  ( wb_p_uart_rdat  ),
  .sel_i  ( wb_p_uart_sel   ),
  .cyc_i  ( wb_p_uart_cyc   ),
  .stb_i  ( wb_p_uart_stb   ),
  .ack_o  ( wb_p_uart_ack   ),
  .we_i   ( wb_p_uart_we    ),
  // TODO: check if that needs to be registered
  .IRQ    ( uart_irq        ),  
  .rx     ( uart_rx_i       ),
  .tx     ( uart_tx_o       )
);

                            
//           mmmm  m      mmmmmm mmmm  
//          m"  "m #      #      #   "m
//          #    # #      #mmmmm #    #
//          #    # #      #      #    #
//           #mm#  #mmmmm #mmmmm #mmm"                       
                            
tiny_wb_dma_oled_spi #(
  .MAX_SPI_LENGTH ( MAX_SPI_LENGTH    ),
  .PREFETCH       ( SPI_PREFETCH      )
) i_tiny_wb_dma_oled_spi (
  .clk_i         ( clk_p              ),
  .rst_in        ( rst_p_n            ),
  // memory access interface
  .wbm_spi_cyc_o ( wb_c_oled_dma_cyc  ),
  .wbm_spi_stb_o ( wb_c_oled_dma_stb  ),
  .wbm_spi_adr_o ( wb_c_oled_dma_adr  ),
  .wbm_spi_ack_i ( wb_c_oled_dma_ack  ),
  .wbm_spi_dat_i ( wb_c_oled_dma_rdat ),
  // control
  .start_i       ( oled_start         ),
  .presc_i       ( oled_presc         ),
  .spi_adr_i     ( oled_spi_adr       ),
  .spi_inc_i     ( oled_spi_inc       ),
  .size_i        ( oled_size          ),
  .rdy_o         ( oled_rdy           ),
  // spi data
  .spi_sck_o     ( spi_oled_sck_o     ),
  .spi_sdo_o     ( spi_oled_sdo_o     )
);
                                  
//          mmmmm    mm   m    m
//          #   "#   ##   ##  ##
//          #mmmm"  #  #  # ## #
//          #   "m  #mm#  # "" #
//          #    " #    # #    #
//                     
                                    
//localparam RAM_DEPTH = 2048; // words  

localparam RAM_DEPTH = 5*512; // words  

wb_ram #( .DEPTH( RAM_DEPTH ) ) i_wb_ram (
  `ifdef USE_POWER_PINS
  .VDD      ( VDD           ),
  .VSS      ( VSS           ),
  `endif
  .clk_i    ( clk_p         ),
  .rst_in   ( rst_wb_n      ),
  // Wishbone
  .wb_stb_i ( wb_p_ram_stb  ),
  .wb_cyc_i ( wb_p_ram_cyc  ),
  .wb_we_i  ( wb_p_ram_we   ),
  .wb_ack_o ( wb_p_ram_ack  ),
  .wb_sel_i ( wb_p_ram_sel  ),
  .wb_dat_i ( wb_p_ram_wdat ),
  .wb_adr_i ( wb_p_ram_adr[$clog2(RAM_DEPTH/512)+10:2]), // word address
  .wb_dat_o ( wb_p_ram_rdat )
);

//                                                                      
//   mmm                  m                  ""#    ""#                 
// m"   "  mmm   m mm   mm#mm   m mm   mmm     #      #     mmm    m mm 
// #      #" "#  #"  #    #     #"  " #" "#    #      #    #"  #   #"  "
// #      #   #  #   #    #     #     #   #    #      #    #""""   #    
//  "mmm" "#m#"  #   #    "mm   #     "#m#"    "mm    "mm  "#mm"   #    
//
//########################################################################
                                                                      

frv_1 i_frv_1 (
  `ifdef USE_POWER_PINS
  .VDD           ( VDD                  ),
  .VSS           ( VSS                  ),
  `endif
  .clk_i         ( clk_c_frv_1          ),
  .rst_in        ( rst_c_frv_1_n        ),
  // imem
  .wb_imem_stb_o ( wb_c_frv_1_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_1_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_1_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_1_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_1_imem_ack  ),
  // dmem
  .wb_dmem_cyc_o ( wb_c_frv_1_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_1_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_1_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_1_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_1_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_1_dmem_rdat ),
  .wb_dmem_adr_o ( wb_c_frv_1_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_1_dmem_wdat )
);

frv_2 i_frv_2 (
  `ifdef USE_POWER_PINS
  .VDD           ( VDD                  ),
  .VSS           ( VSS                  ),
  `endif
  .clk_i         ( clk_c_frv_2          ),
  .rst_in        ( rst_c_frv_2_n        ),
  // imem
  .wb_imem_stb_o ( wb_c_frv_2_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_2_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_2_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_2_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_2_imem_ack  ),
  // dmem
  .wb_dmem_cyc_o ( wb_c_frv_2_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_2_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_2_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_2_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_2_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_2_dmem_rdat ),
  .wb_dmem_adr_o ( wb_c_frv_2_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_2_dmem_wdat )
);

frv_4 i_frv_4 (
  `ifdef USE_POWER_PINS
  .VDD           ( VDD                  ),
  .VSS           ( VSS                  ),
  `endif
  .clk_i         ( clk_c_frv_4          ),
  .rst_in        ( rst_c_frv_4_n        ),
  // imem
  .wb_imem_stb_o ( wb_c_frv_4_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_4_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_4_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_4_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_4_imem_ack  ),
  // dmem
  .wb_dmem_cyc_o ( wb_c_frv_4_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_4_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_4_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_4_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_4_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_4_dmem_rdat ),
  .wb_dmem_adr_o ( wb_c_frv_4_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_4_dmem_wdat )
);

frv_8 i_frv_8 (
  `ifdef USE_POWER_PINS
  .VDD           ( VDD                  ),
  .VSS           ( VSS                  ),
  `endif
  .clk_i         ( clk_c_frv_8          ),
  .rst_in        ( rst_c_frv_8_n        ),
  // imem
  .wb_imem_stb_o ( wb_c_frv_8_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_8_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_8_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_8_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_8_imem_ack  ),
  // dmem
  .wb_dmem_cyc_o ( wb_c_frv_8_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_8_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_8_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_8_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_8_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_8_dmem_rdat ),
  .wb_dmem_adr_o ( wb_c_frv_8_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_8_dmem_wdat )
);

frv_4ccx i_frv_4ccx (
  `ifdef USE_POWER_PINS
  .VDD           ( VDD                     ),
  .VSS           ( VSS                     ),
  `endif
  .clk_i         ( clk_c_frv_4ccx          ),
  .rst_in        ( rst_c_frv_4ccx_n        ),
  // imem
  .wb_imem_stb_o ( wb_c_frv_4ccx_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_4ccx_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_4ccx_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_4ccx_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_4ccx_imem_ack  ),
  // dmem
  .wb_dmem_cyc_o ( wb_c_frv_4ccx_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_4ccx_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_4ccx_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_4ccx_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_4ccx_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_4ccx_dmem_rdat ),
  .wb_dmem_adr_o ( wb_c_frv_4ccx_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_4ccx_dmem_wdat ),

  .ccx_rs_a_o    ( ccx4_rs_a_o             ),
  .ccx_rs_b_o    ( ccx4_rs_b_o             ),
  .ccx_res_i     ( ccx4_res_i              ),
  .ccx_sel_o     ( ccx4_sel_o              ),
  .ccx_req_o     ( ccx4_req_o              ),
  .ccx_resp_i    ( ccx4_resp_i             )
);

frv_1bram i_frv_1bram (
  `ifdef USE_POWER_PINS
  .VDD           ( VDD                      ),
  .VSS           ( VSS                      ),
  `endif
  .clk_i         ( clk_c_frv_1bram          ),
  .rst_in        ( rst_c_frv_1bram_n        ),
  // imem
  .wb_imem_stb_o ( wb_c_frv_1bram_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_1bram_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_1bram_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_1bram_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_1bram_imem_ack  ),
  // dmem
  .wb_dmem_cyc_o ( wb_c_frv_1bram_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_1bram_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_1bram_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_1bram_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_1bram_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_1bram_dmem_rdat ),
  .wb_dmem_adr_o ( wb_c_frv_1bram_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_1bram_dmem_wdat )
);

frv_8bram i_frv_8bram (
  `ifdef USE_POWER_PINS
  .VDD           ( VDD                      ),
  .VSS           ( VSS                      ),
  `endif
  .clk_i         ( clk_c_frv_8bram          ),
  .rst_in        ( rst_c_frv_8bram_n        ),
  // imem
  .wb_imem_stb_o ( wb_c_frv_8bram_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_8bram_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_8bram_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_8bram_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_8bram_imem_ack  ),
  // dmem
  .wb_dmem_cyc_o ( wb_c_frv_8bram_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_8bram_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_8bram_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_8bram_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_8bram_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_8bram_dmem_rdat ),
  .wb_dmem_adr_o ( wb_c_frv_8bram_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_8bram_dmem_wdat )
);

                                                        
// mmmmm           m                                      
//   #    m mm   mm#mm   mmm    m mm   mmm    mmm   m mm  
//   #    #"  #    #    #"  #   #"  " #"  "  #" "#  #"  # 
//   #    #   #    #    #""""   #     #      #   #  #   # 
// mm#mm  #   #    "mm  "#mm"   #     "#mm"  "#m#"  #   # 
//                                                      
//#########################################################                                                      

/* verilator lint_off PINCONNECTEMPTY */
wb_intercon i_wb_intercon (
  .wb_clk_i               ( clk_wb              ),
  .wb_rst_i               ( ~rst_wb_n           ),
  // 
  .wb_fazyrv1_adr_i       ( wb_c_frv_1_adr      ),
  .wb_fazyrv1_dat_i       ( wb_c_frv_1_wdat     ),
  .wb_fazyrv1_sel_i       ( wb_c_frv_1_be       ),
  .wb_fazyrv1_we_i        ( wb_c_frv_1_we       ),
  .wb_fazyrv1_cyc_i       ( wb_c_frv_1_cyc      ),
  .wb_fazyrv1_stb_i       ( wb_c_frv_1_stb      ),
  .wb_fazyrv1_cti_i       ( 3'b0                ),
  .wb_fazyrv1_bte_i       ( 2'b0                ),
  .wb_fazyrv1_rdt_o       ( wb_c_frv_1_rdat     ),
  .wb_fazyrv1_ack_o       ( wb_c_frv_1_ack      ),
  .wb_fazyrv1_err_o       ( /* nc */            ),
  .wb_fazyrv1_rty_o       ( /* nc */            ),
  //
  .wb_fazyrv2_adr_i       ( wb_c_frv_2_adr      ),
  .wb_fazyrv2_dat_i       ( wb_c_frv_2_wdat     ),
  .wb_fazyrv2_sel_i       ( wb_c_frv_2_be       ),
  .wb_fazyrv2_we_i        ( wb_c_frv_2_we       ),
  .wb_fazyrv2_cyc_i       ( wb_c_frv_2_cyc      ),
  .wb_fazyrv2_stb_i       ( wb_c_frv_2_stb      ),
  .wb_fazyrv2_cti_i       ( 3'b0                ),
  .wb_fazyrv2_bte_i       ( 2'b0                ),
  .wb_fazyrv2_rdt_o       ( wb_c_frv_2_rdat     ),
  .wb_fazyrv2_ack_o       ( wb_c_frv_2_ack      ),
  .wb_fazyrv2_err_o       ( /* nc */            ),
  .wb_fazyrv2_rty_o       ( /* nc */            ),
  //
  .wb_fazyrv4_adr_i       ( wb_c_frv_4_adr      ),
  .wb_fazyrv4_dat_i       ( wb_c_frv_4_wdat     ),
  .wb_fazyrv4_sel_i       ( wb_c_frv_4_be       ),
  .wb_fazyrv4_we_i        ( wb_c_frv_4_we       ),
  .wb_fazyrv4_cyc_i       ( wb_c_frv_4_cyc      ),
  .wb_fazyrv4_stb_i       ( wb_c_frv_4_stb      ),
  .wb_fazyrv4_cti_i       ( 3'b0                ),
  .wb_fazyrv4_bte_i       ( 2'b0                ),
  .wb_fazyrv4_rdt_o       ( wb_c_frv_4_rdat     ),
  .wb_fazyrv4_ack_o       ( wb_c_frv_4_ack      ),
  .wb_fazyrv4_err_o       ( /* nc */            ),
  .wb_fazyrv4_rty_o       ( /* nc */            ),
  //
  .wb_fazyrv8_adr_i       ( wb_c_frv_8_adr      ),
  .wb_fazyrv8_dat_i       ( wb_c_frv_8_wdat     ),
  .wb_fazyrv8_sel_i       ( wb_c_frv_8_be       ),
  .wb_fazyrv8_we_i        ( wb_c_frv_8_we       ),
  .wb_fazyrv8_cyc_i       ( wb_c_frv_8_cyc      ),
  .wb_fazyrv8_stb_i       ( wb_c_frv_8_stb      ),
  .wb_fazyrv8_cti_i       ( 3'b0                ),
  .wb_fazyrv8_bte_i       ( 2'b0                ),
  .wb_fazyrv8_rdt_o       ( wb_c_frv_8_rdat     ),
  .wb_fazyrv8_ack_o       ( wb_c_frv_8_ack      ),
  .wb_fazyrv8_err_o       ( /* nc */            ),
  .wb_fazyrv8_rty_o       ( /* nc */            ),
  //
  .wb_fazyrv4ccx_adr_i    ( wb_c_frv_4ccx_adr   ),
  .wb_fazyrv4ccx_dat_i    ( wb_c_frv_4ccx_wdat  ),
  .wb_fazyrv4ccx_sel_i    ( wb_c_frv_4ccx_be    ),
  .wb_fazyrv4ccx_we_i     ( wb_c_frv_4ccx_we    ),
  .wb_fazyrv4ccx_cyc_i    ( wb_c_frv_4ccx_cyc   ),
  .wb_fazyrv4ccx_stb_i    ( wb_c_frv_4ccx_stb   ),
  .wb_fazyrv4ccx_cti_i    ( 3'b0                ),
  .wb_fazyrv4ccx_bte_i    ( 2'b0                ),
  .wb_fazyrv4ccx_rdt_o    ( wb_c_frv_4ccx_rdat  ),
  .wb_fazyrv4ccx_ack_o    ( wb_c_frv_4ccx_ack   ),
  .wb_fazyrv4ccx_err_o    ( /* nc */            ),
  .wb_fazyrv4ccx_rty_o    ( /* nc */            ),
  // 
  .wb_fazyrv1bram_adr_i   ( wb_c_frv_1bram_adr  ),
  .wb_fazyrv1bram_dat_i   ( wb_c_frv_1bram_wdat ),
  .wb_fazyrv1bram_sel_i   ( wb_c_frv_1bram_be   ),
  .wb_fazyrv1bram_we_i    ( wb_c_frv_1bram_we   ),
  .wb_fazyrv1bram_cyc_i   ( wb_c_frv_1bram_cyc  ),
  .wb_fazyrv1bram_stb_i   ( wb_c_frv_1bram_stb  ),
  .wb_fazyrv1bram_cti_i   ( 3'b0                ),
  .wb_fazyrv1bram_bte_i   ( 2'b0                ),
  .wb_fazyrv1bram_rdt_o   ( wb_c_frv_1bram_rdat ),
  .wb_fazyrv1bram_ack_o   ( wb_c_frv_1bram_ack  ),
  .wb_fazyrv1bram_err_o   ( /* nc */            ),
  .wb_fazyrv1bram_rty_o   ( /* nc */            ),
  //
  .wb_fazyrv8bram_adr_i   ( wb_c_frv_8bram_adr  ),
  .wb_fazyrv8bram_dat_i   ( wb_c_frv_8bram_wdat ),
  .wb_fazyrv8bram_sel_i   ( wb_c_frv_8bram_be   ),
  .wb_fazyrv8bram_we_i    ( wb_c_frv_8bram_we   ),
  .wb_fazyrv8bram_cyc_i   ( wb_c_frv_8bram_cyc  ),
  .wb_fazyrv8bram_stb_i   ( wb_c_frv_8bram_stb  ),
  .wb_fazyrv8bram_cti_i   ( 3'b0                ),
  .wb_fazyrv8bram_bte_i   ( 2'b0                ),
  .wb_fazyrv8bram_rdt_o   ( wb_c_frv_8bram_rdat ),
  .wb_fazyrv8bram_ack_o   ( wb_c_frv_8bram_ack  ),
  .wb_fazyrv8bram_err_o   ( /* nc */            ),
  .wb_fazyrv8bram_rty_o   ( /* nc */            ),
  //
  .wb_oled_dma_adr_i      ( wb_c_oled_dma_adr   ),
  .wb_oled_dma_dat_i      ( 32'b0               ),
  .wb_oled_dma_sel_i      ( 4'b0                ),
  .wb_oled_dma_we_i       ( 1'b0                ),
  .wb_oled_dma_cyc_i      ( wb_c_oled_dma_cyc   ),
  .wb_oled_dma_stb_i      ( wb_c_oled_dma_stb   ),
  .wb_oled_dma_cti_i      ( 3'b0                ),
  .wb_oled_dma_bte_i      ( 2'b0                ),
  .wb_oled_dma_rdt_o      ( wb_c_oled_dma_rdat  ),
  .wb_oled_dma_ack_o      ( wb_c_oled_dma_ack   ),
  .wb_oled_dma_err_o      ( /* nc */            ),
  .wb_oled_dma_rty_o      ( /* nc */            ),
  //
  .wb_qspi_ram_rom_adr_o  ( wb_p_qspi_mem_adr   ),
  .wb_qspi_ram_rom_dat_o  ( wb_p_qspi_mem_wdat  ),
  .wb_qspi_ram_rom_sel_o  ( wb_p_qspi_mem_sel   ),
  .wb_qspi_ram_rom_we_o   ( wb_p_qspi_mem_we    ),
  .wb_qspi_ram_rom_cyc_o  ( wb_p_qspi_mem_cyc   ),
  .wb_qspi_ram_rom_stb_o  ( wb_p_qspi_mem_stb   ),
  .wb_qspi_ram_rom_cti_o  ( /* nc */            ),
  .wb_qspi_ram_rom_bte_o  ( /* nc */            ),
  .wb_qspi_ram_rom_rdt_i  ( wb_p_qspi_mem_rdat  ),
  .wb_qspi_ram_rom_ack_i  ( wb_p_qspi_mem_ack   ),
  .wb_qspi_ram_rom_err_i  ( 1'b0                ),
  .wb_qspi_ram_rom_rty_i  ( 1'b0                ),
  //
  .wb_ram_adr_o           ( wb_p_ram_adr        ),
  .wb_ram_dat_o           ( wb_p_ram_wdat       ),
  .wb_ram_sel_o           ( wb_p_ram_sel        ),
  .wb_ram_we_o            ( wb_p_ram_we         ),
  .wb_ram_cyc_o           ( wb_p_ram_cyc        ),
  .wb_ram_stb_o           ( wb_p_ram_stb        ),
  .wb_ram_cti_o           ( /* nc */            ),
  .wb_ram_bte_o           ( /* nc */            ),
  .wb_ram_rdt_i           ( wb_p_ram_rdat       ),
  .wb_ram_ack_i           ( wb_p_ram_ack        ),
  .wb_ram_err_i           ( 1'b0                ),
  .wb_ram_rty_i           ( 1'b0                ),
  //
  .wb_uart_adr_o          ( wb_p_uart_adr       ),
  .wb_uart_dat_o          ( wb_p_uart_wdat      ),
  .wb_uart_sel_o          ( wb_p_uart_sel       ),
  .wb_uart_we_o           ( wb_p_uart_we        ),
  .wb_uart_cyc_o          ( wb_p_uart_cyc       ),
  .wb_uart_stb_o          ( wb_p_uart_stb       ),
  .wb_uart_cti_o          ( /* nc */            ),
  .wb_uart_bte_o          ( /* nc */            ),
  .wb_uart_rdt_i          ( wb_p_uart_rdat      ),
  .wb_uart_ack_i          ( wb_p_uart_ack       ),
  .wb_uart_err_i          ( 1'b0                ),
  .wb_uart_rty_i          ( 1'b0                ),
  //
  .wb_spi_adr_o           ( wb_p_spi_adr        ),
  .wb_spi_dat_o           ( wb_p_spi_wdat       ),
  .wb_spi_sel_o           ( wb_p_spi_sel        ),
  .wb_spi_we_o            ( wb_p_spi_we         ),
  .wb_spi_cyc_o           ( wb_p_spi_cyc        ),
  .wb_spi_stb_o           ( wb_p_spi_stb        ),
  .wb_spi_cti_o           ( /* nc */            ),
  .wb_spi_bte_o           ( /* nc */            ),
  .wb_spi_rdt_i           ( wb_p_spi_rdat       ),
  .wb_spi_ack_i           ( wb_p_spi_ack        ),
  .wb_spi_err_i           ( 1'b0                ),
  .wb_spi_rty_i           ( 1'b0                ),
  //
  .wb_efspi_adr_o         ( wb_p_efspi_adr      ),
  .wb_efspi_dat_o         ( wb_p_efspi_wdat     ),
  .wb_efspi_sel_o         ( wb_p_efspi_sel      ),
  .wb_efspi_we_o          ( wb_p_efspi_we       ),
  .wb_efspi_cyc_o         ( wb_p_efspi_cyc      ),
  .wb_efspi_stb_o         ( wb_p_efspi_stb      ),
  .wb_efspi_cti_o         ( /* nc */            ),
  .wb_efspi_bte_o         ( /* nc */            ),
  .wb_efspi_rdt_i         ( wb_p_efspi_rdat     ),
  .wb_efspi_ack_i         ( wb_p_efspi_ack      ),
  .wb_efspi_err_i         ( 1'b0                ),
  .wb_efspi_rty_i         ( 1'b0                ),
  //
  .wb_csr_adr_o           ( wb_p_csr_adr        ),
  .wb_csr_dat_o           ( wb_p_csr_wdat       ),
  .wb_csr_sel_o           ( wb_p_csr_sel        ),
  .wb_csr_we_o            ( wb_p_csr_we         ),
  .wb_csr_cyc_o           ( wb_p_csr_cyc        ),
  .wb_csr_stb_o           ( wb_p_csr_stb        ),
  .wb_csr_cti_o           ( /* nc */            ),
  .wb_csr_bte_o           ( /* nc */            ),
  .wb_csr_rdt_i           ( wb_p_csr_rdat       ),
  .wb_csr_ack_i           ( wb_p_csr_ack        ),
  .wb_csr_err_i           ( 1'b0                ),
  .wb_csr_rty_i           ( 1'b0                ),
  //
  .wb_efxip_adr_o         ( wb_p_ef_xip_adr     ),
  .wb_efxip_dat_o         ( wb_p_ef_xip_wdat    ),
  .wb_efxip_sel_o         ( wb_p_ef_xip_sel     ),
  .wb_efxip_we_o          ( wb_p_ef_xip_we      ),
  .wb_efxip_cyc_o         ( wb_p_ef_xip_cyc     ),
  .wb_efxip_stb_o         ( wb_p_ef_xip_stb     ),
  .wb_efxip_cti_o         ( /* nc */            ),
  .wb_efxip_bte_o         ( /* nc */            ),
  .wb_efxip_rdt_i         ( wb_p_ef_xip_rdat    ),
  .wb_efxip_ack_i         ( wb_p_ef_xip_ack     ),
  .wb_efxip_err_i         ( 1'b0                ),
  .wb_efxip_rty_i         ( 1'b0                )
);
/* verilator lint_on PINCONNECTEMPTY */



endmodule