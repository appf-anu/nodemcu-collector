local spinner = 0
require("trig")
i2c.setup(0, 3, 4, i2c.SLOW)
disp = u8g2.ssd1306_i2c_128x64_noname(0, 0x3c)
disp:setDisplayRotation(u8g2.R3)
disp:setPowerSave(0)
disp:setFont(u8g2.font_6x10_tf)
disp:setFontDirection(0)
disp:setFontMode(1)
disp:setDrawColor(1)
disp:setFontRefHeightExtendedText()
disp:setFontPosTop()

local ledState = false
spinner = tmr.create()
local time = 1000
local angle = 0
local n = 0
disp:drawStr(0, 0, "start")
spinner:register(
  time,
  tmr.ALARM_AUTO,
  function()
      xoff = 32.0
      yoff = 100.0
      angle = angle + 72
      disp:setDrawColor(2)
      local p = rotate_point({x=0, y=-32}, angle)

      disp:drawLine(xoff, yoff, p.x+xoff, p.y+yoff)

      disp:sendBuffer()
  end
)
spinner.start(spinner)
