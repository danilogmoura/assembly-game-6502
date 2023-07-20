    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    
    lda #15             ; Carregue o registrador A com o valor decimal literal 15
    tax                 ; Transfira o valor de A para X
    tay                 ; Transferir o valor de A para Y
    tax                 ; Transfira o valor de X para A
    tya                 ; Transferir o valor de Y para A
     
    ldx #06             ; Carregue X com o valor decimal 6
                        
                        ; Transferir o valor de X para Y
    txa                 ; Transferir o valor de X para A
    tay                 ; Transferir o valor de A para Y

    jmp Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
