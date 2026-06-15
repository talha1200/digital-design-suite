///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2026 Talha Mahboob
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module tb_bch ();

  //---------------------
  // Testbench parameters
  //---------------------

  localparam int N           = 26 ;
  localparam int K           = 16 ;
  localparam int T           = 2  ;
  localparam int GF_WIDTH    = 5  ;
  localparam int MAX_VECTORS = 1024; // upper bound; actual count read from file

  //---------------------
  // DUT stimulus (bit — we drive these; X impossible)
  //---------------------

  bit [K-1:0] i_data   ;
  bit [N-1:0] i_rx_word;

  //---------------------
  // DUT outputs (logic — preserve X from DUT into checker)
  //---------------------

  logic [N-1:0] o_codeword    ;
  logic [K-1:0] o_data        ;
  logic         o_uncorrectable;

  //---------------------
  // Vector storage (logic — catch any X loaded from file)
  //---------------------

  logic [K-1:0] vec_data         [0:MAX_VECTORS-1];
  logic [N-1:0] vec_codeword     [0:MAX_VECTORS-1];
  logic [N-1:0] vec_rx           [0:MAX_VECTORS-1];
  logic [K-1:0] vec_expected_data[0:MAX_VECTORS-1];
  logic         vec_uncorrectable[0:MAX_VECTORS-1];
  int           vec_error_count  [0:MAX_VECTORS-1];
  int           vec_actual_count ;

  //---------------------
  // Separate encoder / decoder scoreboards
  //---------------------

  int enc_pass, enc_fail;
  int dec_pass, dec_fail;

  //---------------------
  // DUT instantiation
  //---------------------

  bch_encoder #(
    .N       (N       ),
    .K       (K       ),
    .T       (T       ),
    .GF_WIDTH(GF_WIDTH)
  ) u_enc (
    .i_data    (i_data    ),
    .o_codeword(o_codeword)
  );

  bch_decoder #(
    .N       (N       ),
    .K       (K       ),
    .T       (T       ),
    .GF_WIDTH(GF_WIDTH)
  ) u_dec (
    .i_rx_word      (i_rx_word      ),
    .o_data         (o_data         ),
    .o_uncorrectable(o_uncorrectable)
  );

  //---------------------
  // Watchdog — both DUTs are combinational; 1 ms is orders of magnitude
  // more than needed and exists only to catch an unexpected $finish miss.
  //---------------------

  initial begin
    #1ms;
    $fatal(1, "TIMEOUT: simulation did not finish within 1 ms");
  end

  //---------------------
  // Vector loader — reads until EOF so VECTOR_COUNT in the model and the
  // TB are decoupled. longint scan buffers future-proof for N > 32.
  //---------------------

  task automatic load_vectors;
    int     fd, rc;
    longint data_val, codeword_val, rx_val, expected_val;
    int     uncorrectable_val, error_count_val;
    begin
      fd = $fopen("vectors/bch_vectors.txt", "r");
      if (fd == 0)
        $fatal(1, "cannot open vectors/bch_vectors.txt — run: python3 scripts/gen_vectors.py");

      vec_actual_count = 0;
      while (!$feof(fd) && (vec_actual_count < MAX_VECTORS)) begin
        rc = $fscanf(fd, "%h %h %h %h %d %d\n",
                     data_val, codeword_val, rx_val, expected_val,
                     uncorrectable_val, error_count_val);
        if (rc != 6) break;
        vec_data[vec_actual_count]          = data_val[K-1:0];
        vec_codeword[vec_actual_count]      = codeword_val[N-1:0];
        vec_rx[vec_actual_count]            = rx_val[N-1:0];
        vec_expected_data[vec_actual_count] = expected_val[K-1:0];
        vec_uncorrectable[vec_actual_count] = uncorrectable_val[0];
        vec_error_count[vec_actual_count]   = error_count_val;
        vec_actual_count++;
      end
      $fclose(fd);
      $display("loaded %0d vectors from vectors/bch_vectors.txt", vec_actual_count);
    end
  endtask

  //---------------------
  // Main test sequence
  //---------------------

  initial begin
    load_vectors();
    i_data    = '0;
    i_rx_word = '0;
    enc_pass  = 0; enc_fail = 0;
    dec_pass  = 0; dec_fail = 0;

    for (int i = 0; i < vec_actual_count; i++) begin
      i_data    = vec_data[i];
      i_rx_word = vec_rx[i];
      #1; // let combinational paths settle

      // --- Encoder check ---
      if (o_codeword !== vec_codeword[i]) begin
        $display("ENC FAIL[%0d] data=0x%0h  exp_cw=0x%0h  got_cw=0x%0h",
                 i, vec_data[i], vec_codeword[i], o_codeword);
        enc_fail++;
      end else begin
        enc_pass++;
      end

      // --- Decoder check ---
      if (o_uncorrectable !== vec_uncorrectable[i]) begin
        $display("DEC FAIL[%0d] rx=0x%0h errors=%0d  exp_unc=%0b  got_unc=%0b",
                 i, vec_rx[i], vec_error_count[i],
                 vec_uncorrectable[i], o_uncorrectable);
        dec_fail++;
      end else if (!vec_uncorrectable[i] && (o_data !== vec_expected_data[i])) begin
        $display("DEC FAIL[%0d] rx=0x%0h errors=%0d  exp_data=0x%0h  got_data=0x%0h",
                 i, vec_rx[i], vec_error_count[i],
                 vec_expected_data[i], o_data);
        dec_fail++;
      end else begin
        dec_pass++;
      end
    end

    $display("=== BCH enc: PASS=%0d FAIL=%0d  |  dec: PASS=%0d FAIL=%0d ===",
             enc_pass, enc_fail, dec_pass, dec_fail);
    if ((enc_fail + dec_fail) == 0)
      $display("ALL TESTS PASSED");
    else
      $fatal(1, "BCH test FAILED");

    $finish;
  end

endmodule : tb_bch
