`timescale 1ns / 1ps

module model_test_tb;

    // Parameters
    localparam CLK_PERIOD = 10;  // 100MHz
    
    // Conv parameters (giữ nhỏ để dễ kiểm tra)
    localparam IN_WIDTH     = 256;
    localparam IN_HEIGHT    = 256;
    localparam PIXELS = IN_WIDTH*IN_HEIGHT;
    // Conv param
    localparam KERNEL_0_0     = 3;
    localparam KERNEL_1_0     = 3;
    localparam IN_CHANNEL_0   = 3;
    localparam OUT_CHANNEL_0  = 16;
                                 
    localparam KERNEL_0_1     = 1;
    localparam KERNEL_1_1     = 1;
    localparam IN_CHANNEL_1   = 2;
    localparam OUT_CHANNEL_1  = 4;
                                 
    localparam KERNEL_0_2     = 3;
    localparam KERNEL_1_2     = 3;
    localparam IN_CHANNEL_2   = 4;
    localparam OUT_CHANNEL_2  = 2;
                                 
    localparam KERNEL_0_3     = 1;
    localparam KERNEL_1_3     = 1;
    localparam IN_CHANNEL_3   = 2;
    localparam OUT_CHANNEL_3  = 2;


    // Tính toán kích thước đầu ra
    //localparam OUT_WIDTH  = (IN_WIDTH + 2*PADDING_0 - DILATION_0*(KERNEL_0-1) - 1) / STRIDE_0 + 1;
    //localparam OUT_HEIGHT = (IN_HEIGHT + 2*PADDING_1 - DILATION_1*(KERNEL_1-1) - 1) / STRIDE_1 + 1;
    
    // Signals
    reg                              clk;
    reg                              rst_n;
    reg [8*IN_CHANNEL_0-1:0]         i_data;
    reg                              i_valid;
    reg                              fifo_almost_full;
    reg [31:0]                       weight_wr_data;
    reg [31:0]                       weight_wr_addr;
    reg                              weight_wr_en;
    
    wire [8*OUT_CHANNEL_3-1:0]       o_data;  // Đầu ra relu là 8-bit
    wire                             o_valid;
    wire                             fifo_rd_en;

    // Bộ đếm và flags
    integer                          i, j, k, c, oc;
    reg                              weights_loaded;
    reg [8*3-1:0]                    test_data_buffer[0:IN_HEIGHT*IN_WIDTH-1];
    integer                          data_idx;
    integer                          cycle_count;
    integer                          output_count;
    //
integer fd, scan_cnt, idx;
integer r0, r1, r2;

    // Khởi tạo UUT
    model dut
     (
       .clk                  (clk),                  
       .rst_n                (rst_n), 
       .i_data               (i_data),               
       .i_valid              (i_valid),   
       .cls_almost_full      (),   
       .vertical_almost_full (), 
       .weight_wr_data       (weight_wr_data),   
       .weight_wr_addr       (weight_wr_addr),   
       .weight_wr_en         (weight_wr_en),   
       .o_data_cls           (),   
       .o_data_vertical      (),   
       .o_valid_cls          (),
       .o_valid_vertical     (),
       .fifo_rd_en           (fifo_rd_en)
    );
    // fifo_rd_en,          Clock
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
////////////////////////////////////////////////////////////////////////////////////
        // Điền buffer dữ liệu thử nghiệm với pattern dễ dàng nhận biết
        // to do test_data_buffer


///////////////////////////////////////////////////////////////////////////////////
        // Reset
        #(CLK_PERIOD*5);
        rst_n <= 1;
        #(CLK_PERIOD*5);
        
        // Nạp trọng số
        $display("Loading weights...");
        // to do
        //----------------- Conv_0 Nạp kernel (3x3x3x16 = 432 trọng số) --------
        //--------------------------------------------------------------------
        fd = $fopen("/home/tuananh/alpr/QuantLaneNet_original/DA/final_detect_model/try3_minimal/conv0_kernel_hex.txt", "r");
        if (fd == 0) begin
            $display("ERROR: Không mở được file conv0_kernel_hex.txt");
            $finish;
        end
        for (oc = 0; oc < OUT_CHANNEL_0; oc = oc + 1) begin
            for (i = 0; i < KERNEL_0_0; i = i + 1) begin
                for (j = 0; j < KERNEL_1_0; j = j + 1) begin
                    for (c = 0; c < IN_CHANNEL_0; c = c + 1) begin
                        @(posedge clk);
                        weight_wr_addr <= 0 + oc * (KERNEL_0_0 * KERNEL_1_0 * IN_CHANNEL_0) 
                                        + i * (IN_CHANNEL_0 * KERNEL_1_0) + j * IN_CHANNEL_0 + c;
                        scan_cnt <= $fscanf(fd, "%h\n", r0);
                        weight_wr_data <= {{24{r0[7]}} ,r0[7:0]};

                        weight_wr_en <= 1;
                        //#CLK_PERIOD;
                    end
                end
            end
        end
   
        
        // Nạp bias conv_0 (2 giá trị)
        @(posedge clk);
        weight_wr_en <= 0;
        @(posedge clk);
        
        fd = $fopen("/home/tuananh/alpr/QuantLaneNet_original/DA/final_detect_model/try3_minimal/conv0_bias_hex.txt", "r");
        if (fd == 0) begin
            $display("ERROR: Không mở được file conv0_bias_hex.txt");
            $finish;
        end
        for (i = 0; i < OUT_CHANNEL_0; i = i + 1) begin
            @(posedge clk);
            weight_wr_addr <= 3*3*3*16 + i;
            scan_cnt <= $fscanf(fd, "%h\n", r0);
            weight_wr_data <= {r0[31:0]};  // bias = 1
            weight_wr_en <= 1;
            //#CLK_PERIOD;
        end

        // Nạp MACC coeff conv_0 (1 giá trị)
        @(posedge clk);
        weight_wr_en <= 0;
        @(posedge clk);

        weight_wr_addr <= 3*3*3*16 + 16;
        weight_wr_data <= 32'h0000_00AB;  // coeff = 0.5 (nhân 256)
        weight_wr_en <= 1;
        @(posedge clk);
        
        
        weight_wr_en <= 0;
        weights_loaded <= 1;
        
        $display("Weights loaded successfully!");
        
        // Gửi dữ liệu đầu vào
        $display("Sending input data...");
        

///////////////////////////////////////////////////////////////////////////////////////////

fd = $fopen("/home/tuananh/alpr/QuantLaneNet_original/DA/final_detect_model/try3_minimal/input_int8.txt", "r");
if (fd == 0) begin
    $display("ERROR: Không mở được file input_int8.txt");
    $finish;
end
for (idx = 0; idx < PIXELS; idx = idx + 1) begin
    scan_cnt = $fscanf(fd, "%d,%d,%d\n", r0, r1, r2);
    // Ghép lại thành {ch0, ch1, ch2}
    test_data_buffer[idx] = { r0[7:0], r1[7:0], r2[7:0] };
end
$fclose(fd);

        // Trễ một chút trước khi gửi dữ liệu
        #(CLK_PERIOD*10);
        // test
        @(posedge clk);
        // Chỉ gửi dữ liệu khi FIFO không gần đầy và chỉ đọc khi được cho phép
        if (!fifo_almost_full && (data_idx < IN_HEIGHT*IN_WIDTH)) begin
            i_data = 24'h55_5555;
            i_valid = 1;
        end else begin
            i_valid = 0;
        end

  while (data_idx < IN_HEIGHT*IN_WIDTH) begin
    @(posedge clk);
    if (fifo_rd_en) begin
      if (!fifo_almost_full) begin
        i_data      = test_data_buffer[data_idx];
        i_valid     = 1;
        data_idx    = data_idx + 1;
      end
      else begin
        i_valid = 0;
      end
    end
    else begin
      //i_valid = 0;
   
    end
  end

/////////////////////////////////////////////////////////////////////////////////////////////    
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
