test_spritesHMSBWrap: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"x expanded sprite correctly shows partially in left border                      ")

	Start: {
			//Enable an x-expanded sprite
			lda #$01
			sta $d015
			sta $d01d

			//Position sprite
			ldx #$e1
			ldy #$32
			stx $d000
			sty $d001
			lda #$01
			sta $d010

			//Disable 16 color sprites
			//Disable extra wide sprites (16px)
			lda #$00
			sta $d06b
			sta $d057

			//Set 16bit sprite pointer and location
			lda #$80
			sta $d06e
			lda #<SPRITE_POINTERS 
			sta $d06c
			lda #>SPRITE_POINTERS 
			sta $d06d
			//Fill with sample sprite
			lda #<[SPRITES_1BIT / $40]
			sta SPRITE_POINTERS
			lda #>[SPRITES_1BIT / $40]
			sta SPRITE_POINTERS+1

			//Set color
			lda #$01
			sta $d027

			WriteDescription(Desc_Colors)

		//Loop until X is pressed
		!Loop:
			lda #$ff
			jsr WaitForRaster

			inc $d000
			lda $d000
			cmp #$f8
			bne !SkipReset+
			lda #$e1
			sta $d000

		!SkipReset:
			jsr ExitIfRunstop
			jmp !Loop-
	}
}
