print('init ...')
-- Settings
cfg = {}
gpioPins ={}
appStatus = {}
timerAllocation = {}

require('config')
require("programData")

print('check for lfs.img')
gpio.mode(gpioPins.indicatorLed, gpio.OUTPUT)
if file.exists("lfs.img") then
  gpio.write(gpioPins.indicatorLed, gpio.LOW)
  print("-----LFS-----")
  if file.exists("fs.img") then
    print("moving old lfs img")
    if file.exists("backup.img") then file.remove("backup.img") end
    file.rename("fs.img", "backup.img") end
  print("moving new lfs.img to staging")
  file.rename("lfs.img", "fs.img")
  print("flashing new lfs. will reboot with WDT bootreason")
  local valid = node.flashreload("fs.img")
  print("invalid img recovering")
  file.remove("lfs.img")
  file.rename("backup.img", "lfs.img")
  node.restart()
end
gpio.write(gpioPins.indicatorLed, gpio.HIGH)

function dump(o,z)
   if z == nil then z = 0 end
   if type(o) == 'table' then
      local s = '\n'
      local prefix = string.rep(' ',z)
      for k,v in pairs(o) do
         if type(v) == 'table' then z = z+1 s = s..'\n' end
         s = s..prefix..k..': '..string.rep(' ', 20-#k) .. dump(v, z) .. '\n'
      end
      return s
   else
      return tostring(o)
   end
end

node.setcpufreq(cfg.nodeCpuFreq)

print(dump(cfg))

-- print("compiling main.lua")
-- node.compile("main.lua")

i2c.setup(0, gpioPins.sda, gpioPins.scl, i2c.SLOW)

for i=0,127 do
  i2c.start(0)
  resCode = i2c.address(0, i, i2c.TRANSMITTER)
  i2c.stop(0)
  if resCode == true then
    print("We have a device on address 0x" .. string.format("%02x", i) .. " (" .. i ..")")
    if i == 0x3c then
      print("display connected on 0x" .. string.format("%02x", i))
      appStatus.disp = u8g2.ssd1306_i2c_128x64_noname(0, i)
      appStatus.disp:setDisplayRotation(u8g2.R3)
      appStatus.disp:setPowerSave(0)
      appStatus.disp:setFont(u8g2.font_6x10_tf)
      appStatus.disp:setFontDirection(0)
      appStatus.disp:setFontMode(1)
      appStatus.disp:setDrawColor(1)
      appStatus.disp:setFontRefHeightExtendedText()
      appStatus.disp:setFontPosTop()
    end
  end
end
function drawStatusToOled(x,y, string)
  appStatus.disp:clearBuffer()
  appStatus.disp:drawFrame(0,0,64,128)
  appStatus.disp:drawStr(x, y, string)
  appStatus.disp:sendBuffer()
end

drawStatusToOled(3,3, "init...")
require("trig")

local ledState = false
local angle = -72
local xoff = 32.0
local yoff = 100.0
timerAllocation.notification = tmr.create()
local time = 50
if appStatus.disp ~= nil then time = 1000 end

timerAllocation.notification:register(
  time,
  tmr.ALARM_AUTO,
  function()
    if appStatus.disp ~= nil then
          angle = angle + 72
          appStatus.disp:setDrawColor(2)
          local p = rotate_point({x=0, y=-32}, angle)
          appStatus.disp:drawLine(xoff, yoff, p.x+xoff, p.y+yoff)
          appStatus.disp:sendBuffer()
    else
      if ledState == true then
        ledState = false
        gpio.write(gpioPins.indicatorLed, gpio.HIGH)
      else
        ledState = true
        gpio.write(gpioPins.indicatorLed, gpio.LOW)
      end
    end
  end
)
timerAllocation.notification.start(timerAllocation.notification)


local _initted = pcall(node.flashindex("_init"))
print("_initted: "..tostring(_initted))

timerAllocation.initAlarm = tmr.create()
timerAllocation.initAlarm:alarm(10000, tmr.ALARM_SINGLE, function()
  tmr.stop(timerAllocation.notification)
  gpio.write(gpioPins.indicatorLed, gpio.HIGH)
  require('main')
end)
