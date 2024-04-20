.text
.global _start
_start:
    // LDP-STP no offset
    stp x10, x9, [x11, #0]
    ldp x10, x9, [x12, #0]

    // LDP-STP positive offset
    stp x10, x9, [x11, #16]
    ldp x10, x9, [x12, #16]

    // LDP-STP negative offset
    stp x10, x9, [x11, #-16]
    ldp x10, x9, [x12, #-16]

    // LDUR-STUR no offset
    stur x13, [x5, #0]
    ldur x13, [x5, #0]
    stur x13, [x5, #0]
    ldur x13, [x5, #0] 
    stur x13, [x5, #0]
    ldur x13, [x5, #0]

    // LDUR-STUR positive offset
    stur x13, [x5, #8]
    ldur x13, [x5, #8]
    stur x13, [x5, #24]
    ldur x13, [x5, #24] 
    stur x13, [x5, #40]
    ldur x13, [x5, #40]

    // LDUR-STUR negative offset
    stur x13, [x5, #-8]
    ldur x13, [x5, #-8]
    stur x13, [x5, #-24]
    ldur x13, [x5, #-24] 
    stur x13, [x5, #-40]
    ldur x13, [x5, #-40]  