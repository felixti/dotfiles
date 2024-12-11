local wezterm = require("wezterm")

config = wezterm.config_builder()

config = {
	automatically_reload_config = true,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE", -- disable the title bar enable the resize border
	-- color_scheme = "catppuccin-mocha",
	default_cursor_style = "BlinkingBar",
	font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
	font_size = 14.5,
	window_padding = {
		left = 3,
		right = 3,
		top = 0,
		bottom = 0,
	},
	background = {
		{
			source = {
				Color = "#1E1E2F",
			},
			width = "100%",
			height = "100%",
			opacity = 0.95,
		},
	},
}

return config
