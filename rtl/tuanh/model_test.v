`timescale 1ns / 1ps

module model (
    input             clk,
    input             rst_n,
    input  [8*2-1:0]  i_data,
    input             i_valid,
    input             cls_almost_full,
    input             vertical_almost_full,
    input  [31:0]     weight_wr_data,
    input  [31:0]     weight_wr_addr,
    input             weight_wr_en,
    output [16*4-1:0] o_data_cls,
    output [16*4-1:0] o_data_vertical,
    output            o_valid_cls,
    output            o_valid_vertical,
    output            fifo_rd_en
);

    // Encoder stage 0 conv 0
    wire [8*2-1:0] o_data_enc_0;
    wire o_valid_enc_0;
    wire fifo_almost_full_enc_0;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (4),
        .IN_HEIGHT             (4),
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
        .IN_CHANNEL            (2),
        .OUT_CHANNEL           (2),
        .KERNEL_BASE_ADDR      (0),  // Num kernel: 216
        .BIAS_BASE_ADDR        (36),  // Num bias: 8
        .MACC_COEFF_BASE_ADDR  (38),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (39)
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

    wire [8*2-1:0] fifo_rd_data_enc_0;
    wire fifo_empty_enc_0;
    wire fifo_rd_en_enc_0;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 2),
        .DEPTH             (16),
        .ALMOST_FULL_THRES (10)
    ) u_fifo_enc_0 (
        .rd_data           (fifo_rd_data_enc_0),
        .empty             (fifo_empty_enc_0),
        .full              (),
        .almost_full       (fifo_almost_full_enc_0),
        .wr_data           (o_data_enc_0),
        .wr_en             (o_valid_enc_0),
        .rd_en             (fifo_rd_en_enc_0),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // Encoder stage 0 conv 1
    wire [8*4-1:0] o_data_enc_1;
    wire o_valid_enc_1;
    wire fifo_almost_full_enc_1;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (4),
        .IN_HEIGHT             (4),
        .OUTPUT_MODE           ("relu"),
        .COMPUTE_FACTOR        ("single"),
        .KERNEL_0              (1),
        .KERNEL_1              (1),
        .PADDING_0             (0),
        .PADDING_1             (0),
        .DILATION_0            (1),
        .DILATION_1            (1),
        .STRIDE_0              (1),
        .STRIDE_1              (1),
        .IN_CHANNEL            (2),
        .OUT_CHANNEL           (4),
        .KERNEL_BASE_ADDR      (40),  // Num kernel: 576
        .BIAS_BASE_ADDR        (48),  // Num bias: 8
        .MACC_COEFF_BASE_ADDR  (52),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (53)
    ) u_enc_1 (
        .o_data                (o_data_enc_1),
        .o_valid               (o_valid_enc_1),
        .fifo_rd_en            (fifo_rd_en_enc_0),
        .i_data                (fifo_rd_data_enc_0),
        .i_valid               (~fifo_empty_enc_0),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*4-1:0] fifo_rd_data_enc_1;
    wire fifo_empty_enc_1;
    wire fifo_rd_en_enc_1;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 4),
        .DEPTH             (16),
        .ALMOST_FULL_THRES (10)
    ) u_fifo_enc_1 (
        .rd_data           (fifo_rd_data_enc_1),
        .empty             (fifo_empty_enc_1),
        .full              (),
        .almost_full       (fifo_almost_full_enc_1),
        .wr_data           (o_data_enc_1),
        .wr_en             (o_valid_enc_1),
        .rd_en             (fifo_rd_en_enc_1),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // Encoder stage 0 conv 2
    wire [8*2-1:0] o_data_enc_2;
    wire o_valid_enc_2;
    wire fifo_almost_full_enc_2;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (4),
        .IN_HEIGHT             (4),
        .OUTPUT_MODE           ("relu"),
        .COMPUTE_FACTOR        ("single"),
        .KERNEL_0              (3),
        .KERNEL_1              (3),
        .PADDING_0             (1),
        .PADDING_1             (1),
        .DILATION_0            (1),
        .DILATION_1            (1),
        .STRIDE_0              (2),
        .STRIDE_1              (2),
        .IN_CHANNEL            (4),
        .OUT_CHANNEL           (2),
        .KERNEL_BASE_ADDR      (54),  // Num kernel: 512
        .BIAS_BASE_ADDR        (126),  // Num bias: 16
        .MACC_COEFF_BASE_ADDR  (128),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (129)
    ) u_enc_2 (
        .o_data                (o_data_enc_2),
        .o_valid               (o_valid_enc_2),
        .fifo_rd_en            (fifo_rd_en_enc_1),
        .i_data                (fifo_rd_data_enc_1),
        .i_valid               (~fifo_empty_enc_1),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*2-1:0] fifo_rd_data_enc_2;
    wire fifo_empty_enc_2;
    wire fifo_rd_en_enc_2;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 2),
        .DEPTH             (4),
        .ALMOST_FULL_THRES (10)
    ) u_fifo_enc_2 (
        .rd_data           (fifo_rd_data_enc_2),
        .empty             (fifo_empty_enc_2),
        .full              (),
        .almost_full       (fifo_almost_full_enc_2),
        .wr_data           (o_data_enc_2),
        .wr_en             (o_valid_enc_2),
        .rd_en             (fifo_rd_en_enc_2),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // Encoder stage 1 conv 0
    wire [8*2-1:0] o_data_enc_3;
    wire o_valid_enc_3;
    wire fifo_almost_full_enc_3;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (2),
        .IN_HEIGHT             (2),
        .OUTPUT_MODE           ("relu"),
        .COMPUTE_FACTOR        ("single"),
        .KERNEL_0              (1),
        .KERNEL_1              (1),
        .PADDING_0             (0),
        .PADDING_1             (0),
        .DILATION_0            (1),
        .DILATION_1            (1),
        .STRIDE_0              (2),
        .STRIDE_1              (2),
        .IN_CHANNEL            (2),
        .OUT_CHANNEL           (2),
        .KERNEL_BASE_ADDR      (130),  // Num kernel: 2304
        .BIAS_BASE_ADDR        (134),  // Num bias: 16
        .MACC_COEFF_BASE_ADDR  (136),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (137)
    ) u_enc_3 (
        .o_data                (o_data_enc_3),
        .o_valid               (o_valid_enc_3),
        .fifo_rd_en            (fifo_rd_en_enc_2),
        .i_data                (fifo_rd_data_enc_2),
        .i_valid               (~fifo_empty_enc_2),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*1-1:0] fifo_rd_data_enc_3;
    wire fifo_empty_enc_3;
    wire fifo_rd_en_enc_3;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 2),
        .DEPTH             (1),
        .ALMOST_FULL_THRES (10)
    ) u_fifo_enc_3 (
        .rd_data           (fifo_rd_data_enc_3),
        .empty             (fifo_empty_enc_3),
        .full              (),
        .almost_full       (fifo_almost_full_enc_3),
        .wr_data           (o_data_enc_3),
        .wr_en             (o_valid_enc_3),
        .rd_en             (fifo_rd_en_enc_3),
        .rst_n             (rst_n),
        .clk               (clk)
    );


endmodule
