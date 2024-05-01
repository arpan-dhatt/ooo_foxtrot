.data
values:
    .quad 0x1, 0x2
    .quad 0x3, 0x4
    .quad 0x5, 0x6
    .quad 0x7, 0x8

result:
    .quad 0

.text
.global _start
_start:
    // Load the base address of the 'values' array into X0
    ADR X0, values

    // Load the first pair of values using LDP
    LDP X1, X2, [X0, #0]

    // Load the second pair of values using LDP
    LDP X3, X4, [X0, #16]

    // Load the third pair of values using LDP
    LDP X5, X6, [X0, #32]

    // Load the fourth pair of values using LDP
    LDP X7, X8, [X0, #48]

    // Perform the first level of reduction
    ADDS X9, X1, X2
    ADDS X10, X3, X4
    ADDS X11, X5, X6
    ADDS X12, X7, X8

    // Perform the second level of reduction
    ADDS X13, X9, X10
    ADDS X14, X11, X12

    // Perform the final reduction
    ADDS X15, X13, X14

    // Store the final result using STUR
    ADR X16, result
    STUR X15, [X16, #0]

    // End of the test program
    hlt #0