; hello_world.s
.segment "CODE"

start:
    lda data             ; load byte at memory address into A register
    out                  ; output byte from A register into output register
    hlt                  ; halt execution

.org $0E
data: .byte $FE, $AB     ; label on the same line should be possible
