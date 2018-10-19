print('main ...')

appStatus.dataFileExists = file.exists(cfg.dataFileName)

if appStatus.dataFileExists == true then print("data file exists!") end

local _, ext_reset_clause = node.bootreason()
if ext_reset_clause == 0 then print("BOOTREASON: power-on") end
if ext_reset_clause == 1 then print("BOOTREASON: hardware watchdog reset") end
if ext_reset_clause == 2 then print("BOOTREASON: exception reset") end
if ext_reset_clause == 3 then print("BOOTREASON: software watchdog reset") end
if ext_reset_clause == 4 then print("BOOTREASON: software restart") end
if ext_reset_clause == 5 then print("BOOTREASON: wake from deep sleep") end
if ext_reset_clause == 6 then print("BOOTREASON: external reset") end


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
  function ()
    LFS.read_round()
    if appStatus.disp ~= nil then
      timerAllocation.notification = tmr.create()
      timerAllocation.notification:alarm(1500, tmr.ALARM_SINGLE, function()
        LFS.updateScreen()
      end)
     end
  end
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

drawStatusToOled(3,3, "started")

print("heap: "..node.heap())
