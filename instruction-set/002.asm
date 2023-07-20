    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    lda #$0A            ; Carregue o registrador A com o valor hexadecimal $A
    ldx #%11111111      ; Carregue o registrador X com o valor binário %11111111
    
    sta $80             ; Armazene o valor no registrador A no endereço de memória $80
    stx $81             ; Armazene o valor no registrador X no endereço de memória $81

    jmp Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
