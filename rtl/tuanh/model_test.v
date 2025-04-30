`timescale 1ns / 1ps

module model (
    input             clk,
    input             rst_n,
    input  [8*3-1:0]  i_data,
    input             i_valid,
    input  [31:0]     weight_wr_data,
    input  [31:0]     weight_wr_addr,
    input             weight_wr_en,
    output [16*4-1:0] o_data,
    output            o_valid,
    output            fifo_rd_en
);

    // conv_1
    wire [8*16-1:0] o_data_conv_1;
    wire o_valid_conv_1;
    wire fifo_almost_full_conv_1;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (256),
        .IN_HEIGHT             (256),
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
        .IN_CHANNEL            (3),
        .OUT_CHANNEL           (16),
        .KERNEL_BASE_ADDR      (0),  // Num kernel: 216
        .BIAS_BASE_ADDR        (432),  // Num bias: 8
        .MACC_COEFF_BASE_ADDR  (448),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (449)
    ) u_conv_1 (
        .o_data                (o_data_conv_1),
        .o_valid               (o_valid_conv_1),
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

    wire [8*16-1:0] fifo_rd_data_conv_1;
    wire fifo_empty_conv_1;
    wire fifo_rd_en_conv_1;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 16),
        .DEPTH             (128 * 128),
        .ALMOST_FULL_THRES (100)
    ) u_fifo_conv_1 (
        .rd_data           (fifo_rd_data_conv_1),
        .empty             (fifo_empty_conv_1),
        .full              (),
        .almost_full       (fifo_almost_full_conv_1),
        .wr_data           (o_data_conv_1),
        .wr_en             (o_valid_conv_1),
        .rd_en             (fifo_rd_en_conv_1),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // conv_2
    wire [8*32-1:0] o_data_conv_2;
    wire o_valid_conv_2;
    wire fifo_almost_full_conv_2;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (128),
        .IN_HEIGHT             (128),
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
        .IN_CHANNEL            (16),
        .OUT_CHANNEL           (32),
        .KERNEL_BASE_ADDR      (450),  // Num kernel: 576
        .BIAS_BASE_ADDR        (5058),  // Num bias: 8
        .MACC_COEFF_BASE_ADDR  (5090),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (5091)
    ) u_conv_2 (
        .o_data                (o_data_conv_2),
        .o_valid               (o_valid_conv_2),
        .fifo_rd_en            (fifo_rd_en_conv_1),
        .i_data                (fifo_rd_data_conv_1),
        .i_valid               (~fifo_empty_conv_1),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*32-1:0] fifo_rd_data_conv_2;
    wire fifo_empty_conv_2;
    wire fifo_rd_en_conv_2;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 32),
        .DEPTH             (64*64),
        .ALMOST_FULL_THRES (1024)
    ) u_fifo_conv_2 (
        .rd_data           (fifo_rd_data_conv_2),
        .empty             (fifo_empty_conv_2),
        .full              (),
        .almost_full       (fifo_almost_full_conv_2),
        .wr_data           (o_data_conv_2),
        .wr_en             (o_valid_conv_2),
        .rd_en             (fifo_rd_en_conv_2),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // conv_3
    wire [8*64-1:0] o_data_conv_3;
    wire o_valid_conv_3;
    wire fifo_almost_full_conv_3;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (64),
        .IN_HEIGHT             (64),
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
        .IN_CHANNEL            (32),
        .OUT_CHANNEL           (64),
        .KERNEL_BASE_ADDR      (5092),  // Num kernel: 512
        .BIAS_BASE_ADDR        (23524),  // Num bias: 16
        .MACC_COEFF_BASE_ADDR  (23588),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (23589)
    ) u_conv_3 (
        .o_data                (o_data_conv_3),
        .o_valid               (o_valid_conv_3),
        .fifo_rd_en            (fifo_rd_en_conv_2),
        .i_data                (fifo_rd_data_conv_2),
        .i_valid               (~fifo_empty_conv_2),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*64-1:0] fifo_rd_data_conv_3;
    wire fifo_empty_conv_3;
    wire fifo_rd_en_conv_3;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 64),
        .DEPTH             (64*64),
        .ALMOST_FULL_THRES (1024)
    ) u_fifo_conv_3 (
        .rd_data           (fifo_rd_data_conv_3),
        .empty             (fifo_empty_conv_3),
        .full              (),
        .almost_full       (fifo_almost_full_conv_3),
        .wr_data           (o_data_conv_3),
        .wr_en             (o_valid_conv_3),
        .rd_en             (fifo_rd_en_conv_3),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // conv_4
    wire [8*32-1:0] o_data_conv_4;
    wire o_valid_conv_4;
    wire fifo_almost_full_conv_4;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (64),
        .IN_HEIGHT             (64),
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
        .IN_CHANNEL            (64),
        .OUT_CHANNEL           (32),
        .KERNEL_BASE_ADDR      (23590),  // Num kernel: 2304
        .BIAS_BASE_ADDR        (25638),  // Num bias: 16
        .MACC_COEFF_BASE_ADDR  (25670),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (25671)
    ) u_conv_4 (
        .o_data                (o_data_conv_4),
        .o_valid               (o_valid_conv_4),
        .fifo_rd_en            (fifo_rd_en_conv_3),
        .i_data                (fifo_rd_data_conv_3),
        .i_valid               (~fifo_empty_conv_3),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*32-1:0] fifo_rd_data_conv_4;
    wire fifo_empty_conv_4;
    wire fifo_rd_en_conv_4;

    fifo_single_read #(
        .DATA_WIDTH        (8*32),
        .DEPTH             (64*64),
        .ALMOST_FULL_THRES (1024)
    ) u_fifo_conv_4 (
        .rd_data           (fifo_rd_data_conv_4),
        .empty             (fifo_empty_conv_4),
        .full              (),
        .almost_full       (fifo_almost_full_conv_4),
        .wr_data           (o_data_conv_4),
        .wr_en             (o_valid_conv_4),
        .rd_en             (fifo_rd_en_conv_4),
        .rst_n             (rst_n),
        .clk               (clk)
    );
    // conv_5
    wire [8*32-1:0] o_data_conv_5;
    wire o_valid_conv_5;
    wire fifo_almost_full_conv_5;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (64),
        .IN_HEIGHT             (64),
        .OUTPUT_MODE           ("relu"),
        .COMPUTE_FACTOR        ("double"),
        .KERNEL_0              (3),
        .KERNEL_1              (3),
        .PADDING_0             (1),
        .PADDING_1             (1),
        .DILATION_0            (1),
        .DILATION_1            (1),
        .STRIDE_0              (2),
        .STRIDE_1              (2),
        .IN_CHANNEL            (32),
        .OUT_CHANNEL           (32),
        .KERNEL_BASE_ADDR      (25672),  // Num kernel: 2048
        .BIAS_BASE_ADDR        (34888),  // Num bias: 32
        .MACC_COEFF_BASE_ADDR  (34920),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (34921)
    ) u_conv_5 (
        .o_data                (o_data_conv_5),
        .o_valid               (o_valid_conv_5),
        .fifo_rd_en            (fifo_rd_en_conv_4),
        .i_data                (fifo_rd_data_conv_4),
        .i_valid               (~fifo_empty_conv_4),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*32-1:0] fifo_rd_data_conv_5;
    wire fifo_empty_conv_5;
    wire fifo_rd_en_conv_5;

    fifo_single_read #(
        .DATA_WIDTH        (8*32),
        .DEPTH             (32*32),
        .ALMOST_FULL_THRES (512)
    ) u_fifo_conv_5 (
        .rd_data           (fifo_rd_data_conv_5),
        .empty             (fifo_empty_conv_5),
        .full              (),
        .almost_full       (fifo_almost_full_conv_5),
        .wr_data           (o_data_conv_5),
        .wr_en             (o_valid_conv_5),
        .rd_en             (fifo_rd_en_conv_5),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // conv_6
    wire [8*64-1:0] o_data_conv_6;
    wire o_valid_conv_6;
    wire fifo_almost_full_conv_6;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (32),
        .IN_HEIGHT             (32),
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
        .IN_CHANNEL            (32),
        .OUT_CHANNEL           (64),
        .KERNEL_BASE_ADDR      (34922),  // Num kernel: 9216
        .BIAS_BASE_ADDR        (53354),  // Num bias: 32
        .MACC_COEFF_BASE_ADDR  (53418),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (53419)
    ) u_conv_6 (
        .o_data                (o_data_conv_6),
        .o_valid               (o_valid_conv_6),
        .fifo_rd_en            (fifo_rd_en_conv_5),
        .i_data                (fifo_rd_data_conv_5),
        .i_valid               (~fifo_empty_conv_5),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*64-1:0] fifo_rd_data_conv_6;
    wire fifo_empty_conv_6;
    wire fifo_rd_en_conv_6;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 64),
        .DEPTH             (32*32),
        .ALMOST_FULL_THRES (512)
    ) u_fifo_conv_6 (
        .rd_data           (fifo_rd_data_conv_6),
        .empty             (fifo_empty_conv_6),
        .full              (),
        .almost_full       (fifo_almost_full_conv_6),
        .wr_data           (o_data_conv_6),
        .wr_en             (o_valid_conv_6),
        .rd_en             (fifo_rd_en_conv_6),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // conv_7
    wire [8*32-1:0] o_data_conv_7;
    wire o_valid_conv_7;
    wire fifo_almost_full_conv_7;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (32),
        .IN_HEIGHT             (32),
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
        .IN_CHANNEL            (64),
        .OUT_CHANNEL           (32),
        .KERNEL_BASE_ADDR      (53420),  // Num kernel: 9216
        .BIAS_BASE_ADDR        (55468),  // Num bias: 32
        .MACC_COEFF_BASE_ADDR  (55500),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (55501)
    ) u_conv_7 (
        .o_data                (o_data_conv_7),
        .o_valid               (o_valid_conv_7),
        .fifo_rd_en            (fifo_rd_en_conv_6),
        .i_data                (fifo_rd_data_conv_6),
        .i_valid               (~fifo_empty_conv_6),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*32-1:0] fifo_rd_data_conv_7;
    wire fifo_empty_conv_7;
    wire fifo_rd_en_conv_7;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 32),
        .DEPTH             (32*32),
        .ALMOST_FULL_THRES (512)
    ) u_fifo_conv_7 (
        .rd_data           (fifo_rd_data_conv_7),
        .empty             (fifo_empty_conv_7),
        .full              (),
        .almost_full       (fifo_almost_full_conv_7),
        .wr_data           (o_data_conv_7),
        .wr_en             (o_valid_conv_7),
        .rd_en             (fifo_rd_en_conv_7),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // conv_8
    wire [8*64-1:0] o_data_conv_8;
    wire o_valid_conv_8;
    wire fifo_almost_full_conv_8;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (32),
        .IN_HEIGHT             (32),
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
        .IN_CHANNEL            (32),
        .OUT_CHANNEL           (64),
        .KERNEL_BASE_ADDR      (55502),  // Num kernel: 8192
        .BIAS_BASE_ADDR        (73934),  // Num bias: 64
        .MACC_COEFF_BASE_ADDR  (73998),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (73999)
    ) u_conv_8 (
        .o_data                (o_data_conv_8),
        .o_valid               (o_valid_conv_8),
        .fifo_rd_en            (fifo_rd_en_conv_7),
        .i_data                (fifo_rd_data_conv_7),
        .i_valid               (~fifo_empty_conv_7),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*64-1:0] fifo_rd_data_conv_8;
    wire fifo_empty_conv_8;
    wire fifo_rd_en_conv_8;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 64),
        .DEPTH             (16*16),
        .ALMOST_FULL_THRES (128)
    ) u_fifo_conv_8 (
        .rd_data           (fifo_rd_data_conv_8),
        .empty             (fifo_empty_conv_8),
        .full              (),
        .almost_full       (fifo_almost_full_conv_8),
        .wr_data           (o_data_conv_8),
        .wr_en             (o_valid_conv_8),
        .rd_en             (fifo_rd_en_conv_8),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // conv_9
    wire [8*128-1:0] o_data_conv_9;
    wire o_valid_conv_9;
    wire fifo_almost_full_conv_9;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (16),
        .IN_HEIGHT             (16),
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
        .IN_CHANNEL            (64),
        .OUT_CHANNEL           (128),
        .KERNEL_BASE_ADDR      (74000),  // Num kernel: 8192
        .BIAS_BASE_ADDR        (82192),  // Num bias: 64
        .MACC_COEFF_BASE_ADDR  (82320),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (82321)
    ) u_conv_9 (
        .o_data                (o_data_conv_9),
        .o_valid               (o_valid_conv_9),
        .fifo_rd_en            (fifo_rd_en_conv_8),
        .i_data                (fifo_rd_data_conv_8),
        .i_valid               (~fifo_empty_conv_8),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*128-1:0] fifo_rd_data_conv_9;
    wire fifo_empty_conv_9;
    wire fifo_rd_en_conv_9;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 128),
        .DEPTH             (8*8),
        .ALMOST_FULL_THRES (32)
    ) u_fifo_conv_9 (
        .rd_data           (fifo_rd_data_conv_9),
        .empty             (fifo_empty_conv_9),
        .full              (),
        .almost_full       (fifo_almost_full_conv_9),
        .wr_data           (o_data_conv_9),
        .wr_en             (o_valid_conv_9),
        .rd_en             (fifo_rd_en_conv_9),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // conv_10
    wire [8*64-1:0] o_data_conv_10;
    wire o_valid_conv_10;
    wire fifo_almost_full_conv_10;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (8),
        .IN_HEIGHT             (8),
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
        .IN_CHANNEL            (128),
        .OUT_CHANNEL           (64),
        .KERNEL_BASE_ADDR      (82322),  // Num kernel: 8192
        .BIAS_BASE_ADDR        (90514),  // Num bias: 64
        .MACC_COEFF_BASE_ADDR  (90578),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (90579)
    ) u_conv_10 (
        .o_data                (o_data_conv_10),
        .o_valid               (o_valid_conv_10),
        .fifo_rd_en            (fifo_rd_en_conv_9),
        .i_data                (fifo_rd_data_conv_9),
        .i_valid               (~fifo_empty_conv_9),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*64-1:0] fifo_rd_data_conv_10;
    wire fifo_empty_conv_10;
    wire fifo_rd_en_conv_10;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 64),
        .DEPTH             (8*8),
        .ALMOST_FULL_THRES (32)
    ) u_fifo_conv_10 (
        .rd_data           (fifo_rd_data_conv_10),
        .empty             (fifo_empty_conv_10),
        .full              (),
        .almost_full       (fifo_almost_full_conv_10),
        .wr_data           (o_data_conv_10),
        .wr_en             (o_valid_conv_10),
        .rd_en             (fifo_rd_en_conv_10),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // conv_11
    wire [8*128-1:0] o_data_conv_11;
    wire o_valid_conv_11;
    wire fifo_almost_full_conv_11;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (8),
        .IN_HEIGHT             (8),
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
        .IN_CHANNEL            (64),
        .OUT_CHANNEL           (128),
        .KERNEL_BASE_ADDR      (90580),  // Num kernel: 8192
        .BIAS_BASE_ADDR        (98772),  // Num bias: 64
        .MACC_COEFF_BASE_ADDR  (98900),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (98901)
    ) u_conv_11 (
        .o_data                (o_data_conv_11),
        .o_valid               (o_valid_conv_11),
        .fifo_rd_en            (fifo_rd_en_conv_10),
        .i_data                (fifo_rd_data_conv_10),
        .i_valid               (~fifo_empty_conv_10),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    wire [8*128-1:0] fifo_rd_data_conv_11;
    wire fifo_empty_conv_11;
    wire fifo_rd_en_conv_11;

    fifo_single_read #(
        .DATA_WIDTH        (8 * 128),
        .DEPTH             (8*8),
        .ALMOST_FULL_THRES (32)
    ) u_fifo_conv_11 (
        .rd_data           (fifo_rd_data_conv_11),
        .empty             (fifo_empty_conv_11),
        .full              (),
        .almost_full       (fifo_almost_full_conv_11),
        .wr_data           (o_data_conv_11),
        .wr_en             (o_valid_conv_11),
        .rd_en             (fifo_rd_en_conv_11),
        .rst_n             (rst_n),
        .clk               (clk)
    );

    // out_conv
    wire [8*6-1:0] o_data_conv_out;
    wire o_valid_conv_out;
    wire fifo_almost_full_conv_out;

    conv #(
        .UNROLL_MODE           ("incha"),
        .IN_WIDTH              (8),
        .IN_HEIGHT             (8),
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
        .IN_CHANNEL            (128),
        .OUT_CHANNEL           (6),
        .KERNEL_BASE_ADDR      (98902),  // Num kernel: 8192
        .BIAS_BASE_ADDR        (99670),  // Num bias: 64
        .MACC_COEFF_BASE_ADDR  (99676),  // Num macc_coeff: 1
        .LAYER_SCALE_BASE_ADDR (99677)
    ) u_conv_out (
        .o_data                (o_data_conv_out),
        .o_valid               (o_valid_conv_out),
        .fifo_rd_en            (fifo_rd_en_conv_11),
        .i_data                (fifo_rd_data_conv_11),
        .i_valid               (~fifo_empty_conv_11),
        .fifo_almost_full      (1'b0),
        .weight_wr_data        (weight_wr_data),
        .weight_wr_addr        (weight_wr_addr),
        .weight_wr_en          (weight_wr_en),
        .clk                   (clk),
        .rst_n                 (rst_n)
    );

    //wire [8*6-1:0] fifo_rd_data_conv_out;
    //wire fifo_empty_conv_out;
    //wire fifo_rd_en_conv_out;

    //fifo_single_read #(
    //    .DATA_WIDTH        (8 * 32),
    //    .DEPTH             (128),
    //    .ALMOST_FULL_THRES (10)
    //) u_fifo_conv_out (
    //    .rd_data           (fifo_rd_data_conv_out),
    //    .empty             (fifo_empty_conv_out),
    //    .full              (),
    //    .almost_full       (fifo_almost_full_conv_out),
    //    .wr_data           (o_data_conv_out),
    //    .wr_en             (o_valid_conv_out),
    //    .rd_en             (fifo_rd_en_conv_out),
    //    .rst_n             (rst_n),
    //    .clk               (clk)
    //);

    assign o_data  = o_data_conv_out;
    assign o_valid = o_valid_conv_out;

endmodule
