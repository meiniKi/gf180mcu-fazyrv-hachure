// Copyright (c) 2024 Meinhard Kissich
// SPDX-License-Identifier: MIT
// -----------------------------------------------------------------------------
// File  :  tiny_wb_dma_oled_spi.sv
// Usage :  A minimal DMA SPI module for SSD1306 OLED displays.
//
// Ports
//  - clk_i         Clock input.
//  - rst_in        Reset, low active.
//  - wbm_spi_cyc_o
//  - wbm_spi_stb_o
//  - wbm_spi_ack_i
//  - wbm_spi_dat_i
//  - presc_i       Spi prescaler.
//  - size_i        Spi rx/tx size in bytes.
//  - spi_inc_i     Increment SPI address after each word, or fetch same word.
//  - rdy_o         Spi is ready.
//  - spi_sck_o     Spi phy SCK.
//  - spi_sdo_o     Spi phy SDO.
//
// Limitations:
//  - Address must be word-aligned
//  - Prefetch must be acknowledges while the other buffer is clocked to the OLED.
//    OK for Fazy: no subsequent accesses, max access length < 16 cycles
//  - Control inputs must remain constant while the SPI transfer is active
//  - spi_inc_i still increments within one word to save some area
// -----------------------------------------------------------------------------

module tiny_wb_dma_oled_spi #(
  parameter MAX_SPI_LENGTH  = 128*64/8,
  parameter PREFETCH        = 1
) (
  input  logic        rst_in,
  input  logic        clk_i,
  // memory access interface
  output logic        wbm_spi_cyc_o,
  output logic        wbm_spi_stb_o,
  output logic [31:0] wbm_spi_adr_o,
  input  logic        wbm_spi_ack_i,
  input  logic [31:0] wbm_spi_dat_i,
  // control
  input  logic        start_i,
  input  logic [3:0]  presc_i,
  input  logic [31:0] spi_adr_i,
  input  logic        spi_inc_i,
  input  logic [$clog2(MAX_SPI_LENGTH+1)-1:0] size_i,
  output logic        rdy_o,
  // spi data
  output logic        spi_sck_o,
  output logic        spi_sdo_o
);

localparam CPOL = 0;

// When using QSPI RAM: consider caching for sequential read

logic sel_tx_r, sel_tx_n;
logic pref_done_r, pref_done_n;

logic [31:0] dat_tx_r[0:1];
logic [31:0] dat_tx_n[0:1];

logic [6:0] cnt_hbit_r,  cnt_hbit_n;
logic [6:0] cnt_presc_r, cnt_presc_n;
logic [$clog2(MAX_SPI_LENGTH+1)-3:0] cnt_word_r, cnt_word_n;

logic sck_r;
logic tick;
logic done;
logic wbm_stb;

logic full_word_left;
assign full_word_left = (size_i[$clog2(MAX_SPI_LENGTH+1)-1:2] > cnt_word_r);

logic last_transmit;
assign last_transmit = ({cnt_word_r, 2'b0} >= size_i);

enum int unsigned { IDLE, FETCH, SEND } state_r, state_n;

assign rdy_o        = (state_r == IDLE);
assign spi_sck_o    = sck_r;
assign spi_sdo_o    = dat_tx_r[sel_tx_r][31];

assign tick         = (~|cnt_presc_r);
assign done         = (state_r == SEND) & (state_n != SEND);

assign wbm_spi_adr_o  = spi_inc_i ? spi_adr_i + {{(32-$clog2(MAX_SPI_LENGTH+1)){1'b0}}, cnt_word_r, 2'b0} :
                                    spi_adr_i;
assign wbm_spi_stb_o  = wbm_stb;
assign wbm_spi_cyc_o  = wbm_stb;

always_comb begin
  dat_tx_n[0]   = dat_tx_r[0];
  dat_tx_n[1]   = dat_tx_r[1];
  cnt_hbit_n    = cnt_hbit_r;
  state_n       = state_r;
  cnt_presc_n   = cnt_presc_r - 'b1;
  wbm_stb       = 1'b0;
  cnt_word_n    = cnt_word_r;
  sel_tx_n      = sel_tx_r;
  pref_done_n   = pref_done_r;

  case(state_r)
    IDLE: begin
      if (start_i) begin
        state_n     = FETCH;
        cnt_presc_n = {presc_i, 3'b0};
        cnt_word_n  = 'b0;
      end
    end
    // ---
    FETCH: begin
      wbm_stb     = 1'b1;
      cnt_presc_n = {presc_i, 3'b0};
      if (wbm_spi_ack_i) begin
        dat_tx_n[0] = {wbm_spi_dat_i[7:0], wbm_spi_dat_i[15:8], wbm_spi_dat_i[23:16], wbm_spi_dat_i[31:24]};
        state_n     = SEND;
        cnt_word_n  = cnt_word_r + 'b1;
        pref_done_n = ~PREFETCH;
        if (full_word_left) cnt_hbit_n  = 7'b100_0000; 
        else                cnt_hbit_n  = {1'b0, size_i[1:0], 4'b0};
      end
    end
    // ---
    SEND: begin
      wbm_stb = ~(pref_done_r | last_transmit);
      if (~pref_done_r & wbm_spi_ack_i) begin
        // fetch into inactive buffer
        dat_tx_n[~sel_tx_r]   = {wbm_spi_dat_i[7:0], wbm_spi_dat_i[15:8], wbm_spi_dat_i[23:16], wbm_spi_dat_i[31:24]};
        pref_done_n           = 1'b1;
      end

      if (tick) begin
        cnt_hbit_n  = cnt_hbit_r - 'b1;
        if (~|(cnt_hbit_r - 'b1)) begin
          // done with that word (full or part, depending on size)

          // (1) we have transmitted everything
          if (last_transmit) begin
            state_n = IDLE;
          end
          // (2) to next word, not prefetched
          else if (PREFETCH == 0) begin
            state_n = FETCH;
          end
          // (3) to next word, already prefetched
          else begin
            sel_tx_n    = ~sel_tx_r;
            cnt_word_n  = cnt_word_r + 'b1;
            pref_done_n = 1'b0;
            if (full_word_left) cnt_hbit_n  = 7'b100_0000; 
            else                cnt_hbit_n  = {1'b0, size_i[1:0], 4'b0};
          end
        end 
        cnt_presc_n = {presc_i, 3'b0};
        if (cnt_hbit_r[0]) begin
          dat_tx_n[sel_tx_r] = dat_tx_r[sel_tx_r] << 1;
        end
      end
    end
  endcase
end

always_ff @(posedge clk_i) begin
  dat_tx_r[0] <= dat_tx_n[0];
  dat_tx_r[1] <= dat_tx_n[1];
  cnt_hbit_r  <= cnt_hbit_n;
  cnt_presc_r <= cnt_presc_n;
  cnt_word_r  <= cnt_word_n;
  pref_done_r <= pref_done_n;

  if (~rst_in) begin
    state_r     <= IDLE;
    sck_r       <= CPOL;
    sel_tx_r    <= 1'b0;
  end else begin
    state_r     <= state_n;
    sel_tx_r    <= sel_tx_n;
    // SCK
    if (state_r == IDLE)          sck_r <= CPOL;
    else if (tick )  sck_r <= done ? CPOL : ~sck_r;
    else                          sck_r <= sck_r;
  end
end

endmodule
