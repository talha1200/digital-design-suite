module tb_async_fifo ();

  //--------------------------------
  // local parameter
  //--------------------------------
  localparam DATA_WIDTH = 8              ;
  localparam ADDR_WIDTH = 4              ;
  localparam DEPTH      = 1 << ADDR_WIDTH; // FIFO depth is 2^ADDR_WIDTH

  //--------------------------------
  // internal wire & reg
  //--------------------------------
  // Clocks
  logic wr_clk;
  logic rd_clk;
  // Reset signal
  logic rst;
  // FIFO signals
  logic                  wr_en    ;
  logic                  rd_en    ;
  logic [DATA_WIDTH-1:0] din      ;
  logic                  vaild_out;
  logic [DATA_WIDTH-1:0] dout     ;
  logic                  full     ;
  logic                  empty    ;
  // Internal signals for testbench
  logic [DATA_WIDTH-1:0] expected_data[DEPTH-1:0];
  logic [ADDR_WIDTH-1:0] write_count             ;
  logic [ADDR_WIDTH-1:0] read_count              ;
  int                    mismatch_cnt            ;

  //--------------------------------
  // implemetation
  //--------------------------------

  // Instantiate the asynchronous FIFO module
  async_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DEPTH     (DEPTH     )
  ) dut (
    .wr_clk   (wr_clk   ),
    .rd_clk   (rd_clk   ),
    .rst      (rst      ),
    .wr_en    (wr_en    ),
    .rd_en    (rd_en    ),
    .din      (din      ),
    .vaild_out(vaild_out),
    .dout     (dout     ),
    .full     (full     ),
    .empty    (empty    )
  );

  // Clock generation
  always #5 wr_clk = ~wr_clk;  // Write clock period of 10 ns (100 MHz)
  always #10 rd_clk = ~rd_clk; // Read clock period of 20 ns (50 MHz)

  // Testbench logic

  initial begin
    // Initialize signals
    wr_clk      = 0;
    rd_clk      = 0;
    wr_en       = 0;
    write_count = 0;
    mismatch_cnt = 0;
    rst         = 1; // Assert reset
    #50;
    rst         = 0;
  end

  initial begin
    wait(!rst);
    // Generate and send random data to DUT
    repeat (100) begin // Send 100 random data items
      @(posedge wr_clk);
      // Generate random data and send to DUT
      if (!full) begin
        din = $urandom_range(0, $urandom_range(0, (1 << DATA_WIDTH)-1));
        wr_en = 1;
        expected_data[write_count] = din; // Store data in expected_data
        write_count++;
      end
      else begin
        wr_en = 0;
      end
    end
  end

  initial begin
    wait(!rst);
    // Read data from DUT and compare with expected data
    repeat (100) begin // Read 100 data items
      @(posedge rd_clk);
      if (rd_en) begin
        if (dout !== expected_data[read_count]) begin
          $display("Data mismatch! Expected: %h, != Received: %h", expected_data[read_count], dout);
          mismatch_cnt++;
        end
        else begin
          $display("Data match! Expected: %h, ==  Received: %h", expected_data[read_count], dout);
        end
      end
    end
    // End simulation
    if (mismatch_cnt > 0) begin
      $display("TEST FAILED");
      $finish;
    end
    else begin
      $display("TEST PASSED");
      $finish;
    end
  end

  always_ff @(posedge rd_clk or posedge rst) begin
    if(rst) begin
      rd_en <= 0;
    end
    else begin
      if (!empty) begin
        rd_en <= 1'd1;
      end
      else begin
        rd_en <= 1'd0;
      end
    end
  end

  always_ff @(posedge rd_clk or posedge rst) begin
    if(rst) begin
      read_count <= 0;
    end
    else begin
      if (rd_en && vaild_out) begin
        read_count <= read_count + 1;
      end
      else begin
        read_count <= read_count;
      end
    end
  end

endmodule
