package gf_128_pkg;
  
  //----------------
  // Function: reverse_128
  // Description: Reverse bit order in a 128-bit word.
  //----------------
  function automatic logic [127:0] reverse_128(input logic [127:0] in);
    integer i;
    begin
      for(i = 0; i < 128; i=i+1)
        reverse_128[i] = in[127-i];
    end
  endfunction


  //----------------
  // Function: gf_reduce
  // Description:
  //   Reduce a 256-bit product modulo the irreducible polynomial
  //      x^128 + x^7 + x^2 + x + 1
  //   (Again, the arithmetic is over GF(2), so subtraction is XOR.)
  //----------------
  function automatic logic [127:0] gf_reduce (
    input logic [255:0] p
  );
    logic [255:0] r;
    integer i;
    begin
      r = p;
      // Process bits from highest (bit 255) down to bit 128.
      for(i = 255; i >= 128; i=i-1) begin
        if(r[i]) begin
          // Clear the high bit and XOR the irreducible polynomial (except the x^128 term)
          r[i] = 1'b0;
          r[i - 128]     = r[i - 128]     ^ 1'b1;  // coefficient for x^0
          r[i - 128 + 1] = r[i - 128 + 1] ^ 1'b1;  // coefficient for x^1
          r[i - 128 + 2] = r[i - 128 + 2] ^ 1'b1;  // coefficient for x^2
          r[i - 128 + 7] = r[i - 128 + 7] ^ 1'b1;  // coefficient for x^7
        end
      end
      gf_reduce = r[127:0];
    end
  endfunction

endpackage : gf_128_pkg