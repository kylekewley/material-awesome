local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local TaskList = require('widget.task-list')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')
local mat_icon_button = require('widget.material.icon-button')
local mat_icon = require('widget.material.icon')
local left_menu = require('layout.left-panel')
local TagList = require('widget.tag-list')

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')


-- Create an imagebox widget which will contains an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
  local layoutBox = clickable_container(awful.widget.layoutbox(s))
  layoutBox:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        3,
        function()
          awful.layout.inc(-1)
        end
      ),
      awful.button(
        {},
        4,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        5,
        function()
          awful.layout.inc(-1)
        end
      )
    )
  )
  return layoutBox
end

local TopPanel = function(s, barHeight, menuWidth)
  local height = dpi(barHeight)

  local panel =
    wibox(
    {
      ontop = true,
      screen = s,
      height = height,
      width = s.geometry.width,
      x = s.geometry.x,
      y = s.geometry.y,
      stretch = false,
      bg = beautiful.background.hue_800,
      fg = beautiful.fg_normal,
      struts = {
        top = height
      }
    }
  )

  local leftMenu = left_menu(s, barHeight, menuWidth)
  panel.leftMenu = leftMenu

    -- Hamburger menu icon
    local menu_icon =
    wibox.widget {
        icon = icons.menu,
        size = height,
        widget = mat_icon
    }


  -- Hamburger menu button
  local home_button =
  wibox.widget {
      wibox.widget {
          menu_icon,
          widget = clickable_container
      },
      bg = beautiful.primary.hue_500,
      widget = wibox.container.background
  }

  home_button:buttons(
  gears.table.join(
  awful.button(
  {},
  1,
  nil,
  function()
      leftMenu:toggle()
  end
  )
  )
  )

  -- Clock / Calendar 24h format
  local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 11">%m/%d %H:%M</span>')
  local clock_widget = wibox.container.margin(textclock, dpi(8), dpi(8), dpi(2), dpi(2))
  local month_calendar = awful.widget.calendar_popup.month({
      screen = s,
  })
  month_calendar:attach(textclock)


  panel:struts(
  {
      top = height
    }
  )

  panel:setup {
    layout = wibox.layout.align.horizontal,
    expand = "none",
    {
        layout = wibox.layout.fixed.horizontal,
        home_button,
      TaskList(s)
    },
    TagList(s),
    {
      layout = wibox.layout.fixed.horizontal,

      require('widget.package-updater'),
      require('widget.wifi'),
      require('widget.battery'),

      -- Clock
      clock_widget,

      -- Layout box
      LayoutBox(s),
    }
  }

  return panel
end

return TopPanel
