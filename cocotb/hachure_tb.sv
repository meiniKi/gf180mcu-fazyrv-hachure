
// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  hachure_tb.sv
// Usage :  Testbench for the hachure SoC
// -----------------------------------------------------------------------------

`timescale 1ns/1ps
`default_nettype none

module hachure_tb;

localparam RAMSIZE = 1024*1024*16;

logic clk;
logic rst_n;

// Enables
//
logic en_p;
logic en_p2;
logic en_wb;
logic en_frv1;
logic en_frv2;
logic en_frv4;
logic en_frv8;
logic en_frv4ccx;

// UART
//
logic uart_tx;
logic uart_rx;

// Oled Display
//
logic oled_spi_sdo;
logic oled_spi_sck;

// GPIO
//
logic [ 3:0] gpi;
logic [ 3:0] gpo;
logic [ 3:0] gpoen;
logic [ 3:0] gpcs;
logic [ 3:0] gpsl;
logic [ 3:0] gppu;
logic [ 3:0] gppd;

// SPI
//
logic spi_cs;
logic spi_sck;
logic spi_sdo;
logic spi_sdi;

// EF SPI
//
logic efspi_cs;
logic efspi_sck;
logic efspi_sdo;
logic efspi_sdi;

// CCX
logic [ 3:0] ccx4_rs_a;
logic [ 3:0] ccx4_rs_b;
logic [ 3:0] ccx4_res;
logic [ 1:0] ccx4_sel;
logic        ccx4_req;
logic        ccx4_resp;

`ifdef USE_POWER_PINS
logic VDD;
logic VSS;
`endif

// XIP (secondary)
logic       xip_cs_n;
logic       xip_sck;
logic [3:0] xip_sdi;
logic [3:0] xip_sdo;
logic [3:0] xip_oen;

// QSPI
logic       mem_cs_ram_n;
logic       mem_cs_rom_n;
logic       mem_sck;
logic [3:0] mem_core_sdo;
logic [3:0] mem_core_sdoen;

wire  [3:0] mem_sdio;

assign mem_sdio[0] = mem_core_sdoen[0] ? mem_core_sdo[0] : 1'bz;
assign mem_sdio[1] = mem_core_sdoen[1] ? mem_core_sdo[1] : 1'bz;
assign mem_sdio[2] = mem_core_sdoen[2] ? mem_core_sdo[2] : 1'bz;
assign mem_sdio[3] = mem_core_sdoen[3] ? mem_core_sdo[3] : 1'bz;

                     
//  mmmm           mmm 
// #"   "  mmm   m"   "
// "#mmm  #" "#  #     
//     "# #   #  #     
// "mmm#" "#m#"   "mmm"                   


hachure_soc i_hachure_soc (
  `ifdef USE_POWER_PINS
  .VDD                ( VDD             ),
  .VSS                ( VSS             ),
  `endif
  .clk_i              ( clk             ),
  .rst_in             ( rst_n           ),
  // Enables
  .en_p_i             ( en_p            ),
  .en_p2_i            ( en_p2           ),
  .en_wb_i            ( en_wb           ),
  .en_frv1_i          ( en_frv1         ),
  .en_frv2_i          ( en_frv2         ),
  .en_frv4_i          ( en_frv4         ),
  .en_frv8_i          ( en_frv8         ),
  .en_frv4ccx_i       ( en_frv4ccx      ),
  // QSPI XIP Memory
  .qspi_mem_cs_ram_on ( mem_cs_ram_n    ),
  .qspi_mem_cs_rom_on ( mem_cs_rom_n    ),
  .qspi_mem_sck_o     ( mem_sck         ),
  .qspi_mem_sd_i      ( mem_sdio        ),
  .qspi_mem_sd_o      ( mem_core_sdo    ),
  .qspi_mem_oen_o     ( mem_core_sdoen  ),
  // FazyRV CCX
  .ccx4_rs_a_o        ( ccx4_rs_a       ),
  .ccx4_rs_b_o        ( ccx4_rs_b       ),
  .ccx4_res_i         ( ccx4_res        ),
  .ccx4_sel_o         ( ccx4_sel        ),
  .ccx4_req_o         ( ccx4_req        ),
  .ccx4_resp_i        ( ccx4_resp       ),
  // UART
  .uart_tx_o          ( uart_tx         ),
  .uart_rx_i          ( uart_rx         ),
  // OLED
  .spi_oled_sck_o     ( oled_spi_sck    ),
  .spi_oled_sdo_o     ( oled_spi_sdo    ),
  // GPIO
  .gpi_i              ( gpi             ),
  .gpo_o              ( gpo             ),
  .gpeo_o             ( gpoen           ),
  .gpcs_o             ( gpcs            ),
  .gpsl_o             ( gpsl            ),
  .gppu_o             ( gppu            ),
  .gppd_o             ( gppd            ),
  // SPI
  .spi_cs_o           ( spi_cs          ),
  .spi_sck_o          ( spi_sck         ),
  .spi_sdo_o          ( spi_sdo         ),
  .spi_sdi_i          ( spi_sdi         ),
  // EF SPI
  .efspi_cs_o         ( efspi_cs        ),
  .efspi_sck_o        ( efspi_sck       ),
  .efspi_sdo_o        ( efspi_sdo       ),
  .efspi_sdi_i        ( efspi_sdi       ),
  // XIP
  .xip_cs_on          ( xip_cs_n        ),
  .xip_sck_o          ( xip_sck         ),
  .xip_sd_i           ( xip_sdi         ),
  .xip_sd_o           ( xip_sdo         ),
  .xip_oen_o          ( xip_oen         )
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
  $dumpfile("hachure_tb.fst");
  $dumpvars(0, hachure_tb);
end


endmodule