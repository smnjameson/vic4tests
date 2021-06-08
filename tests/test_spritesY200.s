test_spritesY200: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"16color arbitrary y height sprites                                              "+
		    "                                                                                "+
		    "each sprite strip should be bands of color each band the same height with a     "+
		    "transparent black sine wave continuous throughout with no breaks. each strip    "+
		    "should animate from 0-200 sprite height.")

	Start: {
			// //enable v400 mode
			// lda #$08
			// tsb $d031

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
			adc #$12
			pha 
			txa 
			sta $d001, y 
			pla 
			iny
			iny 
			cpy #$10
			bne !-

			//Set msbs and push last sprite right to edge
			lda #$00
			sta $d010 
			// inc $d00e
			// inc $d00e

			//set 16 color + extra wide sprites 
			lda #$ff
			sta $d06b
			sta $d057

		    //Set 16bit sprite pointers and location
			lda #$80
			sta $d06e
			lda #<SPRITE_POINTERS 
			sta $d06c
			lda #>SPRITE_POINTERS 
			sta $d06d


			//Fill with sample sprite
			lda #>[HIGH_SPRITE / $40]
			ldx #<[HIGH_SPRITE / $40]
 			ldy #$00
		!:
			stx SPRITE_POINTERS, y
			iny
			sta SPRITE_POINTERS, y
			iny 
			cpy #$10
			bne !-

			//setr extended height
			lda #$ff
			sta $d055

			//set colors
			lda #$00
			ldy #$07
		!:
			sta $d027, y 
			dey
			bpl !-

			WriteDescription(Desc_Colors)


		//Loop until X is pressed
		!Loop:
			lda #$ff
			jsr WaitForRaster

			inc SprHeight
			lda SprHeight
			sta $d056

			jsr ExitIfRunstop
			jmp !Loop-


		SprHeight:
			.byte 21

	}


}


