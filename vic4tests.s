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

		jsr setSpritePalette
		
		CreateMenu(MenuConfig.Main)

		jmp *
}

setSpritePalette: {
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
			rts	
}

SpritePaletteData: {
	.import binary "./assets/palred.bin"
	.import binary "./assets/palgrn.bin"
	.import binary "./assets/palblu.bin"
}


ResetScreen: {
		//Responsible for bringing the system back to initial state
		lda #$0b
		sta $d020
		lda #$00
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
		lda #$05
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



.align $40
SPRITES_1BIT:
	SquareSprite:
		.byte 255,255,255
		.fill 19, [128,0,1]
		.byte 255,255,255
.align $40		
SPRITES_BASE:
	.import binary "./assets/sprites.bin"

.align $10
SPRITE_POINTERS:
	.fill 16, 0