.data
values:
    .word 0x1234, 0x5678, 0xABCD, 0xEF01

result:
    .word 0

.text
.global _start
_start:
    // Load the base address of the 'values' array into X0
    ADR X0, values

    // Load the first two values using LDUR
    LDUR W1, [X0, #0]
    LDUR W2, [X0, #4]

    // Load the next two values using LDP
    LDP W3, W4, [X0, #8]

    // Reduce the values hierarchically
    ADD W5, W1, W2
    ADD W6, W3, W4
    ADD W7, W5, W6

    // Store the final result using STUR
    ADR X8, result
    STUR W7, [X8, #0]

    // End of the test program
    hlt #0