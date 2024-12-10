local wezterm = require 'wezterm'

local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Your existing configuration
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.5
config.font = wezterm.font('JetBrains Mono', { weight = 'Bold' })
config.font_size = 14
config.animation_fps = 30
config.cursor_blink_rate = 750
config.cursor_blink_ease_in = "Linear"
config.cursor_blink_ease_out = "Constant"
config.default_cursor_style = 'BlinkingBlock'
config.audible_bell = "Disabled"
config.color_scheme = 'Gruvbox Dark (Gogh)'
config.macos_window_background_blur = 30

-- Add these lines for better macOS compatibility
config.term = 'xterm-256color'
config.enable_tab_bar = false
config.use_fancy_tab_bar = false
-- config.warn_about_missing_glyphs = true  -- This will help debug font issues

local function split_pane(window, pane)

  local pane_dims = pane:get_dimensions()
  local width = pane_dims.pixel_width
  local height = pane_dims.pixel_height
  
  if width > height then
    window:perform_action(wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }, pane)
  else
    window:perform_action(wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }, pane)
  end
end

config.keys = {
  -- Horizontal split (new pane below)
  { 
    key = 'P', 
    mods = 'CTRL', 
    action = wezterm.action_callback(function(window, pane)
      split_pane(window, pane)
    end)
  },

  -- Close active pane
  { key = 'W', mods = 'CTRL', action = wezterm.action.CloseCurrentPane { confirm = true } },
}

return config