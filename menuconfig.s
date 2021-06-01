#import "./tests/test_sprites16color.s"
#import "./tests/test_sprites1bit.s"
#import "./tests/test_spritesHtile.s"
#import "./tests/test_16colorcharattr.s"

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


				.byte $00
			}
		}

		SuperAttr: {
			Title:
				String("16 color charmode")
			Items: {
				String("attributes")
				.word test_16colorcharattr.Start
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

				String("return to main menu")
				.word Main
				.byte IS_MENU

				.byte $00
			}
		}				
} 