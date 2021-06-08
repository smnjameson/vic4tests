test_dmaTransparency: {
	Desc_Colors:
	//		 0         1         2         3         4         5         6         7         8
	String(	"animation on the left and the ball on   " +
		    "the right should merge in center")

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


			lda #<[CHAR5 / $40]
			sta $08b8
			lda #>[CHAR5 / $40]
			sta $08b9

			lda #<[CHAR7 / $40]
			sta $08c8
			lda #>[CHAR7 / $40]
			sta $08c9

			lda #<[CHAR6 / $40]
			sta $08d8
			lda #>[CHAR6 / $40]
			sta $08d9



			WriteDescription16(Desc_Colors)
		//Loop until X is pressed
		!Loop:
			lda #$ff
			jsr WaitForRaster

			//animate cross
			ldx #$07
		!:
			lda CHAR5, x 
			sta Temp,x 
			dex  
			bpl !-
			ldx #$00
		!:
			lda CHAR5 + 8, x 
			sta CHAR5, x 
			inx 
			cpx #$38
			bne !-
			ldx #$07
		!:
			lda Temp, x 
			sta CHAR5 + $38,x 
			dex  
			bpl !-		

			//Copy cross WITHOUT dma
			ldx #$3f
		!:
			lda CHAR5, x
			sta CHAR7, x 
			dex 
			bpl !-

			RunDMAJob(DMATransCopy)

			jsr ExitIfRunstop
			jmp !Loop-

	DMATransCopy:
			DMAHeader(0,0)
			DMAEnableTransparency(0)
			DMACopyJob(CHAR6, CHAR7, 64, false, false)

	Temp:
		.fill 8, 0


	}


}


