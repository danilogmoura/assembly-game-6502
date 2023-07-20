    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    LDY #10             ; Inicialize o registrador Y com o valor decimal 10
    TYA                 ; Transferir o valor em A para Y
    STA $80,Y           ; Armazene o valor decimal 10 na posição de memória $80+Y

Loop:
    DEY                 ; Diminuir Y em 1
    TYA                 ; Transferir Y para A
    STA $80,Y           ; Armazene o valor em A dentro da posição de memória $80+Y
    BNE Loop            ; Ramifique de volta para "Loop" até terminarmos
    
    JMP Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
