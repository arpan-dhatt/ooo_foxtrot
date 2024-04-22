.text
.global _start
_start:
    add x12, x5, #395
    add x12, x5, #-395
    adds x3, x20, x21

    sub x1, x3, #123
    sub x1, x3, #-123
    subs x3, x20, x21

    cmp x5, x3

    hlt #0