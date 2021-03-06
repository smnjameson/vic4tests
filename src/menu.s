#import "../menuconfig.s"

.macro CreateMenu(target) {
		lda #<target
		sta zpMenuTarget + 0
		lda #>target
		sta zpMenuTarget + 1
		jmp Menu
		
}
.macro String(str) {
	.text str
	.byte $00
}

.macro WriteDescription(strptr) {
		lda #<strptr
		sta zpMenuTarget + 0
		lda #>strptr
		sta zpMenuTarget + 1
		jsr DrawDescription
}

.macro WriteDescription16(strptr) {
		lda #<strptr
		sta zpMenuTarget + 0
		lda #>strptr
		sta zpMenuTarget + 1
		jsr DrawDescription16
}



MenuData: {
	.const MAX_NUM_ITEMS = 20
	NumItems:	.byte $00
	Type:	.fill MAX_NUM_ITEMS, $00
	TargetLo:	.fill MAX_NUM_ITEMS, $00
	TargetHi:	.fill MAX_NUM_ITEMS, $00
}


Menu: {
		lda zpMenuTarget + 0
		sta zpPrevMenu + 0
		lda zpMenuTarget + 1
		sta zpPrevMenu + 1

		jsr ResetScreen 
		jsr ResetScrRAMVector


	//Title 
		ldy #$00
		ldz #$00
	!:
		lda (zpMenuTarget), y
		beq !TitleDone+
		sta (zpScrRAMVector), z 
		iny 
		inz
		bra !-
	!TitleDone:
		//Underline
		jsr ScrRAMNextLine
		lda #$3d
	!:
		cpz #$00
		beq !TitleDone+
		dez
		sta (zpScrRAMVector), z 
		bra !-
	!TitleDone:
		jsr ScrRAMNextLine


		ldx #$00
	!itemLineLoop:
		jsr ScrRAMNextLine
		ldz #$00
		jsr MenuGetNextItem //Sets vector in ZP and returns first byte in Acc
		beq !Exit+
		//Draw menu item KEY
		txa 
		clc 
		adc #$01
		sta (zpScrRAMVector), z
		inz 
		inz 
		lda #$2d
		sta (zpScrRAMVector), z
		inz 
		inz 
		//Draw menu item text
		ldy #$00
	!itemTextLoop:
		lda (zpMenuTarget), y
		beq !next+
		sta (zpScrRAMVector), z
		iny
		inz
		bra !itemTextLoop-
	!next:
		iny 

		//Record menu item type and target
		lda (zpMenuTarget), y
		sta MenuData.TargetLo, x 
		iny
		lda (zpMenuTarget), y
		sta MenuData.TargetHi, x 
		iny
		lda (zpMenuTarget), y
		sta MenuData.Type, x 

		inx 
		bra !itemLineLoop-

	!Exit:
		stx MenuData.NumItems
		

		jmp WaitOption
}

MenuGetNextItem: {
		iny
		tya 
		clc 
		adc zpMenuTarget + 0
		sta zpMenuTarget + 0
		bcc !+
		inc zpMenuTarget + 1
	!: 
		ldy #$00
		lda (zpMenuTarget), y
		rts
}

WaitOption: {
	!:
		lda #$fe
		cmp $d012
		bne *-3
		lda #$ff
		cmp $d012
		bne *-3

		lda $d610


		and #$1f
		sec 
		sbc #$01
		sta $d610
		bmi !-

		cmp MenuData.NumItems
		bcs !-
		sta $d610

		ldx #$ff
		cpx $d012
		bne *-3

		//Get menu item type
		tax 
		lda MenuData.Type, x 
		beq !RunCode+

		//launch new menu page
		lda MenuData.TargetLo, x 
		sta zpMenuTarget + 0
		lda MenuData.TargetHi, x 
		sta zpMenuTarget + 1
		jmp Menu

	!RunCode:
		phx 
		jsr ClearScreen
		plx
		lda MenuData.TargetLo, x 
		sta routine + 0
		lda MenuData.TargetHi, x 
		sta routine + 1
		jsr routine:$BEEF

	!prevMenu:
		sta $d610
		lda zpPrevMenu + 0
		sta zpMenuTarget + 0
		lda zpPrevMenu + 1
		sta zpMenuTarget + 1
		jmp Menu
		// CreateMenu(MenuConfig.Main)
}


DrawDescription: {
		jsr ResetScrRAMVector
		clc
		lda zpScrRAMVector + 0
		adc #<1600
		sta zpScrRAMVector + 0
		lda zpScrRAMVector + 1
		adc #>1600
		sta zpScrRAMVector + 1

		ldy #$00
	!:
		lda (zpStringTarget), y 
		beq !Exit+
		sta (zpScrRAMVector), y 
		iny 
		bne !-
		inc zpStringTarget + 1
		inc zpScrRAMVector + 1
		bra !-
	!Exit:
		rts
}

DrawDescription16: {
		jsr ResetScrRAMVector
		clc
		lda zpScrRAMVector + 0
		adc #<1200
		sta zpScrRAMVector + 0
		lda zpScrRAMVector + 1
		adc #>1200
		sta zpScrRAMVector + 1

		jsr ResetColRAMVector
		lda zpColRAMVector + 0
		adc #<1200
		sta zpColRAMVector + 0
		lda zpColRAMVector + 1
		adc #>1200
		sta zpColRAMVector + 1

		ldy #$00
		ldz #$00
	!loop:
		lda (zpStringTarget), y 
		beq !Exit+
		sta (zpScrRAMVector), z
		lda #$00
		sta ((zpColRAMVector)), z 
		inz 
		lda #$00
		sta (zpScrRAMVector), z 
		sta ((zpColRAMVector)), z 
		inz 
		bne !+
		inc zpScrRAMVector + 1
		inc zpColRAMVector + 1
	!:
		iny 
		bne !loop-
		inc zpStringTarget + 1
		// inc zpScrRAMVector + 1
		bra !loop-
	!Exit:
		rts
}