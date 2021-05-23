test_sprites16color: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"palette - display 8 spr at 16x21px in 16 colors, each sprite a smooth gradient  "
		  + "transparency - transparent band should move through the sprites                 "
		  + "transparency - transparent band should move through the sprites                 ")

	Colors: {
			//enable sprites
			lda #$ff
			sta $d015

			//position sprites
			ldx #$70
			ldy #$00
			lda #$40
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
			//extra wide sprites (16px)
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

			lda #$00
			sta $d072 
			sta $d074
			sta $d075
			sta $d05f
			sta $d055


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

			
			ExitIfRunstop()
			jmp !Loop-

		TransparentIndex:
			.byte $00
	}
}


