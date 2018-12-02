print('---- init ----')


local _, ext_reset_clause = node.bootreason()
if ext_reset_clause == 0 then print("BOOTREASON: power-on") end
if ext_reset_clause == 1 then print("BOOTREASON: hardware watchdog reset") end
if ext_reset_clause == 2 then print("BOOTREASON: exception reset") end
if ext_reset_clause == 3 then print("BOOTREASON: software watchdog reset") end
if ext_reset_clause == 4 then print("BOOTREASON: software restart") end
if ext_reset_clause == 5 then print("BOOTREASON: wake from deep sleep") end
if ext_reset_clause == 6 then print("BOOTREASON: external reset") end

-- Settings
cfg = {}
gpioPins ={}
appStatus = {}
timerAllocation = {}
currentDataBlock = {}
dataQueue = {}

require('config')
require("programData")

gpio.mode(gpioPins.indicatorLed, gpio.OUTPUT)
if file.exists("fs.img") then local oldhash = crypto.toHex(crypto.fhash("sha1", "fs.img")) print("fs.img hash:  "..oldhash) end

print('check for lfs.img')
if file.exists("lfs.img") then
  gpio.write(gpioPins.indicatorLed, gpio.LOW)
  print("-----LFS-----")
  local newhash = crypto.toHex(crypto.fhash("sha1", "lfs.img"))
  print("lfs.img hash: "..newhash)

  if file.exists("fs.img") then
    if oldhash == newhash then
      print("reflashing image")
      file.remove("fs.img")
    else
      print("backing up old lfs img")
      if file.exists("backup.img") then file.remove("backup.img") end
      file.rename("fs.img", "backup.img") end
    end
  print("moving new lfs img to staging area")
  file.rename("lfs.img", "fs.img")
  print("flashing new lfs. will reboot with hardware watchdog reset")
  local valid = node.flashreload("fs.img")
  print("invalid img recovering")
  file.remove("lfs.img")
  file.rename("backup.img", "lfs.img")
  node.restart()
end
gpio.write(gpioPins.indicatorLed, gpio.HIGH)


node.setcpufreq(cfg.nodeCpuFreq)

local _initted = pcall(node.flashindex("_init"))
print("_initted: "..tostring(_initted))


print(LFS.dumptable(cfg))

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
  if appStatus.disp == nil then return end
  appStatus.disp:clearBuffer()
  appStatus.disp:drawFrame(0,0,64,128)
  appStatus.disp:drawStr(x, y, string)
  appStatus.disp:sendBuffer()
end

drawStatusToOled(3,3, "init...")



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
          local p = LFS.trig():rotate_point({x=0, y=-32}, angle)
          appStatus.disp:drawLine(xoff, yoff, p.x+xoff, p.y+yoff)
          appStatus.disp:sendBuffer()
    else
      if appStatus.ledState == true then
        appStatus.ledState = false
        gpio.write(gpioPins.indicatorLed, gpio.HIGH)
      else
        appStatus.ledState = true
        gpio.write(gpioPins.indicatorLed, gpio.LOW)
      end
    end
  end
)
timerAllocation.notification.start(timerAllocation.notification)


timerAllocation.initAlarm = tmr.create()
timerAllocation.initAlarm:alarm(10000, tmr.ALARM_SINGLE, function()
  gpio.write(gpioPins.indicatorLed, gpio.HIGH)
  LFS.main()
end)
