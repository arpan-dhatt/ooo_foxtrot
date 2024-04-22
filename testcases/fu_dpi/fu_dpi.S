.data
loop:
    .word 0x1234, 0x5678

data:
    .ascii "Hello, World!\0"

error_handler:
    .word 0xDEADBEEF

data_page:
    .word 0

function_page:
    .word 0

table_page:
    .word 0

.text
.global _start
_start:
    // MOVK
    MOVK X5, #0x1234
    MOVK X12, #0xABCD
    MOVK X20, #0x5678

    // MOVZ
    MOVZ X3, #0x1234
    MOVZ X8, #0xABCD
    MOVZ X15, #0x5678

    // ADR
    ADR X10, loop
    ADR X7, data
    ADR X18, error_handler

    // ADRP
    ADRP X2, data_page
    ADRP X9, function_page
    ADRP X14, table_page

    hlt #0