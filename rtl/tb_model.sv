`timescale 1ns / 1ps

module tb_model;
    // Tham số testbench
    parameter CLK_PERIOD = 10;        // Chu kỳ clock 10ns = 100MHz
    parameter TEST_CYCLES = 3000;      // Số chu kỳ kiểm tra
    parameter WEIGHT_COUNT = 77;      // Tổng số trọng số cần nạp (72 kernel + 4 bias + 1 macc_coeff)
    parameter IMAGE_SIZE = 25;       // Kích thước hình ảnh đầu vào 5x5
    
    // Tín hiệu kết nối với DUT (Device Under Test)
    reg clk;
    reg rst_n;
    
    // Tín hiệu đầu vào
    reg [8*2-1:0] i_data;
    reg i_valid;
    reg [15:0] weight_wr_data;
    reg [31:0] weight_wr_addr;
    reg weight_wr_en;
    
    // Tín hiệu đầu ra
    wire [8*4-1:0] o_data;
    wire o_valid;
    reg fifo_rd_en;
    
    // Mảng lưu trữ giá trị đầu vào/ra để theo dõi
    reg [8*2-1:0] input_data_array [0:IMAGE_SIZE-1];
    reg [8*4-1:0] output_data_array [0:IMAGE_SIZE-1];
    reg [15:0] weight_array [0:WEIGHT_COUNT-1];
    
    // Biến đếm và điều khiển
    integer i, output_count;
    reg [7:0] input_idx;

    // Khởi tạo DUT
    model uut (
        .o_data(o_data),
        .o_valid(o_valid),
        .fifo_rd_en(fifo_rd_en),
        .i_data(i_data),
        .i_valid(i_valid),
        .weight_wr_data(weight_wr_data),
        .weight_wr_addr(weight_wr_addr),
        .weight_wr_en(weight_wr_en),
        .clk(clk),
        .rst_n(rst_n)
    );
    
    // Khởi tạo xung clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;  // Clock 100MHz
    end
    
    // Khởi tạo các tín hiệu và dữ liệu thử nghiệm
    initial begin
        // Khởi tạo các tín hiệu
        rst_n = 0;
        i_data = 0;
        i_valid = 0;
        weight_wr_data = 0;
        weight_wr_addr = 0;
        weight_wr_en = 0;
        input_idx = 0;
        output_count = 0;
        
        // Tạo dữ liệu trọng số mẫu
        for (i = 0; i < WEIGHT_COUNT; i = i + 1) begin
            // Tạo các giá trị có quy luật để dễ kiểm tra
            if (i < 72) // Kernel weights: giá trị nhỏ, có mẫu
                weight_array[i] = 1;
            else if (i < 76) // Bias: giá trị trung bình
                weight_array[i] = 10;
            else // MACC coefficient: giá trị lớn hơn
                weight_array[i] = 16'h0100;
        end
        
        // Tạo dữ liệu đầu vào mẫu - pattern dễ nhận biết (gradient)
        for (i = 0; i < IMAGE_SIZE; i = i + 1) begin
            // 3 kênh có giá trị tăng dần theo vị trí pixel
            // input_data_array[i] = {8'd10 + (i % 5), 8'd20 + i, 8'd30 + i};
            input_data_array[i] = 100;
        end
        
        // Khởi tạo mảng đầu ra
        for (i = 0; i < IMAGE_SIZE; i = i + 1) begin
            output_data_array[i] = 0;
        end
        
        // Bắt đầu testbench
        $display("Bắt đầu testbench tại thời điểm %0t ns...", $time);
        
        // Reset module
        #(CLK_PERIOD*2);
        rst_n = 1;
        #(CLK_PERIOD);
        
        // Giai đoạn 1: Nạp trọng số
        $display("Giai đoạn 1: Nạp trọng số");
        
        for (i = 0; i < WEIGHT_COUNT; i = i + 1) begin
            @(posedge clk);
            weight_wr_en = 1;
            weight_wr_addr = i;
            weight_wr_data = weight_array[i];
            $display("Nạp trọng số %0d tại địa chỉ %0d: 0x%h", i, i, weight_array[i]);
        end
        
        @(posedge clk);
        weight_wr_en = 0;
        // Đợi vài chu kỳ để đảm bảo trọng số được nạp hoàn tất
        repeat(10) @(posedge clk);
        $stop;
        fifo_rd_en = 1;
        // Giai đoạn 2: Cung cấp dữ liệu đầu vào
        $display("Giai đoạn 2: Cung cấp dữ liệu đầu vào");
        for (i = 0; i < IMAGE_SIZE; i = i + 1) begin
            @(posedge clk);
            i_valid = 1;
            i_data = input_data_array[i];
            $display("Cung cấp dữ liệu đầu vào %0d: %0h", i, input_data_array[i]);
        end
        $finish;
    end

    
endmodule