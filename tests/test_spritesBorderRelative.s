test_spritesBorderRelative: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"display - sprite x-coordinate should not be affected by border width            "
		  + "(the sprite above should not move horizontally)                                 ")

	Start: {
			//Enable a sprite
			lda #$01
			sta $d015

			//Position sprite
			ldx #$18
			ldy #$32
			stx $d000
			sty $d001

			//disable 16 color sprites
			//disable extra wide sprites (16px)
			lda #$00
			sta $d06b
			sta $d057

			//Set 16bit sprite pointer and location
			lda #$80
			sta $d06e
			lda #<SPRITE_POINTERS 
			ldx #>SPRITE_POINTERS 
			sta $d06c
			stx $d06d
			//Fill with sample sprite
			lda #<[SPRITES_1BIT / $40]
			ldx #>[SPRITES_1BIT / $40]
			sta SPRITE_POINTERS
			stx SPRITE_POINTERS+1

			//Set color
			lda #$01
			sta $d027

			WriteDescription(Desc_Colors)

		//Loop until X is pressed
		!Loop:
			lda #$ff
			jsr WaitForRaster

			ldx BorderWidth
			stx $d05c
			dex
			cpx #$48
			bne !NoReset+
			ldx #$50
		!NoReset:
			stx BorderWidth

			jsr ExitIfRunstop
			jmp !Loop-

		BorderWidth:
			.byte $50
	}
}
