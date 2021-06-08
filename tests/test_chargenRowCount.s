test_chargenRowCount: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"    anim from 1 to 26 rows display filling screen between borders completely    ")

	Start: {
			//Move top border
			lda #$58
			sta $d048
			lda #$00
			sta $d049

			//Move bottom border
			lda #$f8
			sta $d04a
			lda #$01
			sta $d04b

			//Move Text Y Chargen position 
			lda #$58
			sta $d04e
			lda #$00
			sta $d04f	

			//Fill screen
			jsr ResetScrRAMVector
			jsr ResetColRAMVector

			
			ldz #$1a
		!OLoop:
			ldy #$4f
			lda #$a1
		!:
			sta (zpScrRAMVector), y 
			dey 
			bpl !-
			clc
			lda zpScrRAMVector + 0
			adc #$50 
			sta zpScrRAMVector + 0
			bcc !+
			inc zpScrRAMVector + 1
		!:
			dez 
			bne !OLoop-



			WriteDescription(Desc_Colors)
		//Loop until X is pressed
		!Loop:
			lda #$ff
			jsr WaitForRaster
			inc Counter
			lda Counter 
			and #$07
			bne !skip+
			lda $d07b 
			clc
			adc #$01
			cmp #$1b 
			bne !+
			lda #$01
		!:
			sta $d07b
		!skip:
			jsr ExitIfRunstop
			jmp !Loop-


		Counter:
			.byte $00

	}


}


