local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local apps = require('configuration.apps')
local dpi = require('beautiful').xresources.apply_dpi

local left_panel = function(screen, width, panelWidth)
  local action_bar_width = dpi(400)
  local panel_content_width = dpi(panelWidth)

  local panel =
    wibox {
    screen = screen,
    width = action_bar_width,
    height = screen.geometry.height,
    x = screen.geometry.x,
    y = screen.geometry.y,
    ontop = true,
    bg = beautiful.background.hue_800,
    fg = beautiful.fg_normal
  }

  panel.opened = false

  local backdrop =
    wibox {
    ontop = true,
    screen = screen,
    bg = '#00000022',
    type = 'dock',
    x = screen.geometry.x,
    y = screen.geometry.y,
    width = screen.geometry.width,
    height = screen.geometry.height
  }

  function panel:run_rofi()
    _G.awesome.spawn(
      apps.default.rofi,
      false,
      false,
      false,
      false,
      function()
        panel:toggle()
      end
    )
  end

  local openPanel = function(should_run_rofi)
    panel.width = panel_content_width
    backdrop.visible = true
    panel.visible = true

    if should_run_rofi then
      panel:run_rofi()
    end

    panel:emit_signal('opened')
  end

  local closePanel = function()
    panel.visible = false
    backdrop.visible = false
    panel:emit_signal('closed')
  end

  function panel:toggle(should_run_rofi)
    self.opened = not self.opened
    if self.opened then
      openPanel(should_run_rofi)
    else
      closePanel()
    end
  end

  backdrop:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          panel:toggle()
        end
      )
    )
  )

  panel:setup {
    layout = wibox.layout.align.horizontal,
    nil,
    {
      id = 'panel_content',
      bg = beautiful.background.hue_900,
      widget = wibox.container.background,
      {
        require('layout.left-panel.dashboard')(screen, panel),
        layout = wibox.layout.stack
      }
    },
  }
  return panel
end

return left_panel
