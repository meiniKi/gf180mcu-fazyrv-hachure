
module soc #(
  // TODO
  )(
  `ifdef USE_POWER_PINS
  inout wire VDD,
  inout wire VSS,
  `endif

  // QSPI XIP Memory
  output logic        qspi_mem_cs_ram_on,
  output logic        qspi_mem_cs_rom_on,
  output logic        qspi_mem_sck_o,
  input  logic [ 3:0] qspi_mem_sd_i,
  output logic [ 3:0] qspi_mem_sd_o,
  output logic [ 3:0] qspi_mem_oen_o,

  // UART
  output logic uart_tx_o,
  input  logic uart_rx_i,

  // OLED
  output logic spi_oled_sck_o,
  output logic spi_oled_sdo_o,

  // GPIO
  
);

// Clocks
logic clk_p;
logic clk_c_frv_1;
logic clk_c_frv_2;
logic clk_c_frv_4;
logic clk_c_frv_8;

// Resets
logic rst_p_n;
logic rst_c_frv_1_n;
logic rst_c_frv_2_n;
logic rst_c_frv_4_n;
logic rst_c_frv_8_n;

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

// QSPI Memory
logic        wb_p_qspi_mem_cyc;
logic        wb_p_qspi_mem_stb;
logic        wb_p_qspi_mem_ack;
logic        wb_p_qspi_mem_we;
logic [31:0] wb_p_qspi_mem_adr;
logic [31:0] wb_p_qspi_mem_wdat;
logic [31:0] wb_p_qspi_mem_rdat;
logic [ 3:0] wb_p_qspi_mem_sel;

// UART
logic        wb_p_uart_cyc;
logic        wb_p_uart_stb;
logic        wb_p_uart_ack;
logic        wb_p_uart_we;
logic [31:0] wb_p_uart_adr;
logic [31:0] wb_p_uart_wdat;
logic [31:0] wb_p_uart_rdat;
logic [ 3:0] wb_p_uart_sel;

// SPI
logic        wb_p_spi_cyc;
logic        wb_p_spi_stb;
logic        wb_p_spi_ack;
logic        wb_p_spi_we;
logic [31:0] wb_p_spi_adr;
logic [31:0] wb_p_spi_wdat;
logic [31:0] wb_p_spi_rdat;
logic [ 3:0] wb_p_spi_sel;

//                                                                             
// mmmmm                  "           #                           ""#          
// #   "#  mmm    m mm  mmm    mmmm   # mm    mmm    m mm   mmm     #     mmm  
// #mmm#" #"  #   #"  "   #    #" "#  #"  #  #"  #   #"  " "   #    #    #   " 
// #      #""""   #       #    #   #  #   #  #""""   #     m"""#    #     """m 
// #      "#mm"   #     mm#mm  ##m#"  #   #  "#mm"   #     "mm"#    "mm  "mmm" 
//                             #                                               
//                             "              
//##############################################################################    

                                                        
// m    m mmmmm  mmmmm          mmmm   mmmm  mmmmm  mmmmm 
//  #  #    #    #   "#        m"  "m #"   " #   "#   #   
//   ##     #    #mmm#"        #    # "#mmm  #mmm#"   #   
//  m""m    #    #             #    #     "# #        #   
// m"  "m mm#mm  #              #mm#" "mmm#" #      mm#mm 
//                                 #                      
                                                        
wb_qspi_mem i_wb_qspi_mem (
  .clk_i          ( clk_p   ),                                                                    
  .rst_in         ( rst_p_n ),
  // select mem before, one module to reduce area
  .sel_rom_ram_i  ( TODO    ),
  // wishbone
  .wb_mem_stb_i   ( wb_p_qspi_mem_stb & wb_qspi_mem_cyc ),
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
  .IRQ    ( TODO            ),  
  .rx     ( uart_rx_i       ),
  .tx     ( uart_tx_o       )
);

                     
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

  // spi config
  input  logic [3:0]  presc_i,
  input  logic [1:0]  size_i,
  input  logic        cpol_i,
  input  logic        auto_cs_i,
  output logic        rdy_o,
  // spi data
  output logic        spi_cs_o,
  output logic        spi_sck_o,
  output logic        spi_sdo_o,
  input  logic        spi_sdi_i
);

                            
//           mmmm  m      mmmmmm mmmm  
//          m"  "m #      #      #   "m
//          #    # #      #mmmmm #    #
//          #    # #      #      #    #
//           #mm#  #mmmmm #mmmmm #mmm" 
                            
                            
localparam MAX_SPI_LENGTH = 128*64/8;
localparam SPI_PREFETCH   = 0;

tiny_wb_dma_oled_spi #(
  .MAX_SPI_LENGTH ( MAX_SPI_LENGTH ),
  .PREFETCH       ( SPI_PREFETCH   ),
) i_tiny_wb_dma_oled_spi (
  .clk_i         ( clk_p   ),
  .rst_in        ( rst_p_n ),
  // memory access interface
  .wbm_spi_cyc_o ( wb_c_oled_dma_cyc  ),
  .wbm_spi_stb_o ( wb_c_oled_dma_stb  ),
  .wbm_spi_adr_o ( wb_c_oled_dma_adr  ),
  .wbm_spi_ack_i ( wb_c_oled_dma_ack  ),
  .wbm_spi_dat_i ( wb_c_oled_dma_rdat ),
  // control
  input  logic        start_i,
  input  logic [3:0]  presc_i,
  input  logic [31:0] spi_adr_i,
  input  logic        spi_inc_i,
  input  logic [$clog2(MAX_SPI_LENGTH+1)-1:0] size_i,
  output logic        rdy_o,
  // spi data
  output logic        spi_sck_o ( spi_oled_sck_o ),
  output logic        spi_sdo_o ( spi_oled_sdo_o )
);

                                        
// mmmmm    mm   m    m
// #   "#   ##   ##  ##
// #mmmm"  #  #  # ## #
// #   "m  #mm#  # "" #
// #    " #    # #    #
//                     
                                    
localparam RAM_DEPTH = 2048;     

wb_ram #( .DEPTH(RAM_DEPTH) ) i_wb_ram (
  .clk_i  ( clk_p   ),
  .rst_in ( rst_p_n ),
  // Wishbone
  .wb_stb_i ( wb_p_ram_stb  ),
  .wb_cyc_i ( wb_p_ram_cyc  ),
  .wb_we_i  ( wb_p_ram_we   ),
  .wb_ack_o ( wb_p_ram_ack  ),
  .wb_sel_i ( wb_p_ram_sel  ),
  .wb_dat_i ( wb_p_ram_wdat ),
  .wb_adr_i ( wb_p_ram_adr[$clog2(DEPTH/512+1)+1:2]), // word address
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
                                                                      

fazyrv_top #(
  .CHUNKSIZE ( 1        ),
  .CONF      ( "MIN"    ),
  .BOOTADR   ( h'10     ),
  .RFTYPE    ( "LOGIC"  )
) i_fazyrv_top_1 (
  .clk_i         ( clk_c_frv_1   ),
  .rst_in        ( rst_c_frv_1_n ),
  .tirq_i        ( 'b0           ),
  .trap_o        (               ),

  .wb_imem_stb_o ( wb_c_frv_1_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_1_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_1_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_1_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_1_imem_ack  ),

  .wb_dmem_cyc_o ( wb_c_frv_1_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_1_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_1_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_1_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_1_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_1_dmem_wdat ),
  .wb_dmem_adr_o ( wb_c_frv_1_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_1_dmem_rdat ),
);

fazyrv_top #(
  .CHUNKSIZE ( 2        ),
  .CONF      ( "MIN"    ),
  .BOOTADR   ( h'20     ),
  .RFTYPE    ( "LOGIC"  )
) i_fazyrv_top_2 (
  .clk_i         ( clk_c_frv_2   ),
  .rst_in        ( rst_c_frv_2_n ),
  .tirq_i        ( 'b0           ),
  .trap_o        (               ),

  .wb_imem_stb_o ( wb_c_frv_2_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_2_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_2_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_2_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_2_imem_ack  ),

  .wb_dmem_cyc_o ( wb_c_frv_2_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_2_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_2_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_2_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_2_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_2_dmem_wdat ),
  .wb_dmem_adr_o ( wb_c_frv_2_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_2_dmem_rdat ),
);


fazyrv_top #(
  .CHUNKSIZE ( 4        ),
  .CONF      ( "MIN"    ),
  .BOOTADR   ( h'30     ),
  .RFTYPE    ( "LOGIC"  )
) i_fazyrv_top_4 (
  .clk_i         ( clk_c_frv_4   ),
  .rst_in        ( rst_c_frv_4_n ),
  .tirq_i        ( 'b0           ),
  .trap_o        (               ),

  .wb_imem_stb_o ( wb_c_frv_4_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_4_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_4_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_4_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_4_imem_ack  ),

  .wb_dmem_cyc_o ( wb_c_frv_4_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_4_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_4_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_4_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_4_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_4_dmem_wdat ),
  .wb_dmem_adr_o ( wb_c_frv_4_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_4_dmem_rdat ),
);


fazyrv_top #(
  .CHUNKSIZE ( 8        ),
  .CONF      ( "MIN"    ),
  .BOOTADR   ( h'40     ),
  .RFTYPE    ( "LOGIC"  )
) i_fazyrv_top_8 (
  .clk_i         ( clk_c_frv_8   ),
  .rst_in        ( rst_c_frv_8_n ),
  .tirq_i        ( 'b0           ),
  .trap_o        (               ),

  .wb_imem_stb_o ( wb_c_frv_8_imem_stb  ),
  .wb_imem_cyc_o ( wb_c_frv_8_imem_cyc  ),
  .wb_imem_adr_o ( wb_c_frv_8_imem_adr  ),
  .wb_imem_dat_i ( wb_c_frv_8_imem_rdat ),
  .wb_imem_ack_i ( wb_c_frv_8_imem_ack  ),

  .wb_dmem_cyc_o ( wb_c_frv_8_dmem_cyc  ),
  .wb_dmem_stb_o ( wb_c_frv_8_dmem_stb  ),
  .wb_dmem_we_o  ( wb_c_frv_8_dmem_we   ),
  .wb_dmem_ack_i ( wb_c_frv_8_dmem_ack  ),
  .wb_dmem_be_o  ( wb_c_frv_8_dmem_be   ),
  .wb_dmem_dat_i ( wb_c_frv_8_dmem_wdat ),
  .wb_dmem_adr_o ( wb_c_frv_8_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_8_dmem_rdat ),
);


                                                        
// mmmmm           m                                      
//   #    m mm   mm#mm   mmm    m mm   mmm    mmm   m mm  
//   #    #"  #    #    #"  #   #"  " #"  "  #" "#  #"  # 
//   #    #   #    #    #""""   #     #      #   #  #   # 
// mm#mm  #   #    "mm  "#mm"   #     "#mm"  "#m#"  #   # 
//                                                      
//#########################################################                                                      



endmodule