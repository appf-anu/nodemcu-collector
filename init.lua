print('init ...')

-- Settings
cfg = {}
gpioPins ={}
appStatus = {}
timerAllocation = {}
readerSlots = {}
influxMeasurement = {}
fieldNames = {}
captureDelta = {}

require('config')
--require('config_local')/
require('pins')
require('status')
require('timers')
require('reader_slots')

--node.setcpufreq(cfg.nodeCpuFreq)

require('wifi_client')
require('telnetsrv')

-- Launch 'main' after 5 sec
timerAllocation.initAlarm = tmr.create()
timerAllocation.initAlarm:alarm(10000, tmr.ALARM_SINGLE, function()
  if (cfg.production) then
    require('main')
  end
end)
