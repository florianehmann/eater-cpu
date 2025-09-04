; hello_world.asm
.segment "CODE"

start:
    lda data             ; load byte at memory address into A register
    out                  ; output byte from A register into output register
    hlt                  ; halt execution

.org $0E
data: .byte $AB, $FE     ; label on the same line should be possible
