    processor 6502

    seg code
    org $F000               ; Defina a origem do código em $F000

Start:
    sei                     ; Desabilita interrupções
    cld                     ; Limpa o bit de decimal
    ldx #$FF                ; Carrega o valor $FF em X
    txs                     ; Transfere o valor de X para o registrador de pilha

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Limpa a região de memória $00-$FF
; Toda a RAM e também todos os registradores que estão localizados nesta região
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0                  ; Carrega o valor #0 em A
    ldx #$FF                ; Carrega o valor $FF em X
    
MemLoop:
    sta $0,x                ; Armazena o valor de A no endereço $0 + X
    dex                     ; Decrementa o valor de X (x--)
    bne MemLoop             ; Se X for diferente de zero, pula para MemLoop (registrador z != 0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Preencha o tamanho da ROM exatamente com 4KB.
; A ROM é mapeada na memória de $F000-$FFFF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC             
    .word Start             ; Vetor de reset em $FFFC (onde o programa começa)
    .word Start             ; Vetor de interrupção em $FFFC (não utilizado no VSC)
