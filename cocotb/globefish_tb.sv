
// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  globefish_tb.sv
// Usage :  Testbench for the globefish SoC
// -----------------------------------------------------------------------------

`timescale 1ns/1ps
`default_nettype none

module globefish_tb;

localparam RAMSIZE = 1024*1024*16;

logic clk;
logic rst_n;

// Enables
//
logic en_p;
logic en_wb;
logic en_frv1;
logic en_frv2;
logic en_frv4;
logic en_frv8;

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
logic [7:0] gpi;
logic [7:0] gpo;
logic [7:0] gpoen;

// SPI
//
logic spi_cs;
logic spi_sck;
logic spi_sdo;
logic spi_sdi;

`ifdef USE_POWER_PINS
logic VDD;
logic VSS;
`endif

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


globefish_soc i_globefish_soc (
  `ifdef USE_POWER_PINS
  .VDD                ( VDD             ),
  .VSS                ( VSS             ),
  `endif
  .clk_i              ( clk             ),
  .rst_in             ( rst_n           ),
  // Enables
  .en_p_i             ( en_p            ),
  .en_wb_i            ( en_wb           ),
  .en_frv1_i          ( en_frv1         ),
  .en_frv2_i          ( en_frv2         ),
  .en_frv4_i          ( en_frv4         ),
  .en_frv8_i          ( en_frv8         ),
  // QSPI XIP Memory
  .qspi_mem_cs_ram_on ( mem_cs_ram_n    ),
  .qspi_mem_cs_rom_on ( mem_cs_rom_n    ),
  .qspi_mem_sck_o     ( mem_sck         ),
  .qspi_mem_sd_i      ( mem_sdio        ),
  .qspi_mem_sd_o      ( mem_core_sdo    ),
  .qspi_mem_oen_o     ( mem_core_sdoen  ),
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
  // SPI
  .spi_cs_o           ( spi_cs          ),
  .spi_sck_o          ( spi_sck         ),
  .spi_sdo_o          ( spi_sdo         ),
  .spi_sdi_i          ( spi_sdi         )
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
  $dumpfile("globefish_tb.fst");
  $dumpvars(0, globefish_tb);
end


endmodule