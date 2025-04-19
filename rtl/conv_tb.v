`timescale 1ns / 1ps

module conv_tb;

    // Parameters
    localparam CLK_PERIOD = 10;  // 100MHz
    
    // Conv parameters (giữ nhỏ để dễ kiểm tra)
    localparam IN_WIDTH     = 8;
    localparam IN_HEIGHT    = 8;
    localparam KERNEL_0     = 3;
    localparam KERNEL_1     = 3;
    localparam DILATION_0   = 1;
    localparam DILATION_1   = 1;
    localparam PADDING_0    = 1;
    localparam PADDING_1    = 1;
    localparam STRIDE_0     = 1;
    localparam STRIDE_1     = 1;
    localparam IN_CHANNEL   = 2;
    localparam OUT_CHANNEL  = 2;
    localparam OUTPUT_MODE  = "relu";
    localparam UNROLL_MODE  = "incha";
    localparam COMPUTE_FACTOR = "single";

    // Tính toán kích thước đầu ra
    localparam OUT_WIDTH  = (IN_WIDTH + 2*PADDING_0 - DILATION_0*(KERNEL_0-1) - 1) / STRIDE_0 + 1;
    localparam OUT_HEIGHT = (IN_HEIGHT + 2*PADDING_1 - DILATION_1*(KERNEL_1-1) - 1) / STRIDE_1 + 1;
    
    // Weight address map
    localparam KERNEL_BASE_ADDR      = 0;
    localparam BIAS_BASE_ADDR        = KERNEL_BASE_ADDR + KERNEL_0 * KERNEL_1 * IN_CHANNEL * OUT_CHANNEL;
    localparam MACC_COEFF_BASE_ADDR  = BIAS_BASE_ADDR + OUT_CHANNEL;
    localparam LAYER_SCALE_BASE_ADDR = MACC_COEFF_BASE_ADDR + 1;

    // Signals
    reg                               clk;
    reg                               rst_n;
    reg [8*IN_CHANNEL-1:0]           i_data;
    reg                              i_valid;
    reg                              fifo_almost_full;
    reg [31:0]                       weight_wr_data;
    reg [31:0]                       weight_wr_addr;
    reg                              weight_wr_en;
    
    wire [8*OUT_CHANNEL-1:0]         o_data;  // Đầu ra relu là 8-bit
    wire                             o_valid;
    wire                             fifo_rd_en;

    // Bộ đếm và flags
    integer                          i, j, k, c, oc;
    reg                              weights_loaded;
    reg [8*IN_CHANNEL-1:0]           test_data_buffer[0:IN_HEIGHT*IN_WIDTH-1];
    integer                          data_idx;
    integer                          cycle_count;
    integer                          output_count;

    // Khởi tạo UUT
    conv #(
        .IN_WIDTH(IN_WIDTH),
        .IN_HEIGHT(IN_HEIGHT),
        .OUTPUT_MODE(OUTPUT_MODE),
        .UNROLL_MODE(UNROLL_MODE),
        .COMPUTE_FACTOR(COMPUTE_FACTOR),
        .KERNEL_0(KERNEL_0),
        .KERNEL_1(KERNEL_1),
        .DILATION_0(DILATION_0),
        .DILATION_1(DILATION_1),
        .PADDING_0(PADDING_0),
        .PADDING_1(PADDING_1),
        .STRIDE_0(STRIDE_0),
        .STRIDE_1(STRIDE_1),
        .IN_CHANNEL(IN_CHANNEL),
        .OUT_CHANNEL(OUT_CHANNEL),
        .KERNEL_BASE_ADDR(KERNEL_BASE_ADDR),
        .BIAS_BASE_ADDR(BIAS_BASE_ADDR),
        .MACC_COEFF_BASE_ADDR(MACC_COEFF_BASE_ADDR),
        .LAYER_SCALE_BASE_ADDR(LAYER_SCALE_BASE_ADDR)
    ) uut (
        .o_data(o_data),
        .o_valid(o_valid),
        .fifo_rd_en(fifo_rd_en),
        .i_data(i_data),
        .i_valid(i_valid),
        .fifo_almost_full(fifo_almost_full),
        .weight_wr_data(weight_wr_data),
        .weight_wr_addr(weight_wr_addr),
        .weight_wr_en(weight_wr_en),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock
    always begin
        #(CLK_PERIOD/2) clk = ~clk;
    end

    // Giám sát đầu ra
    always @(posedge clk) begin
        if (o_valid) begin
            $display("Output cycle %0d: o_data = %h", output_count, o_data);
            output_count = output_count + 1;
        end
    end

    // Test sequence
    initial begin
        // Khởi tạo
        clk = 0;
        rst_n = 0;
        i_data = 0;
        i_valid = 0;
        fifo_almost_full = 0;
        weight_wr_data = 0;
        weight_wr_addr = 0;
        weight_wr_en = 0;
        weights_loaded = 0;
        data_idx = 0;
        cycle_count = 0;
        output_count = 0;
        
        // Điền buffer dữ liệu thử nghiệm với pattern dễ dàng nhận biết
        // Kênh 1: pattern 1, 2, 3, ...
        // Kênh 2: pattern 10, 20, 30, ...
        for (i = 0; i < IN_HEIGHT; i = i + 1) begin
            for (j = 0; j < IN_WIDTH; j = j + 1) begin
                test_data_buffer[i*IN_WIDTH+j][7:0] = i*IN_WIDTH + j + 1;                // Kênh 1
                test_data_buffer[i*IN_WIDTH+j][15:8] = (i*IN_WIDTH + j + 1) * 1;        // Kênh 2
            end
        end

        // Reset
        #(CLK_PERIOD*5);
        rst_n = 1;
        #(CLK_PERIOD*5);
        
        // Nạp trọng số
        $display("Loading weights...");
        
        // Nạp kernel (3x3x2x2 = 36 trọng số)
        // Kernel đơn giản: tất cả trọng số là 1 cho kernel đầu tiên, 2 cho kernel thứ hai
        for (oc = 0; oc < OUT_CHANNEL; oc = oc + 1) begin
            for (c = 0; c < IN_CHANNEL; c = c + 1) begin
                for (i = 0; i < KERNEL_0; i = i + 1) begin
                    for (j = 0; j < KERNEL_1; j = j + 1) begin
                        @(posedge clk);
                        weight_wr_addr = KERNEL_BASE_ADDR + oc * (KERNEL_0 * KERNEL_1 * IN_CHANNEL) 
                                        + c * (KERNEL_0 * KERNEL_1) + i * KERNEL_1 + j;
                        if (oc == 0) weight_wr_data = i*3 + j;  // -1 cho kênh đầu ra 0,
                        if (oc == 1) weight_wr_data = i*3 + j + 9;  //  2 cho kênh đầu ra 1

                        weight_wr_en = 1;
                        //#CLK_PERIOD;
                    end
                end
            end
        end
        
        
        
        repeat (10) @(posedge clk);
        weight_wr_en = 0;
        @(posedge clk);
        
        
        
        
        // Nạp bias (2 giá trị)
        for (i = 0; i < OUT_CHANNEL; i = i + 1) begin
            @(posedge clk);
            weight_wr_addr = BIAS_BASE_ADDR + i;
            weight_wr_data = 32'h0001_0000;  // bias = 16
            weight_wr_en = 1;
            //#CLK_PERIOD;
        end
        
//        @(posedge clk);
//        @(posedge clk);
//        @(posedge clk);
//        weight_wr_en = 0;
        
//        $stop;
        // Nạp MACC coeff (1 giá trị)

        @(posedge clk);
        weight_wr_en = 0;
        @(posedge clk);

        weight_wr_addr = MACC_COEFF_BASE_ADDR;
        weight_wr_data = 16'h8000;  // coeff = 0.5 (nhân 256)
        weight_wr_en = 1;
        #CLK_PERIOD;
        
        // Nạp layer scale (1 giá trị)
        @(posedge clk);
        weight_wr_addr = LAYER_SCALE_BASE_ADDR;
        weight_wr_data = 16'h0800;  // scale = 1.0 (nhân 256)
        weight_wr_en = 1;
        #CLK_PERIOD;
        
        weight_wr_en = 0;
        weights_loaded = 1;
        
        $display("Weights loaded successfully!");
        
        // Gửi dữ liệu đầu vào
        $display("Sending input data...");
        
        // Trễ một chút trước khi gửi dữ liệu
        #(CLK_PERIOD*10);
        // test
        @(posedge clk);
        // Chỉ gửi dữ liệu khi FIFO không gần đầy và chỉ đọc khi được cho phép
        if (!fifo_almost_full && (data_idx < IN_HEIGHT*IN_WIDTH)) begin
            i_data = 16'h5555;
            i_valid = 1;
        end else begin
            i_valid = 0;
        end

        // Gửi dữ liệu từ buffer
        for (i = 0; i < IN_HEIGHT; i = i + 1) begin
            for (j = 0; j < IN_WIDTH; j = j + 1) begin
                @(posedge clk);
                // Chỉ gửi dữ liệu khi FIFO không gần đầy và chỉ đọc khi được cho phép
                if (!fifo_almost_full && (data_idx < IN_HEIGHT*IN_WIDTH)) begin
                    i_data = test_data_buffer[data_idx];
                    i_valid = 1;
                    data_idx = data_idx + 1;
                end else begin
                    i_valid = 0;
                end
                
//                // Mô phỏng FIFO gần đầy với xác suất thấp
//                if ($random % 20 == 0) fifo_almost_full = 1;
//                else fifo_almost_full = 0;
            end
        end
        
        // Tắt tín hiệu hợp lệ sau khi gửi hết dữ liệu
        i_valid = 0;
        
        // Chờ đủ thời gian để xử lý hoàn tất
        #(CLK_PERIOD*200);
        
        // Kết thúc mô phỏng
        $display("Simulation completed. %0d output values observed", output_count);
        $finish;
    end

    // Giám sát tín hiệu fifo_rd_en
    always @(posedge clk) begin
        if (fifo_rd_en)
            $display("FIFO read enabled at cycle %0d", cycle_count);
    end

    // Đếm chu kỳ
    always @(posedge clk) begin
        cycle_count = cycle_count + 1;
    end

endmodule