// Copyright (c) 2025 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  reset_sync.sv
// Usage :  Synchronizes a reset signal to the pos edge
//
// Ports
//  - clk_i             Clock input
//  - async_reset_on    Async reset input, low active
//  - sync_reset_on     Sync reset ouput, low active
// -----------------------------------------------------------------------------


module reset_sync (
  input  logic clk_i,
  input  logic async_reset_on,
  output logic sync_reset_on
);

logic sync_ff1_r, sync_ff2_r, sync_ff3_r;

always_ff @(posedge clk_i or negedge async_reset_on) begin
  if (~async_reset_on) begin
    sync_ff1_r <= 1'b0;
    sync_ff2_r <= 1'b0;
    sync_ff3_r <= 1'b0;
  end else begin
    sync_ff1_r <= 1'b1;
    sync_ff2_r <= sync_ff1_r;
    sync_ff3_r <= sync_ff2_r;
  end
end

assign sync_reset_on = sync_ff3_r;

endmodule
