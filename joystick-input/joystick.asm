    processor 6502
    
    include "../dasm/machines/atari2600/vcs.h"
    include "../dasm/machines/atari2600/macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Iniciar na posição $80 um segmento na memória RAM para a declaração das variáveis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80
P0XPos  byte                ; posição X da sprite 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Iniciar nosso segmento de código na ROM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg code
    org $F000

Reset:
    CLEAN_START             ; Macro para limpar a memória e TIA

    ldx #$80                ; cor azul para o fundo (céu)
    stx COLUBK

    ldx #$D0                ; cor verde para o playfield (grama)
    stx COLUPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inicialização das variaveis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #10
    sta P0XPos              ; posição X da sprite onde será inicializadaz
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Novo frame para configurar o VBLANK e o VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
    lda #2
    sta VBLANK              ; ativa o VBLANK
    sta VSYNC               ; ativa o VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera 3 linha do VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 3
        sta WSYNC
    REPEND

    lda #00
    sta VSYNC               ; desativa o VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera a posição X da sprite enquanto está no VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda P0XPos              ; carrega a posição X da sprite no acumulador
    and #$7F                ; $7F = 0111 1111, mascara para manter o bit 7 em 0
                            ; o bit 7 é o bit de sinal, se for 1, a sprite é desenhada

    sta WSYNC               ; espera o inicio da próxima scanline
    sta HMCLR               ; Limpa o bit de movimento horizontal da sprite

    sec                     ; seta o carry para subtrair
DivideLoop:
    sbc #15                 ; subtrai 15 da posição X da sprite
    bcs DivideLoop          ; se o resultado for maior que 0, repete o loop

    eor #7                  ; inverte os bits do acumulador
                            ; ajusta A entre -8 e 7
    asl
    asl
    asl
    asl
    sta HMP0                ; seta a posição fina
    sta RESP0               ; reseta 15 da posição bruta calculada
    sta WSYNC               ; espera o inicio da próxima scanline
    sta HMOVE               ; aplica a posição fina, offset para uma movimentação suave

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as 35 linha de saída recomendadas pelo TIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 35
        sta WSYNC
    REPEND
        
    lda #00
    sta VBLANK              ; desativa o VBLANK
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Desenha as 192 scanlines visíveis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 160
        sta WSYNC           ; espera por 160 scanlines vazias
    REPEND

    ldy #17                  ; contador para o loop de desenho da sprite
DrawBitmap:
    lda P0Bitmap,Y          ; carrega o byte da sprite
    sta GRP0                ; desenha a uma parte da sprite
    
    lda P0Color,Y           ; carrega a cor da sprite
    sta COLUP0              ; set a cor da sprite

    sta WSYNC               ; espera o inicio da próxima scanline

    dey                     ; decrementa o contador
    bne DrawBitmap          ; se X != 0, repete o loop

    lda #00
    sta GRP0                ; desativa o bitmap P0

    lda #$FF                 ; habilita o playfield para desenhar a grama
    sta PF0
    sta PF1
    sta PF2

    REPEAT 15
        sta WSYNC           ; espera por 124 scanlines vazias
    REPEND

    lda #00                 ; desabilita o playfield da grama
    sta PF0
    sta PF1
    sta PF2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as 30 scanlines do overscan (VBLANK), recomendado
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Overscan:
    lda #2
    sta VBLANK              ; ativa o VBLANK
    REPEAT 30
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lógica para movimentar a sprite (Joystick) P0-up, P0-down, P0-left, P0-right
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckP0Up:
    lda #%00010000
    bit SWCHA               ; verifica se o botão UP está pressionado
    bne CheckP0Down         ; se estiver, repete o loop
    inc P0XPos              ; incrementa a posição X da sprite

CheckP0Down:
    lda #%00100000
    bit SWCHA               ; verifica se o botão DOWN está pressionado
    bne CheckP0Left         ; se estiver, repete o loop
    dec P0XPos              ; decrementa a posição X da sprite

CheckP0Left:
    lda #%01000000
    bit SWCHA               ; verifica se o botão Left está pressionado
    bne CheckP0Right        ; se estiver, repete o loop
    dec P0XPos              ; decrementa a posição X da sprite

CheckP0Right:
    lda #%10000000
    bit SWCHA               ; verifica se o botão Right está pressionado
    bne NoInput             ; se estiver, repete o loop
    inc P0XPos              ; incrementa a posição X da sprite

NoInput:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop: Próximo Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define o array de bytes para a sprite
;; IMPORTANTE!!! 
;; Devem estar sempre nos endereços finais da ROM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprite do jogador P0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Bitmap:
    byte #%00000000
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00011100
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01111111
    byte #%00111110
    byte #%00010000
    byte #%00011100
    byte #%00011100
    byte #%00011100

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cor da sprite do jogador P0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Color:
    byte #$00
    byte #$F6
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$3E
    byte #$3E
    byte #$3E
    byte #$24

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completa a ROM com 4KB, exigência do 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC		                	; Define a origem para $FFFC
    .word Reset			                ; Endereço de reset $FFFC (o 6502 inicia a execução do programa nesse endereço)
    .word Reset		                	; Endereço de IRQ (interrupção) $FFFE