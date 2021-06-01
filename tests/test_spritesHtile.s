test_spritesHtile: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"display - 4x1bit and 4x16color sprites tiled horizontally, increasing start xpos")

	Start: {
			//enable sprites
			lda #$ff
			sta $d015

			//position sprites
			ldy #$00
			ldx #$32
			lda #$18
			
		!:
			sta $d000, y 
			clc 
			adc #$2a
			pha 
			txa 
			sta $d001, y 
			clc 
			adc #$18 
			tax
			pla 
			iny
			iny 
			cpy #$10
			bne !-

			//Set msbs and push last sprite right to edge
			lda #$c0
			sta $d010 
			inc $d00e
			inc $d00e

			//disable 16 color sprites for sprites 0-4
			//disable extra wide sprites (16px) for sprites 0-4
			lda #$f0
			sta $d06b
			sta $d057

			//Extend sprites horizontally
			lda #$f0
			tsb $d04d 
			tsb $d04f 


		    //Set 16bit sprite pointers and location
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
			cpy #$08 
			bne !-
		!:
			lda #>[SPRITES_BASE / $40] + 3
			ldx #<[SPRITES_BASE / $40] + 3	
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
			lda SprColors, y
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

		SprColors:
			.byte 1,2,3,4,0,0,0,0
		Tests:

	}


}


