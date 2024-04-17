.text
.global _start
_start:
    // CSEL
    csel x14, x11, x12, lt
    csel x14, x11, x12, mi
    csel x1, x2, x3, eq
    hlt #0