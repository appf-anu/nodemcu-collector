print('main ...')

appStatus.dataFileExists = file.exists(cfg.dataFileName)

dataQueue = {}

function dataItemToString(dataItem)
  return dataItem[1] .. ',' .. dataItem[2] .. ',' .. dataItem[3]
end
function stringToDataItem(string)
  local dataItem = {}
  for t, r, v in string.gmatch(string, '(%d+),(%d+),(.+)') do
    dataItem[1] = t
    dataItem[2] = r
    dataItem[3] = v
  end
  return dataItem
end

function unrequire(m)
  package.loaded[m] = nil
  _G[m] = nil
end

if file.exists("lfs.img") then
  print("-----LFS-----")
  if file.exists("fs.img") then print("removing old lfs img") file.remove("fs.img") end
  print("moving new lfs.img to staging")
  file.rename("lfs.img", "fs.img")
  print("flashing new lfs. will reboot with WDT bootreason")
  local valid = node.flashreload("fs.img")
  if not valid then print("invalid img wth") end
end

local _initted = pcall(node.flashindex("_init"))
print("_initted: "..tostring(_initted))

function LFS_OTA()
  print("-----OTA-----")
  LFS.HTTP_OTA(cfg.ota_address, cfg.ota_path)
end

gpio.mode(gpioPins.updatePin, gpio.INT)
gpio.trig(gpioPins.updatePin, "down", LFS_OTA)

timerAllocation.otaUpdate = tmr.create()
timerAllocation.otaUpdate:register(
  3600000,
  tmr.ALARM_AUTO,
  function()
    appStatus.updateHour = appStatus.updateHour - 1
    if appStatus.updateHour == 0 then
      appStatus.updateHour = 24
      LFS_OTA()
    end
  end
)
timerAllocation.otaUpdate.start(timerAllocation.otaUpdate)

gpio.mode(gpioPins.indicatorLed, gpio.OUTPUT)
local ledState = false
timerAllocation.flashLed = tmr.create()
timerAllocation.flashLed:register(
  250,
  tmr.ALARM_AUTO,
  function()
    if ledState == true then
      ledState = false
      gpio.write(gpioPins.indicatorLed, gpio.HIGH)
    else
      ledState = true
      gpio.write(gpioPins.indicatorLed, gpio.LOW)
    end
  end
)
timerAllocation.flashLed.start(timerAllocation.flashLed)


timerAllocation.syncSntp = tmr.create()
timerAllocation.syncSntp:register(
  3600000,
  tmr.ALARM_AUTO,
  LFS.ntp_sync
)
timerAllocation.syncSntp.start(timerAllocation.syncSntp)


timerAllocation.readRound = tmr.create()
timerAllocation.readRound:register(
  cfg.readRoundInterval,
  tmr.ALARM_AUTO,
  LFS.read_round
)
tmr.start(timerAllocation.readRound)

timerAllocation.transmission = tmr.create()
timerAllocation.transmission:register(
  cfg.transmissionInterval,
  tmr.ALARM_AUTO,
  LFS.transmission
)
tmr.start(timerAllocation.transmission)

LFS.wifi_client()

print("heap: "..node.heap())
