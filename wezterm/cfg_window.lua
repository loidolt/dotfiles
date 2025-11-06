-- Window configuration
local cfg = {}

-- Window size
cfg.initial_cols = 120
cfg.initial_rows = 28

-- Window decorations
cfg.window_decorations = "RESIZE"

-- Window padding with border effect
cfg.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}

-- Window frame colors for border
cfg.window_frame = {
	border_left_width = "0.25cell",
	border_right_width = "0.25cell",
	border_bottom_height = "0.125cell",
	border_top_height = "0.125cell",
	border_left_color = "#89b4fa",
	border_right_color = "#89b4fa",
	border_bottom_color = "#89b4fa",
	border_top_color = "#89b4fa",
}

return cfg
