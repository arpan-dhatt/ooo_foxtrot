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
    // DPI
    // MOVZ
    MOVK X5, #0x1234, LSL #16
    MOVK X12, #0xABCD
    MOVK X20, #0x5678, LSL #48

    // MOVZ examples
    MOVZ X3, #0x1234, LSL #16
    MOVZ X8, #0xABCD
    MOVZ X15, #0x5678, LSL #32

    ADR X10, loop
    ADR X7, data
    ADR X18, error_handler

    ADRP X2, data_page
    ADRP X9, function_page
    ADRP X14, table_page

    // Arithmetic
    add x12, x5, #395
    add x12, x5, #-395
    adds x3, x20, x21

    sub x1, x3, #123
    sub x1, x3, #-123
    subs x3, x20, x21

    cmp x5, x3

    // LSU
    // LDP-STP no offset
    stp x10, x9, [x11, #0]
    ldp x10, x9, [x12, #0]

    // LDUR-STUR no offset
    stur x13, [x5, #0]
    ldur x13, [x5, #0]

    // Logical
    // CSEL
    csel x14, x11, x31, lt
    csel x14, x11, x12, mi
    csel x1, x2, x3, eq

    // CSINC
    cinc x4, x5, lt
    csinc x7, x8, x9, mi
    csinc x10, x11, x12, eq

    // CSINV
    csinv x25, x26, x27, mi
    csinv x28, x29, x30, eq

    // CSNEG
    csneg x9, x10, xZR, lt
    csneg x12, x13, x14, mi
    csneg x15, x16, x17, eq

    // MVN
    mvn x24, x25
    mvn x26, x27
    mvn x28, x29

    // ORR
    orr x0, x1, x31
    orr x3, x4, x5
    orr x6, x7, x8

    // EOR
    eor x9, x10, x11
    eor x12, x13, x14
    eor x15, x16, x17

    // AND
    and x18, x19, #0xFF
    and x20, x21, #0xF0
    and x22, x23, #0x0F

    // ANDS
    tst x23, x12
    ands x27, x28, x29
    ands x0, x1, x2

    // SBFM/ASR
    asr x12, x12, #4
    asr x12, x14, #8
    asr x12, x11, #1

    // UBFM/LSL/LSR
    lsl x14, x24, #4
    lsr x25, x11, #4
    lsl x21, x21, #3

    hlt #0