
module globefish_soc (
  `ifdef USE_POWER_PINS
  inout  wire         VDD,
  inout  wire         VSS,
  `endif
  input  logic        clk_i,
  input  logic        rst_in,
  // Enables
  input  logic        en_p_i,
  input  logic        en_wb_i,
  input  logic        en_frv1_i,
  input  logic        en_frv2_i,
  input  logic        en_frv4_i,
  input  logic        en_frv8_i,
  // QSPI XIP Memory
  output logic        qspi_mem_cs_ram_on,
  output logic        qspi_mem_cs_rom_on,
  output logic        qspi_mem_sck_o,
  input  logic [ 3:0] qspi_mem_sd_i,
  output logic [ 3:0] qspi_mem_sd_o,
  output logic [ 3:0] qspi_mem_oen_o,
  // UART
  output logic        uart_tx_o,
  input  logic        uart_rx_i,
  // OLED
  output logic        spi_oled_sck_o,
  output logic        spi_oled_sdo_o,
  // GPIO
  input  logic [ 7:0] gpi_i,
  output logic [ 7:0] gpo_o,
  output logic [ 7:0] gpeo_o,
  // SPI
  output logic        spi_cs_o,
  output logic        spi_sck_o,
  output logic        spi_sdo_o,
  input  logic        spi_sdi_i
);

                                   
// mmmmm    mm   mmmmm    mm   m    m
// #   "#   ##   #   "#   ##   ##  ##
// #mmm#"  #  #  #mmmm"  #  #  # ## #
// #       #mm#  #   "m  #mm#  # "" #
// #      #    # #    " #    # #    #
//
//####################################                                 
                                   

localparam MAX_SPI_LENGTH = 2048*64/8;
// Note: 14-bit address hard-coded in CSR bitfield

localparam SPI_PREFETCH   = 0;

// Clocks
logic clk_p;
logic clk_wb;
logic clk_c_frv_1;
logic clk_c_frv_2;
logic clk_c_frv_4;
logic clk_c_frv_8;

// Resets
logic rst_p_n;
logic rst_wb_n;
logic rst_c_frv_1_n;
logic rst_c_frv_2_n;
logic rst_c_frv_4_n;
logic rst_c_frv_8_n;

                     
// mmmmm           m             mmm           mmm  ""#    #     
// #   "#  mmm   mm#mm          #            m"   "   #    #   m 
// #mmmm" #   "    #            ##           #        #    # m"  
// #   "m  """m    #           #  #m#        #        #    #"#   
// #    " "mmm"    "mm         "#mm#m         "mmm"   "mm  #  "m 
//
//################################################################                                                             
                                                               

assign rst_p_n        = rst_in;
assign rst_wb_n       = rst_in;
assign rst_c_frv_1_n  = rst_in; 
assign rst_c_frv_2_n  = rst_in; 
assign rst_c_frv_4_n  = rst_in; 
assign rst_c_frv_8_n  = rst_in; 


`ifdef NO_CLOCK_GATES_TODO
localparam N_CLOCKS = 6;

logic [N_CLOCKS-1:0] cg_enables;
logic [N_CLOCKS-1:0] cg_clks;

assign cg_enables = {en_p_i, en_wb_i, en_frv1_i, en_frv2_i, en_frv4_i, en_frv8_i};
assign {clk_p, clk_wb, clk_c_frv_1, clk_c_frv_2, clk_c_frv_4, clk_c_frv_8} cg_clks;

genvar i;
generate
  for (i = 0; i < N_CLOCKS; i = i + 1) begin : i_cg
    gf180mcu_fd_sc_mcu7t5v0__icgtp_1 i_cg ( 
      `ifdef USE_POWER_PINS
      .VDD  ( VDD           ),
      .VSS  ( VSS           ),
      `endif
      .TE   ( 1'b0          ),
      .E    ( cg_enables[i] ),
      .CLK  ( clk_i         ),
      .Q    ( cg_clks[i]    )
    );
  end
endgenerate

`else
  assign clk_p       = clk_i & en_p_i;
  assign clk_wb      = clk_i & en_wb_i;
  assign clk_c_frv_1 = clk_i & en_frv1_i;
  assign clk_c_frv_2 = clk_i & en_frv2_i;
  assign clk_c_frv_4 = clk_i & en_frv4_i;
  assign clk_c_frv_8 = clk_i & en_frv8_i;
`endif

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

assign wb_c_frv_1_cyc  = wb_c_frv_1_imem_cyc | wb_c_frv_1_dmem_cyc;
assign wb_c_frv_1_stb  = wb_c_frv_1_imem_stb | wb_c_frv_1_dmem_stb;
assign wb_c_frv_1_be   = wb_c_frv_1_imem_stb ? 4'b1111 : wb_c_frv_1_dmem_be;
assign wb_c_frv_1_adr  = wb_c_frv_1_imem_stb ? wb_c_frv_1_imem_adr : wb_c_frv_1_dmem_adr;
assign wb_c_frv_1_we   = wb_c_frv_1_dmem_stb & wb_c_frv_1_dmem_we;
assign wb_c_frv_1_wdat = wb_c_frv_1_dmem_wdat;

assign wb_c_frv_1_imem_ack  = wb_c_frv_1_ack;
assign wb_c_frv_1_dmem_ack  = wb_c_frv_1_ack;
assign wb_c_frv_1_imem_rdat = wb_c_frv_1_rdat;
assign wb_c_frv_1_dmem_rdat = wb_c_frv_1_rdat;


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

assign wb_c_frv_2_cyc  = wb_c_frv_2_imem_cyc | wb_c_frv_2_dmem_cyc;
assign wb_c_frv_2_stb  = wb_c_frv_2_imem_stb | wb_c_frv_2_dmem_stb;
assign wb_c_frv_2_be   = wb_c_frv_2_imem_stb ? 4'b1111 : wb_c_frv_2_dmem_be;
assign wb_c_frv_2_adr  = wb_c_frv_2_imem_stb ? wb_c_frv_2_imem_adr : wb_c_frv_2_dmem_adr;
assign wb_c_frv_2_we   = wb_c_frv_2_dmem_stb & wb_c_frv_2_dmem_we;
assign wb_c_frv_2_wdat = wb_c_frv_2_dmem_wdat;

assign wb_c_frv_2_imem_ack  = wb_c_frv_2_ack;
assign wb_c_frv_2_dmem_ack  = wb_c_frv_2_ack;
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

assign wb_c_frv_4_cyc  = wb_c_frv_4_imem_cyc | wb_c_frv_4_dmem_cyc;
assign wb_c_frv_4_stb  = wb_c_frv_4_imem_stb | wb_c_frv_4_dmem_stb;
assign wb_c_frv_4_be   = wb_c_frv_4_imem_stb ? 4'b1111 : wb_c_frv_4_dmem_be;
assign wb_c_frv_4_adr  = wb_c_frv_4_imem_stb ? wb_c_frv_4_imem_adr : wb_c_frv_4_dmem_adr;
assign wb_c_frv_4_we   = wb_c_frv_4_dmem_stb & wb_c_frv_4_dmem_we;
assign wb_c_frv_4_wdat = wb_c_frv_4_dmem_wdat;

assign wb_c_frv_4_imem_ack  = wb_c_frv_4_ack;
assign wb_c_frv_4_dmem_ack  = wb_c_frv_4_ack;
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

assign wb_c_frv_8_cyc  = wb_c_frv_8_imem_cyc | wb_c_frv_8_dmem_cyc;
assign wb_c_frv_8_stb  = wb_c_frv_8_imem_stb | wb_c_frv_8_dmem_stb;
assign wb_c_frv_8_be   = wb_c_frv_8_imem_stb ? 4'b1111 : wb_c_frv_8_dmem_be;
assign wb_c_frv_8_adr  = wb_c_frv_8_imem_stb ? wb_c_frv_8_imem_adr : wb_c_frv_8_dmem_adr;
assign wb_c_frv_8_we   = wb_c_frv_8_dmem_stb & wb_c_frv_8_dmem_we;
assign wb_c_frv_8_wdat = wb_c_frv_8_dmem_wdat;

assign wb_c_frv_8_imem_ack  = wb_c_frv_8_ack;
assign wb_c_frv_8_dmem_ack  = wb_c_frv_8_ack;
assign wb_c_frv_8_imem_rdat = wb_c_frv_8_rdat;
assign wb_c_frv_8_dmem_rdat = wb_c_frv_8_rdat;

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

// !! TODO CSR for these !! 
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

// UART
logic        wb_p_uart_cyc;
logic        wb_p_uart_stb;
logic        wb_p_uart_ack;
logic        wb_p_uart_we;
logic [31:0] wb_p_uart_adr;
logic [31:0] wb_p_uart_wdat;
logic [31:0] wb_p_uart_rdat;
logic [ 3:0] wb_p_uart_sel;



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
                                                                                                                                                          

CSR #(
  .USE_STALL ( 0 )
) i_CSR (
  .i_clk                ( clk_p               ),
  .i_rst_n              ( rst_p_n             ),
  .i_wb_cyc             ( wb_p_csr_cyc        ),
  .i_wb_stb             ( wb_p_csr_stb        ),
  .o_wb_stall           ( /* nc */            ),
  .i_wb_adr             ( wb_p_csr_adr[4:0]   ),
  .i_wb_we              ( wb_p_csr_we         ),
  .i_wb_dat             ( wb_p_csr_wdat       ),
  .i_wb_sel             ( wb_p_csr_sel        ),
  .o_wb_ack             ( wb_p_csr_ack        ),
  .o_wb_err             ( /* nc */            ),
  .o_wb_rty             ( /* nc */            ),
  .o_wb_dat             ( wb_p_csr_rdat       ),
  .i_GPI_gpi            ( gpi_i               ),
  .o_GPO_gpo            ( gpo_o               ),
  .o_GPOE_gpoe          ( gpeo_o              ),
  .o_SPI_Conf_presc     ( spi_presc           ),
  .o_SPI_Conf_cpol      ( spi_cpol            ),
  .o_SPI_Conf_auto_cs   ( spi_auto_cs         ),
  .o_SPI_Conf_size      ( spi_size            ),
  .o_OLED_Start_Status_start_rdy ( oled_rdy   ),
  .i_OLED_Start_Status_start_rdy ( oled_start ),
  .o_OLED_Conf_presc    ( oled_presc          ),
  .o_OLED_Conf_inc      ( oled_spi_inc        ),
  .o_OLED_Conf_size     ( oled_size           ),
  .o_OLED_Dma_addr      ( oled_spi_adr        )
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
  .sel_rom_ram_i  ( wb_p_qspi_mem_adr[28]   ),
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
  .wb_adr_i ( wb_p_ram_adr[$clog2(RAM_DEPTH/512+1)+1:2]), // word address
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
  .clk_i         ( clk_c_frv_1   ),
  .rst_in        ( rst_c_frv_1_n ),
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
  .wb_dmem_dat_i ( wb_c_frv_1_dmem_wdat ),
  .wb_dmem_adr_o ( wb_c_frv_1_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_1_dmem_rdat ),
);


// TODO: Just one controller for now
//
assign wb_c_frv_2_imem_stb  = 'b0; 
assign wb_c_frv_2_imem_cyc  = 'b0;
assign wb_c_frv_2_imem_adr  = 'b0;
assign wb_c_frv_2_dmem_cyc  = 'b0;
assign wb_c_frv_2_dmem_stb  = 'b0;
assign wb_c_frv_2_dmem_we   = 'b0;
assign wb_c_frv_2_dmem_be   = 'b0;
assign wb_c_frv_2_dmem_adr  = 'b0;
assign wb_c_frv_2_dmem_rdat = 'b0;

assign wb_c_frv_4_imem_stb  = 'b0; 
assign wb_c_frv_4_imem_cyc  = 'b0;
assign wb_c_frv_4_imem_adr  = 'b0;
assign wb_c_frv_4_dmem_cyc  = 'b0;
assign wb_c_frv_4_dmem_stb  = 'b0;
assign wb_c_frv_4_dmem_we   = 'b0;
assign wb_c_frv_4_dmem_be   = 'b0;
assign wb_c_frv_4_dmem_adr  = 'b0;
assign wb_c_frv_4_dmem_rdat = 'b0;

assign wb_c_frv_8_imem_stb  = 'b0; 
assign wb_c_frv_8_imem_cyc  = 'b0;
assign wb_c_frv_8_imem_adr  = 'b0;
assign wb_c_frv_8_dmem_cyc  = 'b0;
assign wb_c_frv_8_dmem_stb  = 'b0;
assign wb_c_frv_8_dmem_we   = 'b0;
assign wb_c_frv_8_dmem_be   = 'b0;
assign wb_c_frv_8_dmem_adr  = 'b0;
assign wb_c_frv_8_dmem_rdat = 'b0;

/*
frv_2 i_frv_2 (
  .clk_i         ( clk_c_frv_2   ),
  .rst_in        ( rst_c_frv_2_n ),
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
  .wb_dmem_dat_i ( wb_c_frv_2_dmem_wdat ),
  .wb_dmem_adr_o ( wb_c_frv_2_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_2_dmem_rdat ),
);

frv_4 i_frv_4 (
  .clk_i         ( clk_c_frv_4   ),
  .rst_in        ( rst_c_frv_4_n ),
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
  .wb_dmem_dat_i ( wb_c_frv_4_dmem_wdat ),
  .wb_dmem_adr_o ( wb_c_frv_4_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_4_dmem_rdat ),
);

frv_8 i_frv_8 (
  .clk_i         ( clk_c_frv_8   ),
  .rst_in        ( rst_c_frv_8_n ),
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
  .wb_dmem_dat_i ( wb_c_frv_8_dmem_wdat ),
  .wb_dmem_adr_o ( wb_c_frv_8_dmem_adr  ),
  .wb_dmem_dat_o ( wb_c_frv_8_dmem_rdat ),
);
*/
                                                        
// mmmmm           m                                      
//   #    m mm   mm#mm   mmm    m mm   mmm    mmm   m mm  
//   #    #"  #    #    #"  #   #"  " #"  "  #" "#  #"  # 
//   #    #   #    #    #""""   #     #      #   #  #   # 
// mm#mm  #   #    "mm  "#mm"   #     "#mm"  "#m#"  #   # 
//                                                      
//#########################################################                                                      


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
  .wb_fazyrv1_cti_i       ( 'b0                 ),
  .wb_fazyrv1_bte_i       ( 'b0                 ),
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
  .wb_fazyrv2_cti_i       ( 'b0                 ),
  .wb_fazyrv2_bte_i       ( 'b0                 ),
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
  .wb_fazyrv4_cti_i       ( 'b0                 ),
  .wb_fazyrv4_bte_i       ( 'b0                 ),
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
  .wb_fazyrv8_cti_i       ( 'b0                 ),
  .wb_fazyrv8_bte_i       ( 'b0                 ),
  .wb_fazyrv8_rdt_o       ( wb_c_frv_8_rdat     ),
  .wb_fazyrv8_ack_o       ( wb_c_frv_8_ack      ),
  .wb_fazyrv8_err_o       ( /* nc */            ),
  .wb_fazyrv8_rty_o       ( /* nc */            ),
  //
  .wb_oled_dma_adr_i      ( wb_c_oled_dma_adr   ),
  .wb_oled_dma_dat_i      ( 'b0                 ),
  .wb_oled_dma_sel_i      ( 'b0                 ),
  .wb_oled_dma_we_i       ( 'b0                 ),
  .wb_oled_dma_cyc_i      ( wb_c_oled_dma_cyc   ),
  .wb_oled_dma_stb_i      ( wb_c_oled_dma_stb   ),
  .wb_oled_dma_cti_i      ( 'b0                 ),
  .wb_oled_dma_bte_i      ( 'b0                 ),
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
  .wb_qspi_ram_rom_err_i  ( 'b0                 ),
  .wb_qspi_ram_rom_rty_i  ( 'b0                 ),
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
  .wb_ram_err_i           ( 'b0                 ),
  .wb_ram_rty_i           ( 'b0                 ),
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
  .wb_uart_err_i          ( 'b0                 ),
  .wb_uart_rty_i          ( 'b0                 ),
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
  .wb_spi_err_i           ( 'b0                 ),
  .wb_spi_rty_i           ( 'b0                 ),
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
  .wb_csr_err_i           ( 'b0                 ),
  .wb_csr_rty_i           ( 'b0                 )
);














endmodule