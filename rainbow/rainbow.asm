    processor 6502

    include "../dasm/machines/atari2600/vcs.h"
    include "../dasm/machines/atari2600/macro.h"

    seg code
    org $F000

Start:
    CLEAN_START             ; Macro para limpar a memoria e TIA 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inicia um novo frame ativando o VBLANK E VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NextFrame:
    lda #02                 ; valor em binário equivalente a %00000010
    sta VBLANK              ; ativa o VBLANK
    sta VSYNC               ; ativa o VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as três linhas de sincronismo vertical	(VSYNC)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC               ; primeiro scanline
    sta WSYNC               ; segundo scanline
    sta WSYNC               ; terceiro scanline

    lda #00
    sta VSYNC               ; desativa o VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as 37 linhas de sincronismo horizontal (VBLANK) recomendado para o TIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37                 ; x = 37 (contador de scanlines)
LoopVBlank:
    sta WSYNC               ; dispara o WSYSNC e espera o proximo scanline
    dex                     ; decrementa o contador
    bne LoopVBlank          ; se x != 0, repete o loop

    lda #00
    sta VBLANK              ; desativa o VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as 192 scanlines visiveis na tela (kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #192                ; x = 192 (contador de scanlines visiveis)
LoopVisible:
    stx COLUBK              ; define a cor do background
    sta WSYNC               ; espera o proximo scanline
    dex                     ; decrementa o contador
    bne LoopVisible         ; se x != 0, repete o loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as 30 scanlines do overscan (VBLANK), recomendado
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #02                 ; dispara o VBLANK e espera o proximo scanline
    sta VBLANK

    ldx #30                 ; x = 30 (contador de scanlines do overscan)
LoopOverscan:
    sta WSYNC               ; espera o proximo scanline
    dex                     ; decrementa o contador
    bne LoopOverscan        ; se x != 0, repete o loop

    jmp NextFrame           ; repete o loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completa a ROM com 4KB, exigência do 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC               ; Define a origem para $FFFC
    .word Start             ; Endereço de reset $FFFC (o 6502 inicia a execução do programa nesse endereço)
    .word Start             ; Endereço de IRQ (interrupção) $FFFE

    