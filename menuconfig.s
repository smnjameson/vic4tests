#import "./tests/test_sprites16color.s"
#import "./tests/test_sprites1bit.s"
#import "./tests/test_spritesHtile.s"
#import "./tests/test_16colorcharattr.s"
#import "./tests/test_16colorRRB.s"
#import "./tests/test_16colorRRBY.s"
#import "./tests/test_16colorRRBAltPalette.s"
#import "./tests/test_16colorRRBBoundary.s"
#import "./tests/test_chargenRowCount.s"
#import "./tests/test_dmaTransparency.s"
#import "./tests/test_spritesY200.s"
#import "./tests/test_spritesHMSBWrap.s"
#import "./tests/test_spritesBorderRelative.s"
#import "./tests/test_16color8pxAltPalette.s"

MenuConfig: {
		.const IS_MENU = 1
		.const IS_CODE = 0

		Main: {
			Title:
				String("vic iv compatibility test suite")
			Items: {
				String("sprites")
				.word Sprites16cols		 //Points to next menu or code item
				.byte IS_MENU				 //Defines menu item type
				
				String("16 color char mode")
				.word SuperAttr			 //Points to next menu or code item
				.byte IS_MENU				 //Defines menu item type

				String("chargen and borders")
				.word CharGen 
				.byte IS_MENU
				
				String("dma")
				.word DMA 
				.byte IS_MENU

				.byte $00


			}
		}


		DMA: {
			Title:
				String("dma")
			Items: {
				String("dma transparency")
				.word test_dmaTransparency.Start
				.byte IS_CODE

				String("return to main menu")
				.word Main
				.byte IS_MENU

				.byte $00
			}
		}

		CharGen: {
			Title:
				String("chargen and borders")
			Items: {
				String("row counter")
				.word test_chargenRowCount.Start
				.byte IS_CODE

				String("return to main menu")
				.word Main
				.byte IS_MENU

				.byte $00
			}
		}

		SuperAttr: {
			Title:
				String("16 color char mode")
			Items: {
				String("attributes 40 column")
				.word test_16colorcharattr.Start
				.byte IS_CODE

				String("rrb 40 column")
				.word test_16colorRRB.Start
				.byte IS_CODE

				String("rrb ypositioning 40 column")
				.word test_16colorRRBY.Start
				.byte IS_CODE				

				String("rrb alternate palette 40 column")
				.word test_16colorRRBAltPalette.Start
				.byte IS_CODE

				String("rrb boundary and wrap 40 column")
				.word test_16colorRRBBoundary.Start
				.byte IS_CODE

				String("fcm 8px alternate palette 40 column")
				.word test_16color8pxAltPalette.Start
				.byte IS_CODE

				String("return to main menu")
				.word Main
				.byte IS_MENU

				.byte $00
			}
		}

		Sprites16cols: {
			Title:
				String("sprites")
			Items: {
				String("16 colors")
				.word test_sprites16color.Start
				.byte IS_CODE	

				String("1 bit")
				.word test_sprites1bit.Start
				.byte IS_CODE	

				String("horizontal tiling")
				.word test_spritesHtile.Start
				.byte IS_CODE	

				String("arbitrary y height")
				.word test_spritesY200.Start
				.byte IS_CODE				

				String("horizontal msb wrapping")
				.word test_spritesHMSBWrap.Start
				.byte IS_CODE

				String("x-coord not affected by border width")
				.word test_spritesBorderRelative.Start
				.byte IS_CODE				

				String("return to main menu")
				.word Main
				.byte IS_MENU

				.byte $00
			}
		}				
}
