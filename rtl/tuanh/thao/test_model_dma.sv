`timescale 1ns / 1ps

module tb_model_dma;
    // Tham số testbench
    parameter CLK_PERIOD = 10;        // Chu kỳ clock 10ns = 100MHz
    parameter WEIGHT_COUNT = 99678;      // Tổng số trọng số cần nạp (72 kernel + 4 bias + 1 macc_coeff)
    reg [32-1:0] weights [0:99678-1];
    reg [24-1:0] input_data [0:256*256-1];
    
    // Tín hiệu kết nối với DUT (Device Under Test)
    reg clk;
    reg rst_n;
    
    reg [31:0]  s_axis_weight_tdata;
    reg         s_axis_weight_tvalid;
    wire        s_axis_weight_tready;
    reg         s_axis_weight_tlast;

    reg [31:0]  s_axis_data_tdata;
    reg         s_axis_data_tvalid;
    wire        s_axis_data_tready;
    reg         s_axis_data_tlast;
    integer i;
    integer data_idx;
    
    wire [31:0] signal_out_data;
    wire        signal_out_valid;
    wire        fifo_rd_en;

    top #(
        .WEIGHT_COUNT(WEIGHT_COUNT)
    ) dut (
        .s_axis_tdata      (s_axis_weight_tdata),
        .s_axis_tvalid     (s_axis_weight_tvalid),
        .s_axis_tready     (s_axis_weight_tready),
        .s_axis_tlast      (s_axis_weight_tlast),
        .clk               (clk),
        .rst_n             (rst_n),
        .s_axis_data_tdata (s_axis_data_tdata[23:0]),
        .s_axis_data_tvalid(s_axis_data_tvalid),
        .signal_out_data   (signal_out_data),
        .signal_out_valid  (signal_out_valid),
        .fifo_rd_en        (fifo_rd_en) 
    );
    
    // Tạo xung đồng hồ
    always begin
        #(CLK_PERIOD/2) clk = ~clk;
    end
    initial begin
        $readmemh("/home/tuananh/alpr/QuantLaneNet_original/DA/final_detect_model/try3_minimal/mem/weights.mem", weights);
        $readmemh("/home/tuananh/alpr/QuantLaneNet_original/DA/final_detect_model/try3_minimal/mem/input.mem", input_data);
       // Khởi tạo
       clk   <= 0;
       @(posedge clk);

       rst_n <= 0;
       s_axis_weight_tdata <= 0;   
       s_axis_weight_tvalid <= 0;
       s_axis_weight_tlast <= 0;
                             
       s_axis_data_tdata <= 0;
       s_axis_data_tvalid <= 0;
       s_axis_data_tlast <= 0;
                             
                             
       data_idx <=0;
       i <= 0;

       repeat (10) @(posedge clk);
       rst_n <= 1;

       @(posedge clk);

       for (i = 0; i < 99678; i = i + 1) begin
           @(posedge clk);
           s_axis_weight_tdata  <= weights[i];
           s_axis_weight_tvalid <= 1;
       end

       @(posedge clk);
       s_axis_weight_tvalid <= 0;
       @(posedge clk);

       //s_axis_data_tvalid <= 1;
       repeat (10) @(posedge clk);
       //
       // 1 dummy input 
       s_axis_data_tdata  <= 'h55_5555;
       s_axis_data_tvalid <= 1;
       //
       //
       while (data_idx < 256*256) begin
           @(posedge clk);
           if (fifo_rd_en) begin
               s_axis_data_tdata  <= input_data[data_idx];
               s_axis_data_tvalid <= 1;
               data_idx           <= data_idx + 1;
           end else begin
               //s_axis_data_tvalid <= 0;
           end
       end

       @(posedge clk);
       s_axis_data_tvalid <= 0;

       repeat (100) begin
          @(posedge clk);
       end
       $finish;
    end
endmodule
