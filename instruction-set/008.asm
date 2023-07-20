    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    LDY #10             ; Inicialize o registrador Y com o valor decimal 10

Loop:
    TYA                 ; Transferir Y para A
    STA $80,Y           ; Armazene o valor em A dentro da posição de memória $80+Y
    DEY                 ; Diminuir Y em 1
    BPL Loop            ; Se Y for maior ou igual a 0, pule para o rótulo "Loop"

    JMP Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
