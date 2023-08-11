-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- mappings
local act = wezterm.action
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 1000 }
-- Ctrl+B % — Split the window into two panes horizontally.
-- Ctrl+B " — Split the window into two panes vertically.
config.keys = {
  {
    key = 'c',
    mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'x',
    mods = 'LEADER',
    action = act.CloseCurrentTab { confirm = false },
  },
  { key = '{', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = '}', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateCommandPalette }
}

-- This is where you actually apply your config choices

-- tab bar
config.tab_max_width  = 30
config.use_fancy_tab_bar = false
config.window_frame = {
  -- The font used in the tab bar.
  -- Roboto Bold is the default; this font is bundled
  -- with wezterm.
  -- Whatever font is selected here, it will have the
  -- main font setting appended to it to pick up any
  -- fallback fonts you may have used there.
  font = wezterm.font { family = 'Hack NFM', weight = 'Bold' },

  -- The size of the font in the tab bar.
  -- Default to 10.0 on Windows but 12.0 on other systems
  font_size = 9.0,

  -- The overall background color of the tab bar when
  -- the window is focused
  active_titlebar_bg = '#24273a',

  -- The overall background color of the tab bar when
  -- the window is not focused
  inactive_titlebar_bg = '#24273a',
}

config.colors = {
  tab_bar = {
    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    background = '#24273a',

    -- The active tab is the one that has focus in the window
    active_tab = {
      -- The color of the background area for the tab
      bg_color = '#24273a',
      -- The color of the text for the tab
      fg_color = '#c0c0c0',

      -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
      -- label shown for this tab.
      -- The default is "Normal"
      intensity = 'Normal',

      -- Specify whether you want "None", "Single" or "Double" underline for
      -- label shown for this tab.
      -- The default is "None"
      underline = 'None',

      -- Specify whether you want the text to be italic (true) or not (false)
      -- for this tab.  The default is false.
      italic = false,

      -- Specify whether you want the text to be rendered with strikethrough (true)
      -- or not for this tab.  The default is false.
      strikethrough = false,
    },

    -- Inactive tabs are the tabs that do not have focus
    inactive_tab = {
      bg_color = '#1b1032',
      fg_color = '#808080',

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over inactive tabs
    inactive_tab_hover = {
      bg_color = '#3b3052',
      fg_color = '#909090',
      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab_hover`.
    },

    -- The new tab button that let you create new tabs
    new_tab = {
      bg_color = '#1b1032',
      fg_color = '#808080',

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over the new tab button
    new_tab_hover = {
      bg_color = '#3b3052',
      fg_color = '#909090',
      italic = true,

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab_hover`.
    },
  },
}


-- For example, changing the color scheme:
config.color_scheme = 'Catppuccin Macchiato'

config.default_prog = { 'C:/Program Files/PowerShell/7/pwsh', '-l' }

config.font = wezterm.font 'Hack NFM'

wezterm.on('update-right-status', function(window, pane)
  -- Each element holds the text for a cell in a "powerline" style << fade
  local cells = {}

  -- Figure out the cwd and host of the current pane.
  -- This will pick up the hostname for the remote host if your
  -- shell is using OSC 7 on the remote host.
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    cwd_uri = cwd_uri:sub(8)
    local slash = cwd_uri:find '/'
    local cwd = ''
    local hostname = ''
    if slash then
      hostname = cwd_uri:sub(1, slash - 1)
      -- Remove the domain name portion of the hostname
      local dot = hostname:find '[.]'
      if dot then
        hostname = hostname:sub(1, dot - 1)
      end
      -- and extract the cwd from the uri
      cwd = cwd_uri:sub(slash)

      table.insert(cells, cwd)
      table.insert(cells, hostname)
    end
  end

  -- I like my date/time in this style: "Wed Mar 3 08:14"
  -- local date = wezterm.strftime '%a %b %-d %H:%M'
  -- table.insert(cells, date)

  -- An entry for each battery (typically 0 or 1 battery)
  for _, b in ipairs(wezterm.battery_info()) do
    table.insert(cells, string.format('%.0f%%', b.state_of_charge * 100))
  end

  -- The powerline < symbol
  local LEFT_ARROW = utf8.char(0xe0b3)
  -- The filled in variant of the < symbol
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  -- Color palette for the backgrounds of each cell
  local colors = {
    '#3c1361',
    '#52307c',
    '#663a82',
    '#7c5295',
    '#b491c8',
  }

  -- Foreground color for the text across the fade
  local text_fg = '#c0c0c0'

  -- The elements to be formatted
  local elements = {}
  -- How many cells have been formatted
  local num_cells = 0

  -- Translate a cell into elements
  function push(text, is_last)
    local cell_no = num_cells + 1
    table.insert(elements, { Foreground = { Color = text_fg } })
    table.insert(elements, { Background = { Color = colors[cell_no] } })
    table.insert(elements, { Text = ' ' .. text .. ' ' })
    if not is_last then
      table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
      table.insert(elements, { Text = SOLID_LEFT_ARROW })
    end
    num_cells = num_cells + 1
  end

  while #cells > 0 do
    local cell = table.remove(cells, 1)
    push(cell, #cells == 0)
  end

  window:set_right_status(wezterm.format(elements))
end)


function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

function folder_name(cwd_uri) 
  print('path: ' .. cwd_uri)
  local path = {}
  for token in string.gmatch(cwd_uri, "[^/]+") do 
    table.insert(path, token)
  end
  if(#path ~= 0) then 
    return path[#path] 
  end
end

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local active_icon = wezterm.nerdfonts.md_triangle
    local inactive_icon = wezterm.nerdfonts.md_triangle_outline
    -- The filled in variant of the > symbol
    local EDGE_RIGHT = wezterm.nerdfonts.ple_lower_right_triangle
    local EDGE_LEFT = wezterm.nerdfonts.ple_lower_left_triangle

    print('#')
    print('######################################################')
    print('#')
    wezterm.log_info('format-tab')
    local active_pane = wezterm.mux.get_pane(tab.active_pane.pane_id)
    wezterm.log_info(active_pane:get_current_working_dir())
    local defaultTitle = tab_title(tab)
    if(active_pane == nil) then return defaultTitle end
    wezterm.log_info('has active pane')
    local current_folder = folder_name(active_pane:get_current_working_dir())
    if(current_folder == nil) then return defaultTitle end
    wezterm.log_info('has folder name')
    if(tab.is_active) then print('tab active: '.. current_folder) else print('tab is not active: ' .. current_folder) end

    local edge_background = '#24273a'
    local background = '#24273a'
    local foreground = '#808080'
    local edge_foreground = '#808080'

    local tab_in_active_color = { background = '#24273a', foreground = '#808080', active = '#24273a', edge = '#24273a' }
    local tab_active_color = { background = '#000000', foreground = '#eeeeee', active = '#00ff00', edge = '#24273a' }
    local color = tab_in_active_color
    local prefix_icon = inactive_icon
    if(tab.is_active) then 
      color = tab_active_color
      prefix_icon = active_icon
    end


    return {
      { Background = { Color = color.edge } },
      { Foreground = { Color = color.background } },
      { Background = { Color = color.background } },
      { Foreground = { Color = color.active } },
      { Text = ' ' .. prefix_icon },
      { Background = { Color =  color.background} },
      { Foreground = { Color = color.foreground } },
      { Text = ' ' .. current_folder .. ' '},
      { Background = { Color = color.edge } },
      { Foreground = { Color = color.background } },
      { Text = EDGE_LEFT },
    }
  end
)



-- and finally, return the configuration to wezterm
return config
