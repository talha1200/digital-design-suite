# Double-Precision Floating Point Square Root Algorithm

## Overview

This project implements a square root calculation for double-precision floating point numbers based on the IEEE-754 format using the **binary long division method**. The SystemVerilog module calculates the square root of a given input number by normalizing its mantissa and exponent, and performing bitwise operations to iteratively compute the result.

## Table of Contents

- [Introduction](#introduction)
- [IEEE-754 Double Precision](#ieee-754-double-precision)
- [Algorithm](#algorithm)
  - [Step-by-step Explanation](#step-by-step-explanation)
  - [Normalization](#normalization)
  - [Square Root Calculation](#square-root-calculation)
- [Implementation](#implementation)
- [Mistakes and Issues](#mistakes-and-issues)
- [Conclusion](#conclusion)

## Introduction

This module computes the square root of a 64-bit double-precision floating point number. The square root operation is fundamental in various scientific and mathematical computations. The algorithm used in this implementation follows a **binary long division method**, which iteratively processes each bit of the input's mantissa to approximate the square root.

## IEEE-754 Double Precision

Double-precision floating point format in the IEEE-754 standard is represented by 64 bits, divided into three main components:

1. **Sign Bit** (1 bit): Determines if the number is positive or negative.
2. **Exponent** (11 bits): Encodes the exponent value with a bias of 1023.
3. **Mantissa (Fraction)** (52 bits): Represents the significant digits (fractional part) of the number.

The value of a double-precision number is expressed as:

\[ \text{Value} = (-1)^{\text{sign}} \times (1 + \text{mantissa}) \times 2^{\text{exponent} - 1023} \]

## Algorithm

### Step-by-step Explanation

1. **Extract Mantissa and Exponent**: The floating-point number is broken down into its constituent parts—sign, exponent, and mantissa.
  
2. **Normalization**: The mantissa is normalized, and the exponent is adjusted. The normalization ensures that the input value lies within a specific range that simplifies the square root computation.

3. **Binary Long Division Method**: 
   - The algorithm operates bit-by-bit on the mantissa.
   - It mimics long division where each bit of the result is determined iteratively by trial and error.
   - This method shifts and subtracts to approximate the square root of the mantissa.

4. **Exponent Adjustment**: After the square root is computed, the exponent is divided by 2 to reflect the change in the magnitude of the square root value.

### Normalization

The first step is to normalize the input number. This involves adjusting the mantissa so that the most significant bit is non-zero. Simultaneously, the exponent is adjusted to account for the normalization.

The normalization ensures that the input mantissa lies between 0.5 and 1, a range suitable for applying the square root algorithm.

### Square Root Calculation

After normalization, the square root is calculated using the **binary long division method**. In this iterative process:

- Each bit of the mantissa is inspected and shifted accordingly.
- The algorithm tests whether adding a bit to the result would keep it within the bounds of the square root calculation.
- The result is built bit-by-bit.

Once the square root of the mantissa is calculated, the exponent is divided by 2 to complete the result. Finally, the computed mantissa and adjusted exponent are combined to produce the final square root result.

## Implementation

The provided SystemVerilog file consists of several key modules:

1. **Mantissa Normalization**: 
   - This module normalizes the mantissa by shifting bits until the leading bit is non-zero.
   - It adjusts the exponent accordingly.

2. **Shifter Module**:
   - Handles bitwise shifts and calculations necessary for the binary division method of calculating the square root.
   - Based on the position of the leading bit in the mantissa, it shifts and adjusts the value iteratively.

3. **Exponent Calculation**:
   - Adjusts the exponent as per the IEEE-754 rules by dividing the original exponent by 2 after normalization.

4. **Square Root Approximation**:
   - This module computes the square root using the binary division method.
   - Each bit of the mantissa is processed and added to the result if it satisfies the square root condition.

## Areas for Improvement

1. **Complexity of Shifting Logic**:
   - The shifting logic in the mantissa normalization step can be simplified using a more efficient loop-based approach rather than a case statement. This would reduce code redundancy and improve readability.

2. **Edge Case Handling**:
   - Some edge cases, such as denormalized numbers (where the exponent is 0), are not explicitly handled. Handling these cases would improve robustness.

3. **Overflow and Underflow Conditions**:
   - There should be explicit checks for overflow and underflow when adjusting the exponent, especially for inputs that are too large or too small.

4. **Sign Handling**:
   - The code doesn't seem to handle negative inputs properly. The square root of a negative number in the real domain is undefined and should result in a NaN (Not a Number) according to IEEE-754.

5. **Rounding Precision**:
   - Rounding precision may need further optimization. The algorithm approximates the square root bit-by-bit, but there may be small errors in the least significant bits due to the limitations of binary representation.

## Conclusion

The SystemVerilog code implements a double-precision floating point square root function using a binary long division method. While the basic algorithm is correct, improvements can be made to the code's structure and edge case handling. This implementation serves as a good basis for FPGA and hardware-level computation of square roots, but further optimizations could make it more efficient and robust.
