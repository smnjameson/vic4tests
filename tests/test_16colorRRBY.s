test_16colorRRBY: {
	Desc_CharAttr:
	//		 0         1         2         3         4         5         6         7         8
	String(	"320x200 mode 16 bit char indices rrb y  "+
		    "                                        "+
		    "                                        "+
		    "single green dot with transparency move "+
		    "from far left to far right across a grid"+
		    "of red and pink squares with y movement "+
		    "between 2 rows                          ")
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
			lda ScreenData, y
			sta (zpScrRAMVector), y
			lda ColorData, y
			sta ((zpColRAMVector)), z		
			iny
			inz 

			cpy #[__ScreenData - ScreenData]
			bne !-



			WriteDescription16(Desc_CharAttr)

			jsr ResetScrRAMVector

		!Loop:
			lda #$ff
			jsr WaitForRaster			

			inc GotoXIndex


			ldx GotoXIndex
			ldy #40
			lda SinusXLo, x 
			sta (zpScrRAMVector), y 
			iny 
			phx
			txa 
			and #$3f
			tax 
			lda SinusRRBY,x 
			asl 
			asl
			asl
			asl
			asl
			plx
			ora SinusXHi, x
			sta (zpScrRAMVector), y 

			ldy #120 
			lda SinusXLo, x 
			sta (zpScrRAMVector), y 
			iny
			phx 
			txa 
			and #$3f
			tax 
			lda SinusRRBY,x 
			asl 
			asl
			asl
			asl
			asl
			plx
			ora SinusXHi, x
			sta (zpScrRAMVector), y 


			jsr ExitIfRunstop
			jmp !Loop-
		
		GotoXIndex:
				.byte $00

		ScreenData:
			.for(var r=0; r<2; r++) {
				.for(var i=0;i<20; i++) {
					.word [CHARS/$40]
				}
				//GOTOX + Char
				.word $8080, [CHAR1/$40] + r
				//Terminator
				.word $0140, $0000
				.fill 32, 0 //Unused row space				
			}
		__ScreenData:

		ColorData:
			.for(var r=0; r<2; r++) {
				.for(var i=0;i<20; i++) {
					.word $0f08
				}
				//GOTOX + Char
				.word $0090, $5f08
				//Terminator
				.word $0090, $0000
				.fill 32, 0 //Unused row space		

			}

	}


}


