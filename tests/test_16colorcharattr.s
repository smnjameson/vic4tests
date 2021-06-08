test_16colorcharattr: {
	Desc_CharAttr:
	//		 0         1         2         3         4         5         6         7         8
	String(	"320x200 mode 16 bit char indices        "+
		    "                                        "+
		    "                                        "+
		    "attributes set in the order:            "+
		    "none, hflip, vflip, h+vflip             "+
		    "grey, blue, green, orange")

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

			jsr ResetColRAMVector
			jsr ResetScrRAMVector
	


			ldy #$00
			ldz #$00
		!:
			lda #<[[CHARS + 0]/$40]
			sta (zpScrRAMVector), y
			lda ColorRamTable, y 
			sta ((zpColRAMVector)), z			
			iny
			inz 

			lda #>[[CHARS + 0]/$40]
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
			.byte $08,$0f //standard 16px wide
			.byte $08,$0f
			.byte $48,$0f //16px + HFlip
			.byte $08,$0f
			.byte $88,$0f //16px + VFlip
			.byte $08,$0f
			.byte $C8,$0f //16px + H+VFlip
			.byte $08,$0f

			.byte $08,$9f //standard 16px wide  grey
			.byte $08,$0f
			.byte $08,$2f //standard 16px wide  blue
			.byte $08,$0f
			.byte $08,$4f //standard 16px wide  green
			.byte $08,$0f
			.byte $08,$7f //standard 16px wide  orange
			.byte $08,$0f
		__ColorRamTable:

		Tests:

	}


}


