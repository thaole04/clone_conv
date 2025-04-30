`timescale 1ns / 1ps

module model (
    input             clk,
    input             rst_n,
    input  [8*3-1:0]  i_data,
    input             i_valid,
    input  [31:0]     weight_wr_data,
    input  [31:0]     weight_wr_addr,
    input             weight_wr_en,
    output [8*3-1:0]  o_data,
    output            o_valid,
    output            fifo_rd_en
);
    wire [8*3-1:0] o_data_enc_0;
    wire o_valid_enc_0;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (5),
        .IN_HEIGHT             (5),
        .OUTPUT_MODE           ("relu"),
        .COMPUTE_FACTOR        ("single"),
        .KERNEL_0              (3),
        .KERNEL_1              (3),
        .PADDING_0             (1),
        .PADDING_1             (1),
        .DILATION_0            (1),
        .DILATION_1            (1),
        .STRIDE_0              (1),
        .STRIDE_1              (1),
        .IN_CHANNEL            (3),
        .OUT_CHANNEL           (3),
        .KERNEL_BASE_ADDR      (0), // Num kernel: 3*3*3*3
        .BIAS_BASE_ADDR        (81), // Num bias: 3
        .MACC_COEFF_BASE_ADDR  (84), // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR ()
    ) u_enc_0 (
        .o_data                (o_data_enc_0),
        .o_valid               (o_valid_enc_0),
        .fifo_rd_en            (fifo_rd_en),
        .i_data                (i_data),
        .i_valid               (i_valid),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );
    assign o_data = o_data_enc_0;
    assign o_valid = o_valid_enc_0;
endmodule
