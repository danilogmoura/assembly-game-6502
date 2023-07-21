	processor 6502
       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Adiciona os arquivos com os macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    include "../../dasm/machines/atari2600/vcs.h"
    include "../../dasm/machines/atari2600/macro.h"
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inicializa o código da ROM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    seg code
    org $F000
        
Reset:
   	CLEAN_START
        
    ldx #$80		; background azul
    stx COLUBK
    
    lda #$1C		; playfield amarelo
    sta COLUPF
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inicializa um novo frame configurando o VBLANK e VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
	lda #02			; %00000010
	sta VBLANK		; ativa o VBLANK
    sta VSYNC		; ativa o VSYNC
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera 3 linha do VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	REPEAT 3
        sta WSYNC	; 3 scanlines para VSYNC
    REPEND
    lda #00
    sta VSYNC		; desabilita o VSYNC
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as 37 linhas recomendadas para o VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
	REPEAT 37
        sta WSYNC
    REPEND
    lda #00
    sta VBLANK		; desabilita o VBLANK
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Seta o CTRLPF register para abilitar a reflexão do playfield
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;       
    ldx #%00000001		; CTRLPF register (D0 significa que será refletido)
    stx CTRLPF
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as 192 scanlines visíveis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ; pula 7 scanlines iniciais deixando sem playfield (PF0, PF1, PF2)
    ldx #00
    stx PF0
    stx PF1
    stx PF2
    
    REPEAT 7
        sta WSYNC
    REPEND
    
    ; Seta o PF0 para 1110 (LBS ) e PF1-PF2 para 1111 1111
    ldx #%11100000
    stx PF0
    
    ldx #%11111111
    stx PF1
    stx PF2
    
    REPEAT 7
        sta WSYNC	; repete a configuração para 7 scanlines
    REPEND
    
    ; Seta as próximas 164 linhas com apenas o PF0 com o terceiro bit habilitado
    ldx #%00100000
    stx PF0
    ldx #00
    stx PF1
    stx PF2
    
    REPEAT 164
        sta WSYNC
    REPEND
        
	; Seta o PF0 para 1110 (LBS ) e PF1-PF2 para 1111 1111
    ldx #%11100000
    stx PF0
    ldx #%11111111
    stx PF1
    stx PF2
    
    REPEAT 7
        sta WSYNC
    REPEND
    
    ; pula 7 scanlines finais deixando sem playfield (PF0, PF1, PF2)
    ldx #00
    stx PF0
    stx PF1
    stx PF2
    
    REPEAT 7
        sta WSYNC
    REPEND
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera 30 linhas de overscan VBLANK para completar nosso quadro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #02
    sta VBLANK		; ativa VBLANK
    
    REPEAT 30
        sta WSYNC
    REPEND
    lda #00
    sta VBLANK
        
	jmp StartFrame
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completa a ROM com 4KB, exigência do 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC			; Define a origem para $FFFC
    .word Reset		; Endereço de reset $FFFC (o 6502 inicia a execução do programa nesse endereço)
    .word Reset		; Endereço de IRQ (interrupção) $FFFE