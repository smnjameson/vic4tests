test_16colorRRBBoundary: {
	Desc_CharAttr:
	//		 0         1         2         3         4         5         6         7         8
	String(	"320x200 mode rrb gotox range            "+
		    "                                        "+
		    "                                        "+
		    "green rectangle moving from -$10 to $140"+
		    "left to right smoothly behind borders   "+
		    "yellow end marker is moving $100-$1ff   "+
		    "and should only be visible @ screen area"+
		    "where it will remove anything aftger it ")
	Start: {
			//Set 16 bit char mode and enable FCM for chars > $FF
			lda #$02
			trb $d054
			lda #$05
			tsb $d054

			lda #$a0
			trb $d031

			lda #$07
			trb $d016

			//Set row sizes
			lda #$18
			sta $d05e
			lda #$30
			sta $d058
			lda #$00
			sta $d059


			//set CHARGENX so screen starts earlier so that
			//RRB X=0 is behind the left border
			// lda #$30
			// sta $d04c

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
			lda #$10
			sta ((zpColRAMVector)), z			
			iny
			inz 
			lda GotoXPositionsHi, x 

			sta (zpScrRAMVector), y 
			lda #$00 
			sta ((zpColRAMVector)),z			
			iny
			inz

			//CHAR
			lda #<[CHAR8/$40]
			sta (zpScrRAMVector), y
			lda #$08 //16 px wide char
			sta ((zpColRAMVector)), z			
			iny
			inz 
			lda #>[CHAR8/$40]
			sta (zpScrRAMVector), y 
			lda GotoXColors, x 
			sta ((zpColRAMVector)),z			
			iny
			inz 

			inx 

			cpy #[40 + [__GotoXPositionsLo - GotoXPositionsLo] * 4]
			bne !-



			


			WriteDescription16(Desc_CharAttr)

			jsr ResetScrRAMVector

		!Loop:
			lda #$ff
			jsr WaitForRaster			

			inc GotoXIndex 

			//rrb sprite
			lda GotoXIndex 
			clc 
			adc #$00
			tay 
			ldz GotoXOffsets + 0
			lda SinusXLo2, y 
			sta (zpScrRAMVector),z 
			inz 
			lda SinusXHi2, y 
			and #$03
			sta (zpScrRAMVector),z 	



			//move gotox marker
			lda GotoXIndex 
			clc 
			adc #$20
			tay 
			ldz GotoXOffsets + 1
			lda SinusXLo3, y  
			sta (zpScrRAMVector),z 


			jsr ExitIfRunstop
			jmp !Loop-


		GotoXIndex:
			.byte 0

		GotoXPositionsLo:
			.byte $10,$40
		__GotoXPositionsLo:
		GotoXPositionsHi:
			.byte $00,$01
		GotoXColors:
			.byte $5f,$6f
		GotoXOffsets:
			.byte 0,0


	}


}


