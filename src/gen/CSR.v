`include "rggen_rtl_macros.vh"
module CSR #(
  parameter ADDRESS_WIDTH = 6,
  parameter PRE_DECODE = 0,
  parameter [ADDRESS_WIDTH-1:0] BASE_ADDRESS = 0,
  parameter ERROR_STATUS = 0,
  parameter [31:0] DEFAULT_READ_DATA = 0,
  parameter INSERT_SLICER = 0,
  parameter USE_STALL = 1
)(
  input i_clk,
  input i_rst_n,
  input i_wb_cyc,
  input i_wb_stb,
  output o_wb_stall,
  input [ADDRESS_WIDTH-1:0] i_wb_adr,
  input i_wb_we,
  input [31:0] i_wb_dat,
  input [3:0] i_wb_sel,
  output o_wb_ack,
  output o_wb_err,
  output o_wb_rty,
  output [31:0] o_wb_dat,
  input [3:0] i_GPI_gpi,
  output [3:0] o_GPO_gpo,
  output [3:0] o_GPOE_gpoe,
  output [3:0] o_GPCS_gpcs,
  output [3:0] o_GPSL_gpsl,
  output [3:0] o_GPPU_gppu,
  output [3:0] o_GPPD_gppd,
  output [3:0] o_SPI_Conf_presc,
  output o_SPI_Conf_cpol,
  output o_SPI_Conf_auto_cs,
  output [1:0] o_SPI_Conf_size,
  output o_OLED_Start_Status_start_rdy,
  input i_OLED_Start_Status_start_rdy,
  output [3:0] o_OLED_Conf_presc,
  output o_OLED_Conf_inc,
  output [13:0] o_OLED_Conf_size,
  output [31:0] o_OLED_Dma_addr,
  input i_Irqs_uart_irq,
  input i_Irqs_spi_irq,
  input i_Irqs_spi_rdy,
  output o_Guard_gd_ef_xip
);
  wire w_register_valid;
  wire [1:0] w_register_access;
  wire [5:0] w_register_address;
  wire [31:0] w_register_write_data;
  wire [31:0] w_register_strobe;
  wire [12:0] w_register_active;
  wire [12:0] w_register_ready;
  wire [25:0] w_register_status;
  wire [415:0] w_register_read_data;
  wire [415:0] w_register_value;
  rggen_wishbone_adapter #(
    .ADDRESS_WIDTH        (ADDRESS_WIDTH),
    .LOCAL_ADDRESS_WIDTH  (6),
    .BUS_WIDTH            (32),
    .REGISTERS            (13),
    .PRE_DECODE           (PRE_DECODE),
    .BASE_ADDRESS         (BASE_ADDRESS),
    .BYTE_SIZE            (56),
    .ERROR_STATUS         (ERROR_STATUS),
    .DEFAULT_READ_DATA    (DEFAULT_READ_DATA),
    .INSERT_SLICER        (INSERT_SLICER),
    .USE_STALL            (USE_STALL)
  ) u_adapter (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_wb_cyc               (i_wb_cyc),
    .i_wb_stb               (i_wb_stb),
    .o_wb_stall             (o_wb_stall),
    .i_wb_adr               (i_wb_adr),
    .i_wb_we                (i_wb_we),
    .i_wb_dat               (i_wb_dat),
    .i_wb_sel               (i_wb_sel),
    .o_wb_ack               (o_wb_ack),
    .o_wb_err               (o_wb_err),
    .o_wb_rty               (o_wb_rty),
    .o_wb_dat               (o_wb_dat),
    .o_register_valid       (w_register_valid),
    .o_register_access      (w_register_access),
    .o_register_address     (w_register_address),
    .o_register_write_data  (w_register_write_data),
    .o_register_strobe      (w_register_strobe),
    .i_register_active      (w_register_active),
    .i_register_ready       (w_register_ready),
    .i_register_status      (w_register_status),
    .i_register_read_data   (w_register_read_data)
  );
  generate if (1) begin : g_GPI
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h0000000f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h00),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[0+:1]),
      .o_register_ready         (w_register_ready[0+:1]),
      .o_register_status        (w_register_status[0+:2]),
      .o_register_read_data     (w_register_read_data[0+:32]),
      .o_register_value         (w_register_value[0+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_gpi
      rggen_bit_field #(
        .WIDTH              (4),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:4]),
        .i_sw_write_data    (w_bit_field_write_data[0+:4]),
        .o_sw_read_data     (w_bit_field_read_data[0+:4]),
        .o_sw_value         (w_bit_field_value[0+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            (i_GPI_gpi),
        .i_mask             ({4{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_GPO
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h0000000f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h04),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[1+:1]),
      .o_register_ready         (w_register_ready[1+:1]),
      .o_register_status        (w_register_status[2+:2]),
      .o_register_read_data     (w_register_read_data[32+:32]),
      .o_register_value         (w_register_value[32+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_gpo
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:4]),
        .i_sw_write_data    (w_bit_field_write_data[0+:4]),
        .o_sw_read_data     (w_bit_field_read_data[0+:4]),
        .o_sw_value         (w_bit_field_value[0+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_GPO_gpo),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_GPOE
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h0000000f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h08),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[2+:1]),
      .o_register_ready         (w_register_ready[2+:1]),
      .o_register_status        (w_register_status[4+:2]),
      .o_register_read_data     (w_register_read_data[64+:32]),
      .o_register_value         (w_register_value[64+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_gpoe
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:4]),
        .i_sw_write_data    (w_bit_field_write_data[0+:4]),
        .o_sw_read_data     (w_bit_field_read_data[0+:4]),
        .o_sw_value         (w_bit_field_value[0+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_GPOE_gpoe),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_GPCS
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h0000000f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h0c),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[3+:1]),
      .o_register_ready         (w_register_ready[3+:1]),
      .o_register_status        (w_register_status[6+:2]),
      .o_register_read_data     (w_register_read_data[96+:32]),
      .o_register_value         (w_register_value[96+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_gpcs
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:4]),
        .i_sw_write_data    (w_bit_field_write_data[0+:4]),
        .o_sw_read_data     (w_bit_field_read_data[0+:4]),
        .o_sw_value         (w_bit_field_value[0+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_GPCS_gpcs),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_GPSL
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h0000000f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h10),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[4+:1]),
      .o_register_ready         (w_register_ready[4+:1]),
      .o_register_status        (w_register_status[8+:2]),
      .o_register_read_data     (w_register_read_data[128+:32]),
      .o_register_value         (w_register_value[128+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_gpsl
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:4]),
        .i_sw_write_data    (w_bit_field_write_data[0+:4]),
        .o_sw_read_data     (w_bit_field_read_data[0+:4]),
        .o_sw_value         (w_bit_field_value[0+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_GPSL_gpsl),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_GPPU
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h0000000f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h14),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[5+:1]),
      .o_register_ready         (w_register_ready[5+:1]),
      .o_register_status        (w_register_status[10+:2]),
      .o_register_read_data     (w_register_read_data[160+:32]),
      .o_register_value         (w_register_value[160+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_gppu
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:4]),
        .i_sw_write_data    (w_bit_field_write_data[0+:4]),
        .o_sw_read_data     (w_bit_field_read_data[0+:4]),
        .o_sw_value         (w_bit_field_value[0+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_GPPU_gppu),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_GPPD
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h0000000f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h18),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[6+:1]),
      .o_register_ready         (w_register_ready[6+:1]),
      .o_register_status        (w_register_status[12+:2]),
      .o_register_read_data     (w_register_read_data[192+:32]),
      .o_register_value         (w_register_value[192+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_gppd
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:4]),
        .i_sw_write_data    (w_bit_field_write_data[0+:4]),
        .o_sw_read_data     (w_bit_field_read_data[0+:4]),
        .o_sw_value         (w_bit_field_value[0+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_GPPD_gppd),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_SPI_Conf
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h000000ff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h1c),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[7+:1]),
      .o_register_ready         (w_register_ready[7+:1]),
      .o_register_status        (w_register_status[14+:2]),
      .o_register_read_data     (w_register_read_data[224+:32]),
      .o_register_value         (w_register_value[224+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_presc
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h1),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:4]),
        .i_sw_write_data    (w_bit_field_write_data[0+:4]),
        .o_sw_read_data     (w_bit_field_read_data[0+:4]),
        .o_sw_value         (w_bit_field_value[0+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_SPI_Conf_presc),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_cpol
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (1'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[4+:1]),
        .i_sw_write_data    (w_bit_field_write_data[4+:1]),
        .o_sw_read_data     (w_bit_field_read_data[4+:1]),
        .o_sw_value         (w_bit_field_value[4+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_SPI_Conf_cpol),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_auto_cs
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (1'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[5+:1]),
        .i_sw_write_data    (w_bit_field_write_data[5+:1]),
        .o_sw_read_data     (w_bit_field_read_data[5+:1]),
        .o_sw_value         (w_bit_field_value[5+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_SPI_Conf_auto_cs),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_size
      rggen_bit_field #(
        .WIDTH          (2),
        .INITIAL_VALUE  (2'h1),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[6+:2]),
        .i_sw_write_data    (w_bit_field_write_data[6+:2]),
        .o_sw_read_data     (w_bit_field_read_data[6+:2]),
        .o_sw_value         (w_bit_field_value[6+:2]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({2{1'b0}}),
        .i_hw_set           ({2{1'b0}}),
        .i_hw_clear         ({2{1'b0}}),
        .i_value            ({2{1'b0}}),
        .i_mask             ({2{1'b1}}),
        .o_value            (o_SPI_Conf_size),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_OLED_Start_Status
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h00000001, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h20),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[8+:1]),
      .o_register_ready         (w_register_ready[8+:1]),
      .o_register_status        (w_register_status[16+:2]),
      .o_register_read_data     (w_register_read_data[256+:32]),
      .o_register_value         (w_register_value[256+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_start_rdy
      rggen_bit_field #(
        .WIDTH              (1),
        .INITIAL_VALUE      (1'h0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_OLED_Start_Status_start_rdy),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_OLED_Start_Status_start_rdy),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_OLED_Conf
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h003fff1f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h24),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[9+:1]),
      .o_register_ready         (w_register_ready[9+:1]),
      .o_register_status        (w_register_status[18+:2]),
      .o_register_read_data     (w_register_read_data[288+:32]),
      .o_register_value         (w_register_value[288+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_presc
      rggen_bit_field #(
        .WIDTH          (4),
        .INITIAL_VALUE  (4'h1),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:4]),
        .i_sw_write_data    (w_bit_field_write_data[0+:4]),
        .o_sw_read_data     (w_bit_field_read_data[0+:4]),
        .o_sw_value         (w_bit_field_value[0+:4]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({4{1'b0}}),
        .i_hw_set           ({4{1'b0}}),
        .i_hw_clear         ({4{1'b0}}),
        .i_value            ({4{1'b0}}),
        .i_mask             ({4{1'b1}}),
        .o_value            (o_OLED_Conf_presc),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_inc
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (1'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[4+:1]),
        .i_sw_write_data    (w_bit_field_write_data[4+:1]),
        .o_sw_read_data     (w_bit_field_read_data[4+:1]),
        .o_sw_value         (w_bit_field_value[4+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_OLED_Conf_inc),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_size
      rggen_bit_field #(
        .WIDTH          (14),
        .INITIAL_VALUE  (14'h0000),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[8+:14]),
        .i_sw_write_data    (w_bit_field_write_data[8+:14]),
        .o_sw_read_data     (w_bit_field_read_data[8+:14]),
        .o_sw_value         (w_bit_field_value[8+:14]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({14{1'b0}}),
        .i_hw_set           ({14{1'b0}}),
        .i_hw_clear         ({14{1'b0}}),
        .i_value            ({14{1'b0}}),
        .i_mask             ({14{1'b1}}),
        .o_value            (o_OLED_Conf_size),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_OLED_Dma
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'hffffffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h28),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[10+:1]),
      .o_register_ready         (w_register_ready[10+:1]),
      .o_register_status        (w_register_status[20+:2]),
      .o_register_read_data     (w_register_read_data[320+:32]),
      .o_register_value         (w_register_value[320+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_addr
      rggen_bit_field #(
        .WIDTH          (32),
        .INITIAL_VALUE  (32'h00000000),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:32]),
        .i_sw_write_data    (w_bit_field_write_data[0+:32]),
        .o_sw_read_data     (w_bit_field_read_data[0+:32]),
        .o_sw_value         (w_bit_field_value[0+:32]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({32{1'b0}}),
        .i_hw_set           ({32{1'b0}}),
        .i_hw_clear         ({32{1'b0}}),
        .i_value            ({32{1'b0}}),
        .i_mask             ({32{1'b1}}),
        .o_value            (o_OLED_Dma_addr),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_Irqs
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h00000007, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h2c),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[11+:1]),
      .o_register_ready         (w_register_ready[11+:1]),
      .o_register_status        (w_register_status[22+:2]),
      .o_register_read_data     (w_register_read_data[352+:32]),
      .o_register_value         (w_register_value[352+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_uart_irq
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_Irqs_uart_irq),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_spi_irq
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[1+:1]),
        .i_sw_write_data    (w_bit_field_write_data[1+:1]),
        .o_sw_read_data     (w_bit_field_read_data[1+:1]),
        .o_sw_value         (w_bit_field_value[1+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_Irqs_spi_irq),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_spi_rdy
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[2+:1]),
        .i_sw_write_data    (w_bit_field_write_data[2+:1]),
        .o_sw_read_data     (w_bit_field_read_data[2+:1]),
        .o_sw_value         (w_bit_field_value[2+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_Irqs_spi_rdy),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_Guard
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'h00000001, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (6),
      .OFFSET_ADDRESS (6'h30),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[12+:1]),
      .o_register_ready         (w_register_ready[12+:1]),
      .o_register_status        (w_register_status[24+:2]),
      .o_register_read_data     (w_register_read_data[384+:32]),
      .o_register_value         (w_register_value[384+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_gd_ef_xip
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (1'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_Guard_gd_ef_xip),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
endmodule
