    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    LDA #01             ; Inicialize o registrador A com o valor decimal 1

Loop:
    CLC                 ; Limpe o bit de carry
    ADC #01             ; Adicione o valor decimal 1 ao registrador A
    CMP #10             ; Compare o valor em A com o valor decimal 10
    BNE Loop            ; Ramifique de volta ao loop se a comparação não for igual (a zero)
    
    JMP Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
