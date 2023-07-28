    processor 6502
    
    include "../../dasm/machines/atari2600/vcs.h"
    include "../../dasm/machines/atari2600/macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Iniciar na posição $80 um segmento na memória RAM para a declaração das variáveis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg.u Variables
    org $80
P0XPos      byte            ; posição X da sprite 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Iniciar nosso segmento de código na ROM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg code
    org $F000

Reset:
    CLEAN_START             ; Macro para limpar a memória e TIA

    ldx #$00                ; background preto
    stx COLUBK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inicialização das variaveis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #50
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
;; Gera as (37-2) linha de saída recomendadas pelo TIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 35
        sta WSYNC
    REPEND
        
    lda #00
    sta VBLANK              ; desativa o VBLANK
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Desenha as 192 scanlines visíveis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 60
        sta WSYNC           ; espera por 60 scanlines vazias
    REPEND

    ldy #8                  ; contador para o loop de desenho da sprite
DrawBitmap:
    lda P0Bitmap,Y          ; carrega o byte da sprite
    sta GRP0                ; desenha a uma parte da sprite
    
    lda P0Color,Y           ; carrega a cor da sprite
    sta COLUP0              ; set a cor da sprite

    sta WSYNC               ; espera o inicio da próxima scanline

    dey                     ; decrementa o contador
    bne DrawBitmap          ; se X != 0, repete o loop

    lda #0
    sta GRP0                ; desativa o bitmap P0

    REPEAT 124
        sta WSYNC           ; espera por 124 scanlines vazias
    REPEND

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
;;  Decrementa a posição X da sprite em cada frame (animacao)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    inc P0XPos              ; decrementa a posição X da sprite

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
;; Sprite de uma maçã P0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Bitmap:
    byte #%00000000
    byte #%00101000
    byte #%01110100
    byte #%11111010
    byte #%11111010
    byte #%11111010
    byte #%11111110
    byte #%01101100
    byte #%00110000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cor da Sprite P0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
P0Color:
    byte #$00
    byte #$40
    byte #$40
    byte #$40
    byte #$40
    byte #$42
    byte #$42
    byte #$44
    byte #$D2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completa a ROM com 4KB, exigência do 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC		                	; Define a origem para $FFFC
    .word Reset			                ; Endereço de reset $FFFC (o 6502 inicia a execução do programa nesse endereço)
    .word Reset		                	; Endereço de IRQ (interrupção) $FFFE