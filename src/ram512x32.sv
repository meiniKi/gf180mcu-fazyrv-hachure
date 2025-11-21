// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  ram512x312.sv
// Usage :  Wrapper for the 8-bit wide gf180mcu_fd_ip_sram__sram512x8m8wm1 RAM. 
//
// Ports
//  - clk_i   Clock input
//  - wen_i   Write enable, high active.
//  - sel_i   Select byte to write.
//  - adr_i   Address input
//  - dat_i   Write data input
//  - dat_o   Read data output 
// -----------------------------------------------------------------------------

module ram512x32 (
  `ifdef USE_POWER_PINS
  inout  wire          VDD,
  inout  wire          VSS,
  `endif
  input  logic         clk_i,
  input  logic         cen_i,
  input  logic         wen_i,
  input  logic [ 3:0]  sel_i,
  input  logic [ 8:0]  adr_i,
  input  logic [31:0]  dat_i,
  output logic [31:0]  dat_o
);

genvar i;
generate
  for (i = 0; i < 4; i = i + 1) begin : gen_ram8
    ram512x8 u_ram (
      `ifdef USE_POWER_PINS
        .VDD( VDD              ),
        .VSS( VSS              ),
      `endif
      .clk_i( clk_i            ),
      .cen_i( cen_i            ),
      .wen_i( wen_i & sel_i[i] ),
      .adr_i( adr_i            ),
      .dat_i( dat_i[8*i+7:8*i] ),
      .dat_o( dat_o[8*i+7:8*i] )
    );
  end
endgenerate

endmodule