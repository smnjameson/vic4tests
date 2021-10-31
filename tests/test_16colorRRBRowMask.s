test_16colorRRBRowMask: {
	.const SCREEN_RAM = $0800
	.const COLOR_RAM = $ff80000
	.const NUM_ROWS = 10

	Desc_CharAttr:
	//		 0         1         2         3         4         5         6         7         8
	String(	"320x200 mode rrb with rowmask           " +
		    "                                        " +
		    "                                        " +
		    "a rectangle moves around without any    " +
		    "display artifacts above or below it     ")

	Start: {
			//Set 16 bit char mode and enable FCM for chars > $FF
			lda #$02
			trb $d054
			lda #$05
			tsb $d054

			lda #$a0
			trb $d031

			//Set row sizes
			lda #$28
			sta $d05e
			lda #$50
			sta $d058
			lda #$00
			sta $d059

			jsr ClearScreen16

			//Copy data to screen and color RAM
			RunDMAJob(DMAScreenCopy)
			RunDMAJob(DMAColorCopy)

			WriteDescription16(Desc_CharAttr)

			jsr ResetScrRAMVector
			jsr ResetColRAMVector

			//Set initial RRB sprite coordinates and movement speeds
			lda #$6c
			sta SpriteX + 0
			lda #$00
			sta SpriteX + 1
			sta SpriteY
			lda #$01
			sta XSpeed
			sta YSpeed

		!Loop:
			lda #$ff
			jsr WaitForRaster

			jsr ClearSprite
			jsr MoveSprite
			jsr DrawSprite

			jsr ExitIfRunstop
			jmp !Loop-
	}

	ClearSprite: {
			RunDMAJob(Job)
			rts
		Job:
			DMAHeader(0, 0)
			DMAStep(0, 0, 80, 0)
			DMAFillJob(<[CHAR1/$40], SCREEN_RAM+42, NUM_ROWS, true) //Reset char
			DMAFillJob(0, SCREEN_RAM+41, NUM_ROWS, false) //Reset char data offset
	}

	DrawSprite: {
			lda SpriteY
			and #$07
			sta TmpY
			asl
			adc TmpY:#$00
			sta RowMaskIdx //Initial index to RowMaskData (TmpY multiplied by 3)

			lda TmpY
			eor #$07
			asl
			asl
			asl
			asl
			asl
			sta Offset //Char data offset

			lda SpriteY
			lsr
			lsr
			lsr
			tax //Initial char row

			lda #<[CHAR8/$40] //Char before actual first char
			sta CurrChar

			ldz #$03
		!RowLoop:
			cpx #NUM_ROWS
			bcs !Done+

			//Get screen and color RAM addresses
			lda RRBScreenRowLo, x
			sta zpScrRAMVector + 0
			sta zpColRAMVector + 0
			lda RRBScreenRowHi, x
			sta zpScrRAMVector + 1
			sbc #$08-1 //Carry is clear here
			sta zpColRAMVector + 1

			//Set GOTOX position and char
			ldy #$00
			lda SpriteX + 0
			sta (zpScrRAMVector), y
			iny
			lda SpriteX + 1
			ora Offset:#$00
			sta (zpScrRAMVector), y
			iny
			lda CurrChar:#$00
			sta (zpScrRAMVector), y
			iny
			lda #>[CHAR8/$40]
			sta (zpScrRAMVector), y

			//Set pixel row mask flags
			ldy RowMaskIdx:#$00
			lda RowMaskData, y
			phz
			ldz #$01
			sta ((zpColRAMVector)), z
			plz

			inc CurrChar
			inc RowMaskIdx
			inx
			dez
			bne !RowLoop-
		!Done:
			rts
	}

	MoveSprite: {
			lda SpriteX + 0
			ldx SpriteX + 1
			ldy XSpeed
			bmi !MoveLeft+
			cpx #$01
			bcc !IncX+
			cmp #48
			bcs !ToggleHor+
		!IncX:
			tya
			adc SpriteX + 0
			sta SpriteX + 0
			bcc !MoveVer+
			inc SpriteX + 1
			bra !MoveVer+
		!MoveLeft:
			cpx #$01
			bcs !DecX+
			cmp #$01
			bcc !ToggleHor+
		!DecX:
			tya
			clc
			adc SpriteX + 0
			sta SpriteX + 0
			bcs !MoveVer+
			dec SpriteX + 1
			bra !MoveVer+
		!ToggleHor:
			tya
			neg
			sta XSpeed

		!MoveVer:
			lda SpriteY
			ldy YSpeed
			bmi !MoveUp+
			cmp #62
			bcs !ToggleVer+
		!AdjustY:
			tya
			adc SpriteY
			sta SpriteY
			bra !Done+
		!MoveUp:
			cmp #$01
			bcc !ToggleVer+
			clc
			bra !AdjustY-
		!ToggleVer:
			tya
			neg
			sta YSpeed
		!Done:
			rts
	}

	SpriteX:
		.word $0000
	SpriteY:
		.byte $00
	XSpeed:
		.byte $01
	YSpeed:
		.byte $01

	DMAScreenCopy:
		DMAHeader(0, 0)
		DMACopyJob(ScreenData, SCREEN_RAM, 80*NUM_ROWS, false, false)

	DMAColorCopy:
		DMAHeader(0, COLOR_RAM>>20)
		DMACopyJob(ColorData, COLOR_RAM, 80*NUM_ROWS, false, false)

	ScreenData:
		.for(var r=0; r<NUM_ROWS; r++) {
			.for(var i=0; i<20; i++) {
				.word [CHARS/$40]
			}
			//GOTOX position + char
			.word $0000, [CHAR1/$40]
			//Terminator
			.word $0140, $0000
			.fill 32, 0 //Unused row space
		}

	ColorData:
		.for(var r=0; r<NUM_ROWS; r++) {
			.for(var i=0; i<20; i++) {
				.word $0f08
			}
			//LAYERED|GOTOX|ROWMASK and pixel row mask flags + char
			.word $0098, $5f08
			//Terminator
			.word $0090, $0000
			.fill 32, 0 //Unused row space
		}

	RRBScreenRowLo:
		.fill NUM_ROWS, <[SCREEN_RAM + 80*i + 40]
	RRBScreenRowHi:
		.fill NUM_ROWS, >[SCREEN_RAM + 80*i + 40]

	RowMaskData:
		.byte %01111111, %11111111, %10000000
		.byte %00111111, %11111111, %11000000
		.byte %00011111, %11111111, %11100000
		.byte %00001111, %11111111, %11110000
		.byte %00000111, %11111111, %11111000
		.byte %00000011, %11111111, %11111100
		.byte %00000001, %11111111, %11111110
		.byte %00000000, %11111111, %11111111
}
