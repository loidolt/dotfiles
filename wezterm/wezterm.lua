-- WezTerm configuration
-- Main entry point that loads modular configuration files

local wezterm = require("wezterm")

-- Build configuration by merging all modules
local config = wezterm.config_builder()

-- Load and apply each module individually
local modules = { "cfg_fonts", "cfg_theme", "cfg_window", "cfg_tabline" }

for _, module_name in ipairs(modules) do
	local module = require(module_name)
	if type(module) == "table" then
		for k, v in pairs(module) do
			config[k] = v
		end
	else
		wezterm.log_error(string.format("Module %s returned %s instead of table", module_name, type(module)))
	end
end

return config
