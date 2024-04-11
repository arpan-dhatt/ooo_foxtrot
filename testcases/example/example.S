.text
.global _start
_start:
    // Load the address of the message into x0
    ldr x0, =message

    // Print the message
    bl  print_string

    // Halt the processor
    hlt #0

print_string:
    ldrb w1, [x0]    //  Load a byte from the message
    cbz  w1, done    //  If the byte is null, end of string

    mov  x1, #-1     //  MMIO port address
    strb w1, [x1]    //  Write the byte to the MMIO port

    add x0, x0, #1   //  Increment the message pointer
    b   print_string

done:
    ret

.data
    message: .asciz "Hello, World!\n"