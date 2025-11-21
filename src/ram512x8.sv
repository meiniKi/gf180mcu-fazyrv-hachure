// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  ram512x8.sv
// Usage :  Wrapper for the 8-bit wide gf180mcu_fd_ip_sram__sram512x8m8wm1 RAM. 
//
// Ports
//  - clk_i   Clock input
//  - wen_i   Write enable, high active.
//  - adr_i   Address input
//  - dat_i   Write data input
//  - dat_o   Read data output 
// -----------------------------------------------------------------------------

module ram512x8 (
  `ifdef USE_POWER_PINS
  inout  wire         VDD,
  inout  wire         VSS,
  `endif
  input  logic        clk_i,
  input  logic        cen_i,
  input  logic        wen_i,
  input  logic [8:0]  adr_i,
  input  logic [7:0]  dat_i,
  output logic [7:0]  dat_o
);

`ifndef SIM
  (* keep *)
  gf180mcu_fd_ip_sram__sram512x8m8wm1 sram_0 (
    `ifdef USE_POWER_PINS
    .VDD  ( VDD     ),
    .VSS  ( VSS     ),
    `endif
    .CLK  ( clk_i   ),
    .CEN  ( cen_i   ),
    .GWEN ( ~wen_i  ),
    .WEN  ( 8'b0    ),
    .A    ( adr_i   ),
    .D    ( dat_i   ),
    .Q    ( dat_o   )
  );

`else

  logic [7:0] mem_r [0:511];

  always @(posedge clk_i) begin
    dat_o <= mem_r[adr_i];
    if (wen) begin
      mem_r[adr_i] <= dat_i;
    end
  end

`endif

endmodule