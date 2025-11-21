
// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  chip_top_tb.sv
// Usage :  Testbench for the hachure SoC at top level
// -----------------------------------------------------------------------------

`timescale 1ns/1ps
`default_nettype none

module chip_top_tb;

localparam RAMSIZE = 1024*1024*16;

wire clk;
wire rst_n;

// Enables
//
wire en_p;
wire en_p2;
wire en_wb;
wire en_frv1;
wire en_frv2;
wire en_frv4;
wire en_frv8;
wire en_frv4ccx;

// UART
//
wire uart_tx;
wire uart_rx;

// Oled Display
//
wire oled_spi_sdo;
wire oled_spi_sck;

// GPIO
//
wire  [ 3:0] gpio;

// SPI
//
wire spi_cs;
wire spi_sck;
wire spi_sdo;
wire spi_sdi;

// EF SPI
//
wire efspi_cs;
wire efspi_sck;
wire efspi_sdo;
wire efspi_sdi;

// CCX
wire [ 3:0] ccx4_rs_a;
wire [ 3:0] ccx4_rs_b;
wire [ 3:0] ccx4_res;
wire [ 1:0] ccx4_sel;
wire        ccx4_req;
wire        ccx4_resp;

`ifdef USE_POWER_PINS
wire VDD;
wire VSS;
`endif

// XIP (secondary)
wire       xip_cs_n;
wire       xip_sck;
wire [3:0] xip_sdi;
wire [3:0] xip_sdo;
wire [3:0] xip_oen;

wire [3:0] xip_sdio;

// QSPI
wire       mem_cs_ram_n;
wire       mem_cs_rom_n;
wire       mem_sck;
wire [3:0] mem_sdio;

                              
//   mmm  #        "                 mmmmmmm              
// m"   " # mm   mmm    mmmm            #     mmm   mmmm  
// #      #"  #    #    #" "#           #    #" "#  #" "# 
// #      #   #    #    #   #           #    #   #  #   # 
//  "mmm" #   #  mm#mm  ##m#"           #    "#m#"  ##m#" 
//                      #                           #     
//                      "                           "                       

chip_top i_chip_top (
  `ifdef USE_POWER_PINS
  .VDD        ( VDD           ),
  .VSS        ( VSS           ),
  `endif
  .clk_PAD    ( clk           ),
  .rst_n_PAD  ( rst_n         ),
  .input_PAD  ( { efspi_sdi,
                  spi_sdi,
                  uart_rx,
                  ccx4_res[3],
                  ccx4_res[2],
                  ccx4_res[1],
                  ccx4_res[0],
                  ccx4_resp,
                  en_frv4ccx,
                  en_frv8,
                  en_frv4,
                  en_frv2,
                  en_frv1,
                  en_p2,
                  en_p,
                  en_wb}),
  .bidir_PAD  ( { mem_sdio[3],
                  mem_sdio[2],
                  mem_sdio[1],
                  mem_sdio[0],
                  mem_sck,
                  mem_cs_ram_n,
                  mem_cs_rom_n,
                  xip_sdio[3],
                  xip_sdio[2],
                  xip_sdio[1],
                  xip_sdio[0],
                  xip_sck,
                  xip_cs_n,
                  efspi_sdo,
                  efspi_sck,
                  efspi_cs,
                  spi_sdo,
                  spi_sck,
                  spi_cs,
                  uart_tx,
                  gpio[3],
                  gpio[2],
                  gpio[1],
                  gpio[0],
                  ccx4_rs_b[3],
                  ccx4_rs_b[2],
                  ccx4_rs_b[1],
                  ccx4_rs_b[0],
                  ccx4_rs_a[3],
                  ccx4_rs_a[2],
                  ccx4_rs_a[1],
                  ccx4_rs_a[0],
                  ccx4_req,
                  ccx4_sel[1],
                  ccx4_sel[0],
                  oled_spi_sdo,
                  oled_spi_sck} ),
  .analog_PAD ( /* nc */        )
);


// mmmmmm ""#                  #     
// #        #     mmm    mmm   # mm  
// #mmmmm   #    "   #  #   "  #"  # 
// #        #    m"""#   """m  #   # 
// #        "mm  "mm"#  "mmm"  #   # 
                                   
spiflash i_spiflash (
  .csb ( mem_cs_rom_n ),
  .clk ( mem_sck      ),
  .io0 ( mem_sdio[0]  ),
  .io1 ( mem_sdio[1]  ),
  .io2 ( mem_sdio[2]  ),
  .io3 ( mem_sdio[3]  )
);

spiflash i_spiflash_2 (
  .csb ( xip_cs_n     ),
  .clk ( xip_sck      ),
  .io0 ( xip_sdio[0]  ),
  .io1 ( xip_sdio[1]  ),
  .io2 ( xip_sdio[2]  ),
  .io3 ( xip_sdio[3]  )
);

                                   
// mmmmm   mmmm  mmmmm    mm   m    m
// #   "# #"   " #   "#   ##   ##  ##
// #mmm#" "#mmm  #mmmm"  #  #  # ## #
// #          "# #   "m  #mm#  # "" #
// #      "mmm#" #    " #    # #    #

qspi_psram #( .DEPTH(RAMSIZE) ) i_qspi_psram (
  .sck_i    ( mem_sck       ),
  .cs_in    ( mem_cs_ram_n  ),
  .io0_io   ( mem_sdio[0]   ),
  .io1_io   ( mem_sdio[1]   ),
  .io2_io   ( mem_sdio[2]   ),
  .io3_io   ( mem_sdio[3]   )
);

initial begin
  $dumpfile("chip_top_tb.fst");
  $dumpvars(0, chip_top_tb);
end


endmodule