.macro testColorAt(xpos,ypos,rgb) {
		.eval xpos = xpos*2 + 81;
		.eval ypos = ypos*2 + 105;
		.var r = [rgb >> 16]
		.eval r = [[r & $0f]<<4]|[r>>4]       
		.var g = [rgb >> 8] & $ff
		.eval g = [[g & $0f]<<4]|[g>>4] 
		.var b = [rgb] & $ff
		.eval b = [[b & $0f]<<4]|[b>>4] 

		lda #<xpos 
		sta $d07d
		lda #<ypos
		sta $d07e
		lda #[>xpos + [[>ypos] << 4]]
		sta $d07f

		ldx #r 
		ldy #g
		ldz #b
		jsr TestPixelAt
}

TestPixelAt: {
		lda #$ff
		jsr WaitForRaster
		lda #$ff
		jsr WaitForRaster

		lda $d07c
		and #$3f
		ora #$40
		sta $d07c
		lda $d07d
		sta $0900
		cpx $d07d
		// bne !Fail+

		lda $d07c
		and #$3f
		ora #$80
		sta $d07c  
		lda $d07d
		sta $0901		
		cpy $d07d		
		// bne !Fail+

		lda $d07c
		and #$3f
		ora #$c0
		sta $d07c 
		lda $d07d
		sta $0902		 
		cpz $d07d
		// bne !Fail+	

	!Success:	
		clc
		rts
	!Fail:
		sec
		rts
}

WaitForRaster: {
		cmp $d012 
		bne *-3
		clc 
		adc #$01
		cmp $d012
		bne *-3
		rts
}

ExitIfRunstop:{
		lda $d610
		
		cmp #$1b
		beq !exit+
		cmp #$03
		bne !+
	!exit:
		sta $d610
		pla 
		pla
	!:
		sta $d610
		rts
}