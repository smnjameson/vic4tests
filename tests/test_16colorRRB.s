test_16colorRRB: {
	Desc_CharAttr:
	//		 0         1         2         3         4         5         6         7         8
	String(	"320x200 mode 16 bit char indices rrb    "+
		    "                                        "+
		    "                                        "+
		    "two green dots with transparency moving "+
		    "from far left to far right across a grid"+
		    "of red and pink squares                 ")
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
	


			//Fill a row (20 chars @ 16px wide)
			ldy #$00
			ldz #$00
		!:
			lda #<[CHARS/$40]
			sta (zpScrRAMVector), y
			lda #$08 //16 px wide char
			sta ((zpColRAMVector)), z			
			iny
			inz 
			lda #>[CHARS/$40]
			sta (zpScrRAMVector), y 
			lda #$0f 
			sta ((zpColRAMVector)),z			
			iny
			inz 
			cpy #40
			bne !-


			//add the rrb x 2 + final terminator
			ldx #$00
		!:
			//GOTOX
			lda GotoXPositionsLo, x 
			sta (zpScrRAMVector), y
			sty GotoXOffsets, x
			lda #$90
			sta ((zpColRAMVector)), z			
			iny
			inz 
			lda GotoXPositionsHi, x 
			inx 
			sta (zpScrRAMVector), y 
			lda #$00 
			sta ((zpColRAMVector)),z			
			iny
			inz

			//CHAR
			lda #<[CHAR2/$40]
			sta (zpScrRAMVector), y
			lda #$08 //16 px wide char
			sta ((zpColRAMVector)), z			
			iny
			inz 
			lda #>[CHAR2/$40]
			sta (zpScrRAMVector), y 
			lda #$5f 
			sta ((zpColRAMVector)),z			
			iny
			inz 

			cpy #[40 + [__GotoXPositionsLo - GotoXPositionsLo] * 4]
			bne !-



			


			WriteDescription16(Desc_CharAttr)

			jsr ResetScrRAMVector

		!Loop:
			lda #$ff
			jsr WaitForRaster			

			inc GotoXIndex 
			ldy GotoXIndex 

			ldx #$00
		!:
			lda GotoXOffsets, x 
			taz
			lda SinusXLo, y 
			sta (zpScrRAMVector),z 
			inz 
			lda SinusXHi, y 
			sta (zpScrRAMVector),z 	

			tya 
			clc 
			adc #$40
			tay

			inx 
			cpx #[__GotoXPositionsLo - GotoXPositionsLo - 1]
			bne !-


			jsr ExitIfRunstop
			jmp !Loop-


		GotoXIndex:
			.byte 0

		GotoXPositionsLo:
			.byte $10,$40,$40
		__GotoXPositionsLo:
		GotoXPositionsHi:
			.byte $00,$00,$01

		GotoXOffsets:
			.byte 0,0,0


	}


}


