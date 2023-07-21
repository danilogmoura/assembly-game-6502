    processor 6502
    
    include "../dasm/machines/atari2600/vcs.h"
    include "../dasm/machines/atari2600/macro.h"
    
    seg code
    org $F000

Reset:
    CLEAN_START                 ; Macro para limpar a memória e TIA

    ldx #$80                    ; background azul
    stx COLUBK

    lda #%1111			        ; playfiled branco
    sta COLUPF
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setamos a cor do P0 e P1 nos registrados TIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$48			        ; player 0, cor vermelho
    sta COLUP0
    
    lda #$C6			        ; player 1, cor verde
    sta COLUP1

    ldy #%00000010              ; CTRLPF D1 set to 1 means (score)
    sty CTRLPF
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Novo frame para configurar o VBLANK e o VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
    lda #2
    sta VBLANK			        ; ativa o VBLANK
    sta VSYNC			        ; ativa o VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera 3 linha do VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 3
        sta WSYNC
    REPEND

    lda #00
    sta VSYNC			        ; desativa o VSYNC
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as 37 linha de saída recomendadas pelo TIA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 37
        sta WSYNC
    REPEND
        
    lda #00
    sta VBLANK			        ; desativa o VBLANK
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as scanlines visíveis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VisibleScanlines:
    ; desenhe 10 scanlines vazias no top do frame
    REPEAT 10
        sta WSYNC
    REPEND
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Desenha 10 scanlines para o placar, usando o array de bytes definido
;; no NumberBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldy #00

ScoreboardLoop:
    lda NumberBitmap,y
    sta PF1			            ; ativa o Playfiel 1
    sta WSYNC       
    iny
    cpy 10
    bne ScoreboardLoop
    
    lda #00
    sta PF1			            ; desativa o Playfiel 1
    
    ; Desenha 50 linhas entre os players e o placar
    REPEAT 50
        sta WSYNC
    REPEND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Desenha 10 scanlines para o GRP0 (player 0), usando o array de bytes definido
;; no NumberBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldy #00

Player0Loop:
    lda PlayerBitmap,y
    sta GRP0                        ; ativa player 0
    sta WSYNC
    iny
    cpy #10
    bne Player0Loop
    
    lda #00
    sta GRP0	                    ; desativa player 0
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Desenha 10 scanlines para o GRP1 (player 1), usando o array de bytes definido
;; no NumberBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldy #00
    
Player1Loop:
    lda PlayerBitmap,y
    sta GRP1			            ; ativa o player 1
    sta WSYNC
    iny
    cpy #10
    bne Player1Loop
    
    lda #00
    sta GRP1 			            ; desativa o player 1
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Desenha o restando das scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    REPEAT 102
    	sta WSYNC
    REPEND
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gera as 30 scanlines do overscan (VBLANK), recomendado
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    REPEAT 30
        sta WSYNC
    REPEND
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop: Próximo Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define o array de bytes para a sprite
;; IMPORTANTE!!! 
;; Devem estar sempre nos endereços finais da ROM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Player
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFE8
PlayerBitmap:
    .byte #%01111110   		            ;  ######
    .byte #%11111111   		            ; ########
    .byte #%10011001   		            ; #  ##  #
    .byte #%11111111   		            ; ########
    .byte #%11111111   		            ; ########
    .byte #%11111111   		            ; ########
    .byte #%10111101   		            ; # #### #
    .byte #%11000011   		            ; ##    ##
    .byte #%11111111   		            ; ########
    .byte #%01111110   		            ;  ######

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Placar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFF2
NumberBitmap:
    .byte #%00001110   		            ; ########
    .byte #%00001110   		            ; ########
    .byte #%00000010   	            	;      ###
    .byte #%00000010   	            	;      ###
    .byte #%00001110   	            	; ########
    .byte #%00001110   	            	; ########
    .byte #%00001000   	            	; ###
    .byte #%00001000   		            ; ###
    .byte #%00001110   	            	; ########
    .byte #%00001110   	            	; ########

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completa a ROM com 4KB, exigência do 6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC		                	; Define a origem para $FFFC
    .word Reset			                ; Endereço de reset $FFFC (o 6502 inicia a execução do programa nesse endereço)
    .word Reset		                	; Endereço de IRQ (interrupção) $FFFE