    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    
    lda #100            ; Carregue o registrador A com o valor decimal literal 100

    sec                 ; Defina o bit de transporte para 1
    adc #05             ; Adicione o valor decimal 5 ao acumulador
    sbc #10             ; Subtraia o valor decimal 10 do acumulador

    ; O registro A agora deve conter o decimal 95 (ou $ 5F em hexadecimal)

    jmp Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
