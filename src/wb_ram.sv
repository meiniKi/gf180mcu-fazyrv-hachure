// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  wb_ram.sv
// Usage :  Wishbone wrapper for RAM primitives
//
// Ports
//  - clk_i     Clock input
//  - rst_in    Reset low active
//
//  - wb_stb_i  Wishbone interface
//  - wb_cyc_i
//  - wb_we_i
//  - wb_ack_o
//  - wb_sel_i
//  - wb_dat_i
//  - wb_adr_i  <- word address
//  - wb_dat_o
// -----------------------------------------------------------------------------

module wb_ram #(
  parameter DEPTH=1024
) (
  `ifdef USE_POWER_PINS
  inout  wire                           VDD,
  inout  wire                           VSS,
  `endif
  input  logic                          clk_i,
  input  logic                          rst_in,
  // wishbone
  input  logic                          wb_stb_i,
  input  logic                          wb_cyc_i,
  input  logic                          wb_we_i,
  output logic                          wb_ack_o,
  input  logic [3:0]                    wb_sel_i,
  input  logic [31:0]                   wb_dat_i,
  input  logic [$clog2(DEPTH/512)+8:0]  wb_adr_i, // word address
  output logic [31:0]                   wb_dat_o
);

localparam int NR_INSTANCES = (DEPTH + 511) / 512;
localparam int BANK_SEL_BITS = $clog2(NR_INSTANCES);

logic [31:0]              wb_rdat_bank [0:NR_INSTANCES-1];
logic [NR_INSTANCES-1:0]  wb_we_bank;

assign wb_we_bank = (wb_cyc_i & wb_stb_i & wb_we_i) ?
                    (1'b1 << wb_adr_i[9 + BANK_SEL_BITS - 1 : 9]) :
                    '0;

assign wb_dat_o = wb_rdat_bank[wb_adr_i[9 + BANK_SEL_BITS - 1 : 9]];

// Memory macros
genvar i;
generate
  for (i = 0; i < NR_INSTANCES; i++) begin : gen_ram_bank
    ram512x32 i_ram512x32 (
      `ifdef USE_POWER_PINS
      .VDD   ( VDD ),
      .VSS   ( VSS ),
      `endif
      .clk_i ( clk_i            ),
      .cen_i ( ~rst_in          ),
      .wen_i ( wb_we_bank[i]    ),
      .sel_i ( wb_sel_i         ),
      .adr_i ( wb_adr_i[8:0]    ),
      .dat_i ( wb_dat_i         ),
      .dat_o ( wb_rdat_bank[i]  )
    );
  end
endgenerate

// Wishbone logic
//
logic wb_ack_r;

always_ff @(posedge clk_i) begin
  if (~rst_in) begin
    wb_ack_r <= 1'b0;
  end else begin
    wb_ack_r <= wb_cyc_i & wb_stb_i;
  end
end

assign wb_ack_o = wb_ack_r;

endmodule