local awful = require('awful')
local left_panel = require('layout.left-panel')
local top_panel = require('layout.top-panel')

local topBarHeight = 24
local leftBarWidth = 48
local leftPanelWidth = 400

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(
  function(s)
    s.mypromptbox = awful.widget.prompt()
    s.top_panel = top_panel(s, topBarHeight, leftPanelWidth)
  end
)

-- Hide bars when app go fullscreen
function updateBarsVisibility()
  for s in screen do
    if s.selected_tag then
      local fullscreen = s.selected_tag.fullscreenMode
      -- Order matter here for shadow
      s.top_panel.visible = not fullscreen
    end
  end
end

_G.tag.connect_signal(
  'property::selected',
  function(t)
    updateBarsVisibility()
  end
)

_G.client.connect_signal(
  'property::fullscreen',
  function(c)
    c.first_tag.fullscreenMode = c.fullscreen
    updateBarsVisibility()
  end
)

_G.client.connect_signal(
  'unmanage',
  function(c)
    if c.fullscreen then
      c.screen.selected_tag.fullscreenMode = false
      updateBarsVisibility()
    end
  end
)
