`timescale 1ns / 1ps

module model (
    output [8*4-1:0] o_data,
    output           o_valid,
    output           fifo_rd_en,
    input  [8*2-1:0] i_data,
    input            i_valid,
    input  [   31:0] weight_wr_data,
    input  [   31:0] weight_wr_addr,
    input            weight_wr_en,
    input            clk,
    input            rst_n
);
  wire [8*4-1:0] o_data_wire;
  wire o_valid_wire;
  conv #(
      .UNROLL_MODE          ("incha"),
      .IN_WIDTH             (5),
      .IN_HEIGHT            (5),
      .OUTPUT_MODE          ("relu"),
      .COMPUTE_FACTOR       ("single"),
      .KERNEL_0             (3),
      .KERNEL_1             (3),
      .PADDING_0            (1),
      .PADDING_1            (1),
      .DILATION_0           (1),
      .DILATION_1           (1),
      .STRIDE_0             (1),
      .STRIDE_1             (1),
      .IN_CHANNEL           (2),
      .OUT_CHANNEL          (4),
      .KERNEL_BASE_ADDR     (0),         // Num kernel: 72
      .BIAS_BASE_ADDR       (72),        // Num bias: 4
      .MACC_COEFF_BASE_ADDR (76),        // Num macc_coeff: 1
      .LAYER_SCALE_BASE_ADDR()           // Num layer_scale: 0
  ) u_conv (
      .o_data          (o_data_wire),
      .o_valid         (o_valid_wire),
      .fifo_rd_en      (fifo_rd_en),
      .i_data          (i_data),
      .i_valid         (i_valid),
      .fifo_almost_full(1'b0),
      .weight_wr_data  (weight_wr_data),
      .weight_wr_addr  (weight_wr_addr),
      .weight_wr_en    (weight_wr_en),
      .clk             (clk),
      .rst_n           (rst_n)
  );

  assign o_valid = o_valid_wire;
  assign o_data  = o_data_wire;

endmodule
