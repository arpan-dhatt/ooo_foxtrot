.text
.global _start
_start:
    // CSEL
    csel x14, x11, x12, lt
    csel x14, x11, x12, mi
    csel x1, x2, x3, eq

    // CSINC
    csinc x4, x5, x6, lt
    csinc x7, x8, x9, mi
    csinc x10, x11, x12, eq

    // CSINV
    csinv x22, x23, x24, lt
    csinv x25, x26, x27, mi
    csinv x28, x29, x30, eq

    // CSNEG
    csneg x9, x10, x11, lt
    csneg x12, x13, x14, mi
    csneg x15, x16, x17, eq

    // MVN
    mvn x24, x25
    mvn x26, x27
    mvn x28, x29

    // ORR
    orr x0, x1, x2
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
    ands x24, x25, x26
    ands x27, x28, x29
    ands x0, x1, x2

    // SBFM/ASR
    asr x12, x12, #4
    asr x12, x14, #8
    asr x12, x11, #1

    // UBFM/LSL/LSR
    lsl x14, x24, #4
    lsr x25, x11, #4
    lsl x21, x21, #63

    hlt #0