require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

require("starship"):setup()

require("zoxide"):setup({
	update_db = true,
})

