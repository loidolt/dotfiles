-- Tabline configuration
local wezterm = require("wezterm")

-- Apply tabline configuration directly
wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez").setup({
	options = {
		icons_enabled = true,
		theme = "Catppuccin Mocha",
		color_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },
		tabline_c = { " " },
		tab_active = {
			"index",
			{ "parent", padding = 0 },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			{ "zoomed", padding = 0 },
		},
		tabline_x = { " " },
		tabline_y = { " " },
		tabline_z = { "hostname" },
	},
	extensions = {},
})

-- Return configuration table for tab bar
return {
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = false,
}
