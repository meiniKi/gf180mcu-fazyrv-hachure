// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  frv_4ccx.sv
// Usage :  Wrapper for frv_4ccx macro hardening.
// -----------------------------------------------------------------------------


module frv_4ccx (
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
  output logic [31:0] wb_dmem_dat_o,

  output logic [3:0]  ccx_rs_a_o,
  output logic [3:0]  ccx_rs_b_o,
  input  logic [3:0]  ccx_res_i,
  output logic [1:0]  ccx_sel_o,
  output logic        ccx_req_o,
  input  logic        ccx_resp_i
);

localparam CHUNKSIZE = 4;
localparam CONF      = "MIN";
localparam BOOTADR   = 'h60;
localparam RFTYPE    = "LOGIC";

fazyrv_top #(
  .CHUNKSIZE ( CHUNKSIZE  ),
  .CONF      ( CONF       ),
  .BOOTADR   ( BOOTADR    ),
  .RFTYPE    ( RFTYPE     )
) i_fazyrv_top_4ccx (
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