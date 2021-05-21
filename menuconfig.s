#import "./tests/test_sprites16color.s"

MenuConfig: {
		.const IS_MENU = 1
		.const IS_CODE = 0

		Main: {
			Title:
				String("vic iv compatibility test suite")
			Items: {
				String("16 color sprites")
				.word Sprites16cols		 //Points to next menu or code item
				.byte IS_MENU				 //Defines menu item type
				
				String("super extended attribute mode")
				.word SuperAttr			 //Points to next menu or code item
				.byte IS_MENU				 //Defines menu item type


				.byte $00
			}
		}

		SuperAttr: {
			Title:
				String("super extended attribute mode")
			Items: {
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
				String("colors")
				.word test_sprites16color.Colors
				.byte IS_CODE				

				String("return to main menu")
				.word Main
				.byte IS_MENU

				.byte $00
			}
		}				
}