test_sprites16color: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"palette - display 8 spr at 16x21px in 16 colors, each sprite a smooth gradient  "
		  + "transparency - transparent band should move through the sprites                 ")

	Start: {
			//enable sprites
			lda #$ff
			sta $d015

			//position sprites
			ldy #$00
			ldx #$32
			lda #$18
			clc 
		!:
			stx $d001, y 
			sta $d000, y 
			adc #$2b 
			iny
			iny 
			cpy #$10
			bne !-


			//Set msbs and push last sprite right to edge
			lda #$c0
			sta $d010 
			inc $d00e
			inc $d00e
			inc $d00e
			
			//enable 16 color sprites
			//extra wide sprites (16px)
			lda #$ff
			sta $d06b
			sta $d057



		// 	//Set 16bit sprite pointers and location
			lda #$80
			sta $d06e
			lda #<SPRITE_POINTERS 
			sta $d06c
			lda #>SPRITE_POINTERS 
			sta $d06d
			//Fill with sample sprite
			lda #>[SPRITES_BASE / $40]
			ldx #<[SPRITES_BASE / $40]
			ldy #$00
		!:
			stx SPRITE_POINTERS, y
			iny
			sta SPRITE_POINTERS, y
			iny 
			cpy #$10
			bne !-


			WriteDescription(Desc_Colors)
		//Loop until X is pressed
		!Loop:
			inc TransparentIndex
			lda TransparentIndex
			and #$0f
			ldy #$07
		!:
			sta $d027, y 
			dey
			bpl !-

			lda #$ff
			jsr WaitForRaster
			// testColorAt(2,2,$000000)
			// bcs Fail
			jsr ExitIfRunstop
			jmp !Loop-


		Fail:
			inc $d020
			nop
			nop
			jmp Fail

		TransparentIndex:
			.byte $00

		Tests:

	}


}


