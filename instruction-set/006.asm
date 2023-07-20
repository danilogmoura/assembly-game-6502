    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    LDA #01             ; Carregue o registrador A com o valor decimal 1
    LDX #01             ; Carregue o registrador X com o valor decimal 2
    LDY #01             ; Carregue o registrador Y com o valor decimal 3
    
    INX                 ; Incrementar X
    INY                 ; Incrementar Y

    CLD                 ; Limpe o registrador de status decimal
    ADC #01             ; Incrementar A
 
    DEX                 ; Decremetar X
    DEY                 ; Decremetar Y
    
    SEC                 ; Defina o bit de carry
    SBC #01             ; Decremetar A
    
    JMP Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
