    processor 6502

    include "../dasm/machines/atari2600/vcs.h"
    include "../dasm/machines/atari2600/macro.h"

    seg code
    org $F000               ; ROM inicia em $F000

START:
    ; CLEAN_START             ; Macro para limpar a TIA e RAM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Seta o background para a com amarela.
;; https://en.wikipedia.org/wiki/List_of_video_game_console_palettes#Atari
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$1E                ; Carrega a cor amarela no acumulador ($1E representa a cor amarela no padrão NTSC)
    sta COLUBK              ; Seta o background para amarelo, colocando o valor do acumulador no endereço $09

    jmp START               ; Volta para o início do programa

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Preencha a ROM para exatamente 4KB, exigência do 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC               ; Define a origem para $FFFC
    .word START             ; Endereço de reset $FFFC (o 6502 inicia a execução do programa nesse endereço)
    .word START             ; Endereço de IRQ (interrupção) $FFFE