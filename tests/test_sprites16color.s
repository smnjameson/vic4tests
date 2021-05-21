test_sprites16color: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"palette - display 8 spr at 16x21px in 16 colors, each sprite a smooth gradient  "
		  + "transparency - transparent band should move through the sprites                 ")

	Colors: {
			//enable sprites
			lda #$ff
			sta $d015

			//position sprites
			ldx #$50
			ldy #$00
			lda #$20
			clc 
		!:
			stx $d001, y 
			sta $d000, y 
			adc #$18 
			iny
			iny 
			cpy #$10
			bne !-

			//enable 16 color sprites
			lda #$ff
			sta $d06b

			//Set 16bit sprite pointers and location
			lda #$80
			sta $d06e
			lda #<SPRITE_POINTERS 
			sta $d06c
			lda #>SPRITE_POINTERS 
			sta $d06d
			//Fill with sample sprite
			lda #$03
			ldx #$e0 
			ldy #$00
		!:
			stx SPRITE_POINTERS, y
			iny
			sta SPRITE_POINTERS, y
			iny 
			cpy #$10
			bne !-

			//set all trasparencies to color 0
			lda #$00
			ldy #$07
		!:
			sta $d027, y 
			dey
			bpl !-


			WriteDescription(Desc_Colors)

		//Loop until X is pressed
		!Loop:
			inc TransparentIndex
			lda TransparentIndex
			ldy #$07
		!:
			sta $d027, y 
			dey
			bpl !-

			
			ExitIfRunstop()
			jmp !Loop-

		TransparentIndex:
			.byte $00
	}
}


