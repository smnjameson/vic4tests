.cpu _45gs02
#import "./_include/m65macros.s"
#import "./src/zeropage.s"

BasicUpstart65(Entry)
* = $2020
#import "./src/menu.s"
#import "./src/testrunner.s"

Entry: {
		//Disable ROM banks and interrupts
		sei 
		lda #$35
		sta $01
		
		lda #$00
		sta $d01a

		lda #$7f
		sta $dc0d
		sta $dd0d

		disableC65ROM()



		//Initialise Mega65 into VIC4 mode at 40 mhz
		enable40Mhz()
		enableVIC4Registers()

		//disable rom mappings
		//and disable rom palette for 0-15
		lda #$04
		sta $d030

		jsr setPalettes
		
		CreateMenu(MenuConfig.Main)

		jmp *
}

setPalettes: {
			lda $d070
			and #%00110011
			ora #$11001100		//SpritePallete = %11

			sta $d070
			ldx #$00
		!:
			lda SpritePaletteData + $000, x
			sta $d100, x //Red
			lda SpritePaletteData + $100, x
			sta $d200, x //Green
			lda SpritePaletteData + $200, x
			sta $d300, x //Blue
			inx
			bne !-


			lda $d070
			and #%00001111		//CharPallete = %00
			ora #%01010000
			sta $d070

			ldx #$00
		!:
			lda SpritePaletteData + $000, x
			sta $d100, x //Red
			lda SpritePaletteData + $100, x
			sta $d200, x //Green
			lda SpritePaletteData + $200, x
			sta $d300, x //Blue
			inx
			bne !-
		 	
			rts	
}

SpritePaletteData: {
	.import binary "./assets/palred.bin"
	.import binary "./assets/palgrn.bin"
	.import binary "./assets/palblu.bin"
}


ResetScreen: {
		//Responsible for bringing the system back to initial state
		lda #143
		sta $d020
		sta $d021
		
		//Restore inital VIC-IV values
		//hide sprites
		//turn off 16 color sprites
		lda #$00
		sta $d015
		sta $d06b

		//disable sprites horizontally tiled
		lda #$f0
		trb $d04d 
		trb $d04f 

		//Restore 8 bit char mode
		lda #$07
		trb $d054

		//Set row sizes
		lda #$50
		sta $d05e
		lda #$50
		sta $d058
		lda #$00
		sta $d059

		lda #$a0
		tsb $d031

		jsr ClearScreen

		rts


}

ClearScreen: {
			//Clear screen
		lda #$20
		ldx #$00
	!:
		sta $0800, x
		sta $0900, x
		sta $0a00, x
		sta $0b00, x
		sta $0c00, x
		sta $0d00, x
		sta $0e00, x
		sta $0f00, x
		
		dex 
		bne !-

		//Clear to green text
		jsr ResetColRAMVector
		ldz #$00
		ldx #$08
		lda #$00
	!:
		sta ((zpColRAMVector)), z 
		inz 
		bne !-
		inc zpColRAMVector + 1 
		dex 
		bne !-
		rts
}

ClearScreen16: {
			//Clear screen
		lda #$20
		ldx #$00
	!:
		sta $0800, x
		sta $0900, x
		sta $0a00, x
		sta $0b00, x
		sta $0c00, x
		sta $0d00, x
		sta $0e00, x
		sta $0f00, x
		sta $1000, x
		sta $1100, x
		sta $1200, x
		sta $1300, x
		sta $1400, x
		sta $1500, x
		sta $1600, x
		sta $1700, x
		eor #$20	//Toggle between $20 and $00 for 16 bit clear
		inx 
		bne !-

		//Clear to green text
		jsr ResetColRAMVector
		ldz #$00
		ldx #$10
		lda #$00
	!:
		sta ((zpColRAMVector)), z 
		inz 
		bne !-
		inc zpColRAMVector + 1 
		dex 
		bne !-
		rts
}


ResetColRAMVector: {
		lda #$00
		sta zpColRAMVector + 0
		sta zpColRAMVector + 1	
		lda #$F8
		sta zpColRAMVector + 2	
		lda #$0F
		sta zpColRAMVector + 3
		rts
}
ResetScrRAMVector: {
		lda #$00
		sta zpScrRAMVector + 0
		lda #$08
		sta zpScrRAMVector + 1	
		rts
}
ScrRAMNextLine: {
		lda zpScrRAMVector + 0
		clc 
		adc #$50
		sta zpScrRAMVector + 0
		bcc !+
		inc zpScrRAMVector + 1
	!:
		rts
}


.align $100
CHARS:
	.byte $11,$11,$11,$11, $77,$77,$77,$77
	.byte $01,$00,$00,$10, $07,$00,$00,$70
	.byte $01,$00,$00,$10, $07,$00,$00,$70
	.byte $01,$00,$00,$10, $07,$00,$00,$70
	.byte $01,$00,$00,$10, $07,$00,$00,$70
	.byte $01,$00,$33,$10, $07,$00,$33,$70
	.byte $01,$00,$33,$10, $07,$00,$33,$70
	.byte $11,$11,$11,$11, $77,$77,$77,$77



.align $10
SPRITE_POINTERS:
	.fill 16, 0

.align $40
SPRITES_1BIT:
	SquareSprite:
		.byte 255,255,255
		.fill 19, [128,0,1]
		.byte 255,255,255
.align $40		
SPRITES_BASE:
	.import binary "./assets/sprites.bin"

