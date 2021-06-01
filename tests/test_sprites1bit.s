test_sprites1bit: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"display - display 8 spr at 1bit colors                                          ")

	Start: {
			//enable sprites
			lda #$ff
			sta $d015

			//position sprites
			ldy #$00
			ldx #$32
			lda #$18
			
		!:
			stx $d001, y 
			sta $d000, y 
			clc 
			adc #$2a
			iny
			iny 
			cpy #$10
			bne !-

			//Set msbs and push last sprite right to edge
			lda #$c0
			sta $d010 
			inc $d00e
			inc $d00e

			//disable 16 color sprites
			//disable extra wide sprites (16px)
			lda #$00
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
			lda #>[SPRITES_1BIT / $40]
			ldx #<[SPRITES_1BIT / $40]
			ldy #$00
		!:
			stx SPRITE_POINTERS, y
			iny
			sta SPRITE_POINTERS, y
			iny 
			cpy #$10
			bne !-

			//set colors
			clc
			ldy #$07
		!:
			tya 
			adc #$01
			sta $d027, y 
			dey
			bpl !-

			WriteDescription(Desc_Colors)
		//Loop until X is pressed
		!Loop:
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


		Tests:

	}


}


