module top #(
    parameter WEIGHT_LIMIT = 99678 // 72 kernels + 4 biases + 1 macc_coeff
)(
    // AXI Stream
    input  wire [31:0] s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    
    // Weight interface: weight_wr_data, weight_wr_addr, weight_wr_en
    output  reg        [31:0] weight_wr_data,
    output  reg        [31:0] weight_wr_addr,
    output  reg        weight_wr_en,
    input  wire        clk,
    input  wire        rst_n,
    // Model if
    input       [31:0] s_axis_data_tdata,
    input       [31:0] s_axis_data_tvalid,
    output      [31:0] signal_out_data,
    output             signal_out_valid,
    output             fifo_rd_en
);
    reg [31:0] weight_count;
    reg tready;
    assign s_axis_tready = tready;

    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          weight_count <= 0;
          weight_wr_en <= 0;
          weight_wr_data <= 0;
          weight_wr_addr <= 0;
          tready <= 0;
      end else begin
        if (weight_count > WEIGHT_LIMIT - 1) begin
//          weight_count <= 0;
          tready <= 0;
        end else begin
          tready <= 1;
        end
        if (s_axis_tvalid && tready) begin
          weight_wr_data <= s_axis_tdata;
          weight_wr_addr <= weight_count;
          weight_wr_en <= 1;
          weight_count <= weight_count + 1;
        end else begin
          weight_wr_en <= 0;
        end
      end
    end

    model aplr_model(
      .clk            (clk),
      .rst_n          (rst_n),
      .i_data         (s_axis_data_tdata),
      .i_valid        (s_axis_data_tvalid),
      .weight_wr_data (weight_wr_data),
      .weight_wr_addr (weight_wr_addr),
      .weight_wr_en   (weight_wr_en),
      .o_data         (signal_out_data),
      .o_valid        (signal_out_valid),
      .fifo_rd_en     (fifo_rd_en)
    );



endmodule
