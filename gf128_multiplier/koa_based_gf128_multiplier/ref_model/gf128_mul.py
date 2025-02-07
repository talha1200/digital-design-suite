def gf128_mul(x, y):
    ''' Multiplication in GF(2^128). 
    The caller specifies the irreducible polynomial.
    '''
    # Irreducible polynomial for GF(2^128) arithmetic
    # This polynomial is x^128 + x^7 + x^2 + x + 1, represented in hexadecimal as 0xE1000000000000000000000000000000
    # The polynomial is chosen because it is irreducible, meaning it cannot be factored into smaller polynomials over GF(2).
    # This ensures that every non-zero element has a multiplicative inverse, making the field a proper finite field.
    R =  0xE1000000000000000000000000000000 # irreducible polynomial

    z = 0  # Initialize the result to 0
    for i in range(127, -1, -1):  # Iterate over each bit of y from MSB to LSB
        # If the i-th bit of y is 1, XOR z with x (this is equivalent to adding x to z in GF(2))
        z ^= x * ((y >> i) & 1)
        # Shift x to the right by 1 bit. If the least significant bit (LSB) of x was 1, XOR x with the irreducible polynomial R.
        # This ensures that x remains within the field defined by the polynomial R.
        x = (x >> 1) ^ ((x & 1) * R)
    return z  # Return the result of the multiplication

def gf128_mul_test():
    ''' Xn * Yn (mod R) = Zn
    R = 0xE1000000000000000000000000000000
    X1 = [0388dace60b6a392f328c2b971b2fe78]
    Y1 = [66e94bd4ef8a2c3b884cfa59ca342b2e]
    Z1 = [5e2ec746917062882c85b0685353deb7]
    X2 = [5e2ec746917062882c85b0685353de37]
    Y2 = [66e94bd4ef8a2c3b884cfa59ca342b2e]
    Z2 = [f38cbb1ad69223dcc3457ae5b6b0f885]
    X3 = [ba471e049da20e40495e28e58ca8c555]
    Y3 = [b83b533708bf535d0aa6e52980d53b78]
    Z3 = [b714c9048389afd9f9bc5c1d4378e052]
    '''

    # Test cases for the GF(2^128) multiplication
    test_cases = [
        (0x0388dace60b6a392f328c2b971b2fe78, 0x66e94bd4ef8a2c3b884cfa59ca342b2e, 0x5e2ec746917062882c85b0685353deb7),
        (0x5e2ec746917062882c85b0685353de37, 0x66e94bd4ef8a2c3b884cfa59ca342b2e, 0xf38cbb1ad69223dcc3457ae5b6b0f885),
        (0xba471e049da20e40495e28e58ca8c555, 0xb83b533708bf535d0aa6e52980d53b78, 0xb714c9048389afd9f9bc5c1d4378e052),
        (0x66e94bd4ef8a2c3b884cfa59ca342b2e, 0xff000000000000000000000000000000, 0x679d3cea2db93be5228724c2e2abea06)
    ]

    for i, (x, y, expected) in enumerate(test_cases, 1):
        result = gf128_mul(x, y)
        print(f"Test case {i}:")
        print(f"Input X: {x:032x}")
        print(f"Input Y: {y:032x}")
        print(f"Expected Z: {expected:032x}")
        print(f"Output Z: {result:032x}")
        assert result == expected, f"Test case {i} failed"
        print("Test passed.\n")
    
if __name__ == "__main__":
    gf128_mul_test()