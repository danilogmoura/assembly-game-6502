    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    LDA #10             ; Carregue o registrador A com o valor decimal 10
    STA $80             ; Armazene o valor de A na posição de memória $80
     
    INC $80             ; Incrementar o valor dentro de uma posição de memória (página zero) $80
    DEC $80             ; Diminuir o valor dentro de uma posição de memória (página zero) $80
    
    JMP Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
