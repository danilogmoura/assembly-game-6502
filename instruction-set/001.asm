    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    lda #$82            ; Carregue o registrador A com o valor hexadecimal literal $82
    ldx #82             ; Carregue o registrador X com o valor decimal literal 82
    ldy $82             ; Carregue o registrador Y com o valor que está dentro da posição de memória $82

    jmp Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
