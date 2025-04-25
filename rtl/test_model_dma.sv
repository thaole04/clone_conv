`timescale 1ns / 1ps

module tb_model_dma;
    // Tham số testbench
    parameter CLK_PERIOD = 10;        // Chu kỳ clock 10ns = 100MHz
    parameter WEIGHT_COUNT = 77;      // Tổng số trọng số cần nạp (72 kernel + 4 bias + 1 macc_coeff)
    
    // Tín hiệu kết nối với DUT (Device Under Test)
    reg clk;
    reg rst_n;
    
    reg [31:0] s_axis_weight_tdata;
    reg        s_axis_weight_tvalid;
    wire       s_axis_weight_tready;
    reg        s_axis_weight_tlast;

    reg [31:0] s_axis_data_tdata;
    reg        s_axis_data_tvalid;
    wire       s_axis_data_tready;
    reg        s_axis_data_tlast;
    integer i;

    wire [31:0] weight_wr_data;
    wire [31:0] weight_wr_addr;
    wire        weight_wr_en;
    wire        fifo_rd_en;

    weight_axi_controller #(
        .WEIGHT_COUNT(WEIGHT_COUNT)
    ) dut (
        .s_axis_tdata(s_axis_weight_tdata),
        .s_axis_tvalid(s_axis_weight_tvalid),
        .s_axis_tready(s_axis_weight_tready),
        .s_axis_tlast(s_axis_weight_tlast),
        .weight_wr_data(weight_wr_data),
        .weight_wr_addr(weight_wr_addr),
        .weight_wr_en(weight_wr_en),
        .clk(clk),
        .rst_n(rst_n)
    );
    // Khởi tạo DUT
    model uut (
        .o_data(),
        .o_valid(),
        .fifo_rd_en(fifo_rd_en),
        .i_data(s_axis_data_tdata),
        .i_valid(s_axis_data_tvalid),
        .weight_wr_data(weight_wr_data),
        .weight_wr_addr(weight_wr_addr),
        .weight_wr_en(weight_wr_en),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Tạo xung đồng hồ
    always begin
        #(CLK_PERIOD/2) clk = ~clk;
    end
    initial begin
       // Khởi tạo
       clk <= 0;
       rst_n <= 0;
       @(posedge clk);
       rst_n = 1;
       @(posedge clk);
       for (i = 0; i < 72; i = i + 1) begin
           // wait posdege clk
           s_axis_weight_tdata = 0;
           s_axis_weight_tvalid = 1;
           @(posedge clk);
       end
       for (i = 72; i < 76; i = i + 1) begin
           // wait posdege clk
           s_axis_weight_tdata = 'h640000;
           s_axis_weight_tvalid = 1;
           @(posedge clk);
       end
       s_axis_weight_tdata = 'h1000;
       s_axis_weight_tvalid = 1;
       @(posedge clk);
       s_axis_weight_tvalid = 0;
       @(posedge clk);
       s_axis_data_tdata = 1;
       s_axis_data_tvalid = 1;
       @(posedge clk);
       for (i = 0; i < 25; i = i + 1) begin
           // wait posdege clk
           if (fifo_rd_en == 1) begin
               s_axis_data_tdata = 1;
               s_axis_data_tvalid = 1;
           end else begin
           end
           @(posedge clk);
       end
       s_axis_data_tvalid = 0;
       repeat (100000) begin
          @(posedge clk);
       end
       $finish;
    end
endmodule
