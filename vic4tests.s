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
			and #%00001111		//CharPallete = %01
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


			lda $d070
			and #%00111100		//Alternate Pallete = %10
			ora #%10000010
			sta $d070

			ldx #$00
		!:
			lda AltPaletteData + $000, x
			sta $d100, x //Red
			lda AltPaletteData + $100, x
			sta $d200, x //Green
			lda AltPaletteData + $200, x
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

AltPaletteData: {
	.import binary "./assets/palgrn.bin"
	.import binary "./assets/palgrn.bin"
	.import binary "./assets/palgrn.bin"
	

	// .import binary "./assets/altpalred.bin"
	// .import binary "./assets/altpalgrn.bin"
	// .import binary "./assets/altpalblu.bin"
}


ResetScreen: {
		//Responsible for bringing the system back to initial state
		lda #32
		sta $d020
		lda #143
		sta $d021
		
		lda #$01
		tsb $d016
		
		//disable v400 mode
		lda #$08
		trb $d031

		//Restore inital VIC-IV values
		//hide sprites
		//turn off 16 color sprites
		//reset sprite expansion and x-msb
		lda #$00
		sta $d015
		sta $d06b
		sta $d017
		sta $d01d
		sta $d010

		//disable sprites horizontally tiled
		lda #$f0
		trb $d04d 
		trb $d04f 

		//Reset sprite heights to default
		lda #$00
		sta $d055
		lda #$15
		sta $d056

		//Reset border width
		lda #$50
		sta $d05c
		lda #$3f
		trb $d05d

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

		lda #$19
		sta $d07b
		
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



SinusXLo:
	.fill 256, <[sin((i/256) * PI * 2) * 152 + 152]
SinusXHi:
	.fill 256, >[sin((i/256) * PI * 2) * 152 + 152]
SinusRRBY:
	.fill 64, [floor([sin((i/64) * PI * 2) * 3 + 4])]


SinusXLo2:
	.fill 256, <[sin((i/256) * PI * 2) * 168 + 152]
SinusXHi2:
	.fill 256, >[sin((i/256) * PI * 2) * 168 + 152]


SinusXLo3:
	.fill 256, <[sin((i/256) * PI * 2) * 127 + 128]

* = $8000
CHARS:
	.byte $11,$11,$11,$11, $77,$77,$77,$77
	.byte $01,$00,$00,$10, $07,$00,$00,$70
	.byte $01,$00,$00,$10, $07,$00,$00,$70
	.byte $01,$00,$00,$10, $07,$00,$00,$70
	.byte $01,$00,$00,$10, $07,$00,$00,$70
	.byte $01,$00,$33,$10, $07,$00,$33,$70
	.byte $01,$00,$33,$10, $07,$00,$33,$70
	.byte $11,$11,$11,$11, $77,$77,$77,$77


CHAR1:
	.fill 64, 0
CHAR2:
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$55,$55,$00,$00,$00
	.byte $00,$00,$55,$55,$55,$55,$00,$00
	.byte $00,$00,$55,$55,$55,$55,$00,$00
	.byte $00,$00,$00,$55,$55,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00
CHAR3:
	.fill 64, 0
CHAR4:
	.byte 15,15,15,15,15,15,15,15
	.byte 15,3,4,5,6,7,8,15
	.byte 15,4,5,6,7,8,9,15
	.byte 15,5,6,7,8,9,1,15
	.byte 15,6,7,8,9,1,2,15
	.byte 15,7,8,9,1,2,3,15
	.byte 15,8,9,1,2,3,4,15
	.byte 15,15,15,15,15,15,15,15


CHAR5:
	.byte 1,0,0,0,0,0,0,1
	.byte 0,1,0,0,0,0,1,0
	.byte 0,0,1,0,0,1,0,0
	.byte 0,0,0,1,1,0,0,0
	.byte 0,0,0,1,1,0,0,0
	.byte 0,0,1,0,0,1,0,0
	.byte 0,1,0,0,0,0,1,0
	.byte 1,0,0,0,0,0,0,1
CHAR6:
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,4,4,4,4,0,0
	.byte 0,4,4,4,4,4,4,0
	.byte 0,4,4,4,4,4,4,0
	.byte 0,0,4,4,4,4,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
CHAR7:
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,4,4,4,4,0,0
	.byte 0,4,4,4,4,4,4,0
	.byte 0,4,4,4,4,4,4,0
	.byte 0,0,4,4,4,4,0,0
	.byte 0,0,0,0,0,0,0,0
	.byte 0,0,0,0,0,0,0,0
CHAR8:
	.byte $55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$22,$22,$22,$22,$22,$22,$55
	.byte $55,$22,$22,$22,$22,$22,$22,$55
	.byte $55,$22,$22,$22,$22,$22,$22,$55
	.byte $55,$22,$22,$22,$22,$22,$22,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55
	.byte $55,$55,$55,$55,$55,$55,$55,$55
CHAR9:
	.byte $11,$11,$11,$11,$11,$11,$11,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
CHAR10:
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$00,$00,$00,$00,$00,$00,$11
	.byte $11,$11,$11,$11,$11,$11,$11,$11
CHAR11:
	.fill 64, $44

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

.align $40
HIGH_SPRITE:
	.for(var i=0;i<200; i++) {
		.var transByte = round(sin(i/6) * 3.5 + 3.5)
		.var color = (floor((i/20) + 1) << 4) + floor((i/20) + 1)
		.if(transByte > 0) {
			.fill transByte, color
		}
		.byte $00
		.if(transByte < 7) {
			.fill 7-transByte, color
		}	
	}