test_16color8pxAltPalette: {
	Desc_CharAttr:
	//		 0         1         2         3         4         5         6         7         8
	String(	"320x200 mode fcm 8px wide alt palette   "+
		    "                                        "+
		    "                                        "+
		    "the two chars have different colors     ")

	Start: {
			//Set 16 bit char mode and enable FCM for chars > $FF
			lda #$02
			trb $d054
			lda #$05
			tsb $d054

			//Clear H640 for 40 column mode
			lda #$80
			trb $d031

			//Set row sizes
			lda #$28
			sta $d05e
			lda #$50
			sta $d058
			lda #$00
			sta $d059

			jsr ClearScreen16

			jsr ResetColRAMVector
			jsr ResetScrRAMVector

			ldy #$00
			ldz #$00
		!:
			lda #<[[CHAR5]/$40]
			sta (zpScrRAMVector), y
			lda ColorRamTable, y
			sta ((zpColRAMVector)), z
			iny
			inz

			lda #>[[CHAR5]/$40]
			sta (zpScrRAMVector), y
			lda ColorRamTable, y
			sta ((zpColRAMVector)),z
			iny
			inz

			iny
			iny
			inz
			inz

			cpy #[__ColorRamTable - ColorRamTable]
			bne !-

			WriteDescription16(Desc_CharAttr)

		//Loop until X is pressed
		!Loop:
			jsr ExitIfRunstop
			jmp !Loop-


		ColorRamTable:
			.byte $00,$00 //8px wide
			.byte $00,$00
			.byte $00,$60 //8px wide alt palette
			.byte $00,$00
		__ColorRamTable:

		Tests:

	}

}
