print('main ...')

appStatus.dataFileExists = file.exists(cfg.dataFileName)

dataQueue = {}

function LFS_OTA()
  print("-----OTA-----")
  LFS.HTTP_OTA(cfg.otaHost, cfg.otaPath)
end

gpio.mode(gpioPins.updatePin, gpio.INT)
gpio.trig(gpioPins.updatePin, "down", LFS_OTA)

timerAllocation.otaUpdate = tmr.create()
timerAllocation.otaUpdate:register(
  3600000,
  tmr.ALARM_AUTO,
  LFS.ota_update
)
timerAllocation.otaUpdate.start(timerAllocation.otaUpdate)

gpio.mode(gpioPins.indicatorLed, gpio.OUTPUT)
local ledState = false
timerAllocation.flashLed = tmr.create()
timerAllocation.flashLed:register(
  500,
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
