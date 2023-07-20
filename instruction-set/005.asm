    processor 6502
    seg Code            ; Defina um novo segmento chamado "Código" 
    org $F000           ; Defina a origem do código ROM no endereço de memória $F000
Start:
    LDA #$0A            ; Carregue o registrador A com o valor hexadecimal $A
    LDX #%1010          ; Carregue o registrador X com o valor binário %1010
     
    STA $80             ; Armazene o valor do registrador A no endereço de memória (página zero) $80
    STX $81             ; Armazene o valor do registrador X no endereço de memória (página zero) $81
 
    LDA #10             ; Carregue A com o valor decimal 10

    CLC                 ; Limpe o bit de carry
    ADC $80             ; Adicione ao acumulador o valor do endereço $80
    ADC $81             ; Adicione ao acumulador o valor do endereço $81
                        ; A deve conter (#10 + $A + %1010) = #30 ($1E em hexadecimal)
                        
    STA $82             ; Armazene o valor de A na posição RAM $ 82
    
    jmp Start           ; Salte para o endereço de memória $F000 (loop infinito)

    org $FFFC           ; Termine a ROM adicionando os valores necessários à posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de reset na posição de memória $FFFC
    .word Start         ; Coloque 2 bytes com o endereço de quebra na posição de memória $FFFE
