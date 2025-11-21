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
  
  input  wire clk,       // clock
  input  wire rst_n,     // reset (active low)
  
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

//  m     m   "                        
//  #  #  # mmm     m mm   mmm    mmm  
//  " #"# #   #     #"  " #"  #  #   " 
//   ## ##"   #     #     #""""   """m 
//   #   #  mm#mm   #     "#mm"  "mmm" 

logic         en_p;
logic         en_p2;
logic         en_wb;
logic         en_frv1;
logic         en_frv2;
logic         en_frv4;
logic         en_frv8;
logic         en_frv4ccx;

logic         qspi_mem_cs_ram_n;
logic         qspi_mem_cs_rom_n;
logic         qspi_mem_sck;
logic [ 3:0]  qspi_mem_sdi;
logic [ 3:0]  qspi_mem_sdo;
logic [ 3:0]  qspi_mem_oen;

logic         xip_cs_n;
logic         xip_sck;
logic [ 3:0]  xip_sdi;
logic [ 3:0]  xip_sdo;
logic [ 3:0]  xip_oen;

logic         uart_tx;
logic         uart_rx;

logic         spi_oled_sck;
logic         spi_oled_sdo;

logic [ 3:0]  gpi;
logic [ 3:0]  gpo;
logic [ 3:0]  gpeo;
logic [ 3:0]  gpcs;
logic [ 3:0]  gpsl;
logic [ 3:0]  gppu;
logic [ 3:0]  gppd;

logic         spi_cs;
logic         spi_sck;
logic         spi_sdo;
logic         spi_sdi;

logic         efspi_cs;
logic         efspi_sck;
logic         efspi_sdo;
logic         efspi_sdi;

logic [ 3:0]  ccx4_rs_a;
logic [ 3:0]  ccx4_rs_b;
logic [ 3:0]  ccx4_res;
logic [ 1:0]  ccx4_sel;
logic         ccx4_req;
logic         ccx4_resp;
                    
//  m    m              
//  ##  ##  mmm   mmmm  
//  # ## # "   #  #" "# 
//  # "" # m"""#  #   # 
//  #    # "mm"#  ##m#" 
//                #
//                "

       
// ### SPI OLED: bidir_PAD[1:0]
// ########################################

assign bidir_oe[1:0]    = '1;  // output
assign bidir_cs[1:0]    = '0;  // dont care; cmos buffer 
assign bidir_sl[1:0]    = '1;  // fast slew rate
assign bidir_ie[1:0]    = '0;  // input disable
assign bidir_pu[1:0]    = '0;  // no pull
assign bidir_pd[1:0]    = '0;  // no pull
//assign bidir_in[1:0] dont care
assign bidir_out[1:0]   = {spi_oled_sdo, spi_oled_sck};


// ### Enables: input_PAD[7:0]
// ################################

assign input_pu[7:0] = '0;
assign input_pd[7:0] = '1;
assign {en_frv4ccx, en_frv8, en_frv4, en_frv2, en_frv1, en_p2, en_p, en_wb} = input_in[7:0];


// ### CCX: bidir_PAD[12:2], input_PAD[12:8]
// ########################################

//  - ccx4_sel
assign bidir_oe[ 3: 2]  = '1;  // output
assign bidir_cs[ 3: 2]  = '0;  // dont care; cmos buffer 
assign bidir_sl[ 3: 2]  = '1;  // fast slew rate
assign bidir_ie[ 3: 2]  = '0;  // input disable
assign bidir_pu[ 3: 2]  = '0;  // no pull
assign bidir_pd[ 3: 2]  = '0;  // no pull
//assign bidir_in[ 3: 2] dont care
assign bidir_out[3: 2]  = ccx4_sel;

//  - ccx4_req
assign bidir_oe[4]      = '1;  // output
assign bidir_cs[4]      = '0;  // dont care; cmos buffer 
assign bidir_sl[4]      = '1;  // fast slew rate
assign bidir_ie[4]      = '0;  // input disable
assign bidir_pu[4]      = '0;  // no pull
assign bidir_pd[4]      = '0;  // no pull
//assign bidir_in[4] dont care
assign bidir_out[4]     = ccx4_req;

//  - ccx4_resp
assign input_pu[8]      = '0; // no pull
assign input_pd[8]      = '0; // no pull
assign ccx4_resp        = input_in[8];

//  - ccx4_rs_a
assign bidir_oe[ 8: 5]  = '1;  // output
assign bidir_cs[ 8: 5]  = '0;  // dont care; cmos buffer 
assign bidir_sl[ 8: 5]  = '1;  // fast slew rate
assign bidir_ie[ 8: 5]  = '0;  // input disable
assign bidir_pu[ 8: 5]  = '0;  // no pull
assign bidir_pd[ 8: 5]  = '0;  // no pull
//assign bidir_in[ 8: 5] dont care
assign bidir_out[ 8: 5] = ccx4_rs_a;

//  - ccx4_rs_b
assign bidir_oe[12: 9]  = '1;  // output
assign bidir_cs[12: 9]  = '0;  // dont care; cmos buffer 
assign bidir_sl[12: 9]  = '1;  // fast slew rate
assign bidir_ie[12: 9]  = '0;  // input disable
assign bidir_pu[12: 9]  = '0;  // no pull
assign bidir_pd[12: 9]  = '0;  // no pull
//assign bidir_in[12: 9] dont care
assign bidir_out[12: 9] = ccx4_rs_b;

//  - ccx4_res
assign input_pu[12: 9]  = '0; // no pull
assign input_pd[12: 9]  = '0; // no pull
assign ccx4_res         = input_in[12:9];


// ### GPIO: bidir_PAD[16:13]
// ########################################

assign bidir_oe[16:13] = gpeo;  // prog. output enable
assign bidir_cs[16:13] = gpcs;  // prog. type
assign bidir_sl[16:13] = gpsl;  // prog. slew rate
assign bidir_ie[16:13] = '1;    // alway input enable
assign bidir_pu[16:13] = gppu;  // prog. pull up
assign bidir_pd[16:13] = gppd;  // prog. pull down

assign gpi = bidir_in[16:13];
assign bidir_out[16:13] = gpo;


// ### UART: bidir_PAD[17], input_PAD[13]
// ########################################

// - tx
assign bidir_oe[17]    = '1;  // output
assign bidir_cs[17]    = '0;  // dont care; cmos buffer 
assign bidir_sl[17]    = '1;  // fast slew rate
assign bidir_ie[17]    = '0;  // input disable
assign bidir_pu[17]    = '0;  // no pull
assign bidir_pd[17]    = '0;  // no pull
//assign bidir_in[17] dont care
assign bidir_out[17]   = uart_tx;

// - rx
assign input_pu[13]    = '1;  // pull up
assign input_pd[13]    = '0;  // no pull down
assign uart_rx         = input_in[13];


// ### SPI: bidir_PAD[20:18], input_PAD[14]
// ########################################

// - cs, sck, sdo
assign bidir_oe[20:18]   = '1;  // output
assign bidir_cs[20:18]   = '0;  // dont care; cmos buffer 
assign bidir_sl[20:18]   = '1;  // fast slew rate
assign bidir_ie[20:18]   = '0;  // input disable
assign bidir_pu[20:18]   = '0;  // no pull
assign bidir_pd[20:18]   = '0;  // no pull
//assign bidir_in[20:18] dont care
assign bidir_out[20:18]  = {spi_sdo, spi_sck, spi_cs};

// - sdi
assign input_pu[14]      = '0;  // np pull up
assign input_pd[14]      = '0;  // no pull down
assign spi_sdi           = input_in[14];


// ### EF_SPI: bidir_PAD[23:21], input_PAD[15]
// ########################################

// - cs, sck, sdo
assign bidir_oe[23:21]   = '1;  // output
assign bidir_cs[23:21]   = '0;  // dont care; cmos buffer 
assign bidir_sl[23:21]   = '1;  // fast slew rate
assign bidir_ie[23:21]   = '0;  // input disable
assign bidir_pu[23:21]   = '0;  // no pull
assign bidir_pd[23:21]   = '0;  // no pull
//assign bidir_in[23:21] dont care
assign bidir_out[23:21]  = {efspi_sdo, efspi_sck, efspi_cs};

// - sdi
assign input_pu[15]      = '0;  // np pull up
assign input_pd[15]      = '0;  // no pull down
assign efspi_sdi         = input_in[15];


// ### XIP: bidir_PAD[29:24]
// ########################################

//  - xip_cs_n 
assign bidir_oe[24]   = '1;  // output
assign bidir_cs[24]   = '0;  // dont care; cmos buffer 
assign bidir_sl[24]   = '1;  // fast slew rate
assign bidir_ie[24]   = '0;  // input disable
assign bidir_pu[24]   = '0;  // no pull
assign bidir_pd[24]   = '0;  // no pull
//assign bidir_in[24] dont care
assign bidir_out[24]  = xip_cs_n;

//  - xip_sck
assign bidir_oe[25]   = '1;  // output
assign bidir_cs[25]   = '0;  // dont care; cmos buffer 
assign bidir_sl[25]   = '1;  // fast slew rate
assign bidir_ie[25]   = '0;  // input disable
assign bidir_pu[25]   = '0;  // no pull
assign bidir_pd[25]   = '0;  // no pull
//assign bidir_in[25] dont care
assign bidir_out[25]  = xip_sck;

//  - xip_sd i/o
assign bidir_cs[29:26] = '0;  // cmos buffer 
assign bidir_sl[29:26] = '1;  // fast slew rate
assign bidir_pu[29:26] = '0;  // no pull
assign bidir_pd[29:26] = '0;  // no pull

assign bidir_ie[29:26]  = ~xip_oen;         // input: ~output
assign bidir_oe[29:26]  = xip_oen;          // output enable
assign bidir_out[29:26] = xip_sdo;          // output data
assign xip_sdi          = bidir_in[29:26];  // input data


// ### QSPI XIP Memory: bidir_PAD[36:30]
// ########################################

//  - cs_mem 
assign bidir_oe[31:30]  = '1;  // output
assign bidir_cs[31:30]  = '0;  // dont care; cmos buffer 
assign bidir_sl[31:30]  = '1;  // fast slew rate
assign bidir_ie[31:30]  = '0;  // input disable
assign bidir_pu[31:30]  = '0;  // no pull
assign bidir_pd[31:30]  = '0;  // no pull
//assign bidir_in[31:30] dont care
assign bidir_out[31:30] = {qspi_mem_cs_ram_n, qspi_mem_cs_rom_n};

//  - qspi_mem_sck
assign bidir_oe[32]     = '1;  // output
assign bidir_cs[32]     = '0;  // dont care; cmos buffer 
assign bidir_sl[32]     = '1;  // fast slew rate
assign bidir_ie[32]     = '0;  // input disable
assign bidir_pu[32]     = '0;  // no pull
assign bidir_pd[32]     = '0;  // no pull
//assign bidir_in[32] dont care
assign bidir_out[32]    = qspi_mem_sck;

//  - qspi_mem_sd i/o
assign bidir_cs[36:33]  = '0;  // cmos buffer 
assign bidir_sl[36:33]  = '1;  // fast slew rate
assign bidir_pu[36:33]  = '0;  // no pull
assign bidir_pd[36:33]  = '0;  // no pull

assign bidir_ie[36:33]  = ~qspi_mem_oen; // input: ~output
assign bidir_oe[36:33]  = qspi_mem_oen;  // output enable
assign bidir_out[36:33] = qspi_mem_sdo;  // output data
assign qspi_mem_sdi     = bidir_in[36:33];  // input data




//        ""#           #               m""    "           #     
//  mmmm    #     mmm   #mmm    mmm   mm#mm  mmm     mmm   # mm  
// #" "#    #    #" "#  #" "#  #"  #    #      #    #   "  #"  # 
// #   #    #    #   #  #   #  #""""    #      #     """m  #   # 
// "#m"#    "mm  "#m#"  ##m#"  "#mm"    #    mm#mm  "mmm"  #   # 
//  m  #                                                         
//   ""                                                          

hachure_soc i_hachure_soc (
  `ifdef USE_POWER_PINS
  .VDD                ( VDD               ),
  .VSS                ( VSS               ),
  `endif
  .clk_i              ( clk               ),
  .rst_in             ( rst_n             ),
  // Enables
  .en_p_i             ( en_p              ),
  .en_wb_i            ( en_wb             ),
  .en_p2_i            ( en_p2             ),
  .en_frv1_i          ( en_frv1           ),
  .en_frv2_i          ( en_frv2           ),
  .en_frv4_i          ( en_frv4           ),
  .en_frv8_i          ( en_frv8           ),
  .en_frv4ccx_i       ( en_frv4ccx        ),
  // QSPI XIP Memory
  .qspi_mem_cs_ram_on ( qspi_mem_cs_ram_n ),
  .qspi_mem_cs_rom_on ( qspi_mem_cs_rom_n ),
  .qspi_mem_sck_o     ( qspi_mem_sck      ),
  .qspi_mem_sd_i      ( qspi_mem_sdi      ),
  .qspi_mem_sd_o      ( qspi_mem_sdo      ),
  .qspi_mem_oen_o     ( qspi_mem_oen      ),
  // FazyRV CCX
  .ccx4_rs_a_o        ( ccx4_rs_a         ),
  .ccx4_rs_b_o        ( ccx4_rs_b         ),
  .ccx4_res_i         ( ccx4_res          ),
  .ccx4_sel_o         ( ccx4_sel          ),
  .ccx4_req_o         ( ccx4_req          ),
  .ccx4_resp_i        ( ccx4_resp         ),
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
  .gpcs_o             ( gpcs              ),
  .gpsl_o             ( gpsl              ),
  .gppu_o             ( gppu              ),
  .gppd_o             ( gppd              ),
  // SPI
  .spi_cs_o           ( spi_cs            ),
  .spi_sck_o          ( spi_sck           ),
  .spi_sdo_o          ( spi_sdo           ),
  .spi_sdi_i          ( spi_sdi           ),
  // EF SPI
  .efspi_cs_o         ( efspi_cs           ),
  .efspi_sck_o        ( efspi_sck          ),
  .efspi_sdo_o        ( efspi_sdo          ),
  .efspi_sdi_i        ( efspi_sdi          ),
  //
  .xip_cs_on          ( xip_cs_n          ),
  .xip_sck_o          ( xip_sck           ),
  .xip_sd_i           ( xip_sdi           ),
  .xip_sd_o           ( xip_sdo           ),
  .xip_oen_o          ( xip_oen           )
);


endmodule

`default_nettype wire
