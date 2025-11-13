// SPDX-FileCopyrightText: © 2025 Meinhard Kissich
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

module chip_core #(
  parameter NUM_INPUT_PADS,
  parameter NUM_BIDIR_PADS,
  parameter NUM_ANALOG_PADS
  )(
  `ifdef USE_POWER_PINS
  inout wire VDD,
  inout wire VSS,
  `endif
  
  input  logic clk,       // clock
  input  logic rst_n,     // reset (active low)
  
  input  wire [NUM_INPUT_PADS-1:0] input_in,   // Input value
  output wire [NUM_INPUT_PADS-1:0] input_pu,   // Pull-up
  output wire [NUM_INPUT_PADS-1:0] input_pd,   // Pull-down

  input  wire [NUM_BIDIR_PADS-1:0] bidir_in,   // Input value
  output wire [NUM_BIDIR_PADS-1:0] bidir_out,  // Output value
  output wire [NUM_BIDIR_PADS-1:0] bidir_oe,   // Output enable
  output wire [NUM_BIDIR_PADS-1:0] bidir_cs,   // Input type (0=CMOS Buffer, 1=Schmitt Trigger)
  output wire [NUM_BIDIR_PADS-1:0] bidir_sl,   // Slew rate (0=fast, 1=slow)
  output wire [NUM_BIDIR_PADS-1:0] bidir_ie,   // Input enable
  output wire [NUM_BIDIR_PADS-1:0] bidir_pu,   // Pull-up
  output wire [NUM_BIDIR_PADS-1:0] bidir_pd,   // Pull-down

  inout  wire [NUM_ANALOG_PADS-1:0] analog  // Analog
);

// See here for usage: https://gf180mcu-pdk.readthedocs.io/en/latest/IPs/IO/gf180mcu_fd_io/digital.html

TODO
assign input_pu[5:0] = '0;
assign input_pd[5:0] = '1;
// Set the bidir as output
assign bidir_oe = '1;
assign bidir_cs = '0;
assign bidir_sl = '0;
assign bidir_ie = ~bidir_oe;
assign bidir_pu = '0;
assign bidir_pd = '0;

                                   
//  m     m   "                        
//  #  #  # mmm     m mm   mmm    mmm  
//  " #"# #   #     #"  " #"  #  #   " 
//   ## ##"   #     #     #""""   """m 
//   #   #  mm#mm   #     "#mm"  "mmm" 

logic         en_p;
logic         en_wb;
logic         en_frv1;
logic         en_frv2;
logic         en_frv4;
logic         en_frv8;

logic         qspi_mem_cs_ram_n;
logic         qspi_mem_cs_rom_n;
logic         qspi_mem_sck;
logic [ 3:0]  qspi_mem_sdi;
logic [ 3:0]  qspi_mem_sdo;
logic [ 3:0]  qspi_mem_oen;

logic         uart_tx;
logic         uart_rx;

logic         spi_oled_sck;
logic         spi_oled_sdo;

logic [ 7:0]  gpi;
logic [ 7:0]  gpo;
logic [ 7:0]  gpeo;

logic         spi_cs;
logic         spi_sck;
logic         spi_sdo;
logic         spi_sdi;

                     
//  m    m              
//  ##  ##  mmm   mmmm  
//  # ## # "   #  #" "# 
//  # "" # m"""#  #   # 
//  #    # "mm"#  ##m#" 
//                #
//                "

// ### Enables: NUM_INPUT_PADS[5:0]
// ################################

assign input_pu[5:0] = '0;
assign input_pd[5:0] = '1;
assign {en_frv8, en_frv4, en_frv2, en_frv1, en_p, en_wb} = input_in[5:0];

// ### QSPI XIP Memory: NUM_BIDIR_PADS[6:0]
// ########################################

//  - cs_comr 
assign bidir_oe[1:0]  = '1;  // output
assign bidir_cs[1:0]  = '0;  // dont care; cmos buffer 
assign bidir_sl[1:0]  = '1;  // fast slew rate
assign bidir_ie[1:0]  = '0;  // input disable
assign bidir_pu[1:0]  = '0;  // no pull
assign bidir_pd[1:0]  = '0;  // no pull

//assign bidir_in[1:0] dont care
assign bidir_out[1:0] = {qspi_mem_cs_ram_n, qspi_mem_cs_rom_n};

//  - qspi_mem_sck
assign bidir_oe[2]    = '1;  // output
assign bidir_cs[2]    = '0;  // dont care; cmos buffer 
assign bidir_sl[2]    = '1;  // fast slew rate
assign bidir_ie[2]    = '0;  // input disable
assign bidir_pu[2]    = '0;  // no pull
assign bidir_pd[2]    = '0;  // no pull

//assign bidir_in[2] dont care
assign bidir_out[2]   = qspi_mem_sck;

//  - qspi_mem_sd i/o
assign bidir_cs[6:3]  = '0;  // cmos buffer 
assign bidir_sl[6:3]  = '1;  // fast slew rate
assign bidir_pu[6:3]  = '0;  // no pull
assign bidir_pd[6:3]  = '0;  // no pull

assign bidir_ie[6:3]  = ~qspi_mem_oen; // input: ~output
assign bidir_oe[6:3]  = qspi_mem_oen;  // output enable
assign bidir_out[6:3] = qspi_mem_sdo;  // output data
assign qspi_mem_sdi   = bidir_in[6:3];  // input data

// ### UART: NUM_BIDIR_PADS[8:7]
// ########################################

// - tx
assign bidir_oe[7]    = '1;  // output
assign bidir_cs[7]    = '0;  // dont care; cmos buffer 
assign bidir_sl[7]    = '1;  // fast slew rate
assign bidir_ie[7]    = '0;  // input disable
assign bidir_pu[7]    = '0;  // no pull
assign bidir_pd[7]    = '0;  // no pull

//assign bidir_in[7] dont care
assign bidir_out[7]   = uart_tx;

// - rx
assign bidir_oe[7]    = '0;  // input
assign bidir_cs[7]    = '0;  // cmos buffer 
assign bidir_sl[7]    = '1;  // fast slew rate
assign bidir_ie[7]    = '1;  // input enable
assign bidir_pu[7]    = '1;  // pull up
assign bidir_pd[7]    = '0;  // no pull

assign uart_rx        = bidir_in[7];
assign bidir_out[7]   = '1;  // don't care; 1

// ### SPI OLED: NUM_BIDIR_PADS[10:9]
// ########################################

assign bidir_oe[10:9]    = '1;  // output
assign bidir_cs[10:9]    = '0;  // dont care; cmos buffer 
assign bidir_sl[10:9]    = '1;  // fast slew rate
assign bidir_ie[10:9]    = '0;  // input disable
assign bidir_pu[10:9]    = '0;  // no pull
assign bidir_pd[10:9]    = '0;  // no pull

//assign bidir_in[10:9] dont care
assign bidir_out[10:9]   = {spi_oled_sdo, spi_oled_sck};

// ### SPI: NUM_BIDIR_PADS[14:11]
// ########################################

// - cs, sck, sdo
assign bidir_oe[13:11]   = '1;  // output
assign bidir_cs[13:11]   = '0;  // dont care; cmos buffer 
assign bidir_sl[13:11]   = '1;  // fast slew rate
assign bidir_ie[13:11]   = '0;  // input disable
assign bidir_pu[13:11]   = '0;  // no pull
assign bidir_pd[13:11]   = '0;  // no pull

//assign bidir_in[13:11] dont care
assign bidir_out[13:11]  = {spi_sdo, spi_sck, spi_cs};

// - sdi
assign bidir_oe[14]      = '0;  // input
assign bidir_cs[14]      = '0;  // cmos buffer 
assign bidir_sl[14]      = '1;  // fast slew rate
assign bidir_ie[14]      = '1;  // input enable
assign bidir_pu[14]      = '1;  // pull up
assign bidir_pd[14]      = '0;  // no pull

assign spi_sdi           = bidir_in[14];
assign bidir_out[14]     = '1;  // don't care; 1






//        ""#           #               m""    "           #     
//  mmmm    #     mmm   #mmm    mmm   mm#mm  mmm     mmm   # mm  
// #" "#    #    #" "#  #" "#  #"  #    #      #    #   "  #"  # 
// #   #    #    #   #  #   #  #""""    #      #     """m  #   # 
// "#m"#    "mm  "#m#"  ##m#"  "#mm"    #    mm#mm  "mmm"  #   # 
//  m  #                                                         
//   ""                                                          

globefish_soc i_globefish_soc (
  `ifdef USE_POWER_PINS
  .VDD                ( VDD               ),
  .VSS                ( VSS               ),
  `endif
  .clk_i              ( clk               ),
  .rst_in             ( rst_n             ),
  // Enables
  .en_p_i             ( en_p              ),
  .en_wb_i            ( en_wb             ),
  .en_frv1_i          ( en_frv1           ),
  .en_frv2_i          ( en_frv2           ),
  .en_frv4_i          ( en_frv4           ),
  .en_frv8_i          ( en_frv8           ),
  // QSPI XIP Memory
  .qspi_mem_cs_ram_on ( qspi_mem_cs_ram_n ),
  .qspi_mem_cs_rom_on ( qspi_mem_cs_rom_n ),
  .qspi_mem_sck_o     ( qspi_mem_sck      ),
  .qspi_mem_sd_i      ( qspi_mem_sdi      ),
  .qspi_mem_sd_o      ( qspi_mem_sdo      ),
  .qspi_mem_oen_o     ( qspi_mem_oen      ),
  // UART
  .uart_tx_o          ( uart_tx           ),
  .uart_rx_i          ( uart_rx           ),
  // OLED
  .spi_oled_sck_o     ( spi_oled_sck      ),
  .spi_oled_sdo_o     ( spi_oled_sdo      ),
  // GPIO
  .gpi_i              ( gpi               ),
  .gpo_o              ( gpo               ),
  .gpeo_o             ( gpeo              ),
  // SPI
  .spi_cs_o           ( spi_cs            ),
  .spi_sck_o          ( spi_sck           ),
  .spi_sdo_o          ( spi_sdo           ),
  .spi_sdi_i          ( spi_sdi           )
);

endmodule

`default_nettype wire
