// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  frv_4.sv
// Usage :  Wrapper for frv1 macro hardening.
// -----------------------------------------------------------------------------


module frv_4 (
  input  logic        clk_i,
  input  logic        rst_in,

  output logic        wb_imem_stb_o,
  output logic        wb_imem_cyc_o,
  output logic [31:0] wb_imem_adr_o,
  input  logic [31:0] wb_imem_dat_i,
  input  logic        wb_imem_ack_i,

  output logic        wb_dmem_cyc_o,
  output logic        wb_dmem_stb_o,
  output logic        wb_dmem_we_o,
  input  logic        wb_dmem_ack_i,
  output logic [3:0]  wb_dmem_be_o,
  input  logic [31:0] wb_dmem_dat_i,
  output logic [31:0] wb_dmem_adr_o,
  output logic [31:0] wb_dmem_dat_o
);

localparam CHUNKSIZE = 4;
localparam CONF      = "MIN";
localparam BOOTADR   = 'h30;
localparam RFTYPE    = "LOGIC";

fazyrv_top #(
  .CHUNKSIZE ( CHUNKSIZE  ),
  .CONF      ( CONF       ),
  .BOOTADR   ( BOOTADR    ),
  .RFTYPE    ( RFTYPE     )
) i_fazyrv_top_4 (
  .clk_i         ( clk_i    ),
  .rst_in        ( rst_in   ),
  .tirq_i        ( 1'b0     ),
  .trap_o        ( /* nc */ ),

  .wb_imem_stb_o ( wb_imem_stb_o  ),
  .wb_imem_cyc_o ( wb_imem_cyc_o  ),
  .wb_imem_adr_o ( wb_imem_adr_o  ),
  .wb_imem_dat_i ( wb_imem_dat_i  ),
  .wb_imem_ack_i ( wb_imem_ack_i  ),

  .wb_dmem_cyc_o ( wb_dmem_cyc_o  ),
  .wb_dmem_stb_o ( wb_dmem_stb_o  ),
  .wb_dmem_we_o  ( wb_dmem_we_o   ),
  .wb_dmem_ack_i ( wb_dmem_ack_i  ),
  .wb_dmem_be_o  ( wb_dmem_be_o   ),
  .wb_dmem_dat_i ( wb_dmem_dat_i  ),
  .wb_dmem_adr_o ( wb_dmem_adr_o  ),
  .wb_dmem_dat_o ( wb_dmem_dat_o  )
);

endmodule