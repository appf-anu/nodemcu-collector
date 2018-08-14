print('init ...')

-- Settings
cfg = {}
gpioPins ={}
appStatus = {}
timerAllocation = {}

function readHeap()
 return node.heap()
end

function readRssi()
  return wifi.sta.getrssi()
end


node.compile('reader_bmx280.lua')
require('reader_bmx280')
node.compile('reader_bh1750.lua')
require('reader_bh1750')
node.compile('reader_dht.lua')
require('reader_dht')
node.compile('config.lua')
require('config')
node.compile('pins.lua')
require('pins')
node.compile('status.lua')
require('status')
node.compile('timers.lua')
require('timers')
i2c.setup(0, gpioPins.sda, gpioPins.scl, i2c.SLOW)

-- require('reader_slots')

--node.setcpufreq(cfg.nodeCpuFreq)

--require('wifi_client')
--require('telnetsrv')

-- Launch 'main' after 5 sec
timerAllocation.initAlarm = tmr.create()
timerAllocation.initAlarm:alarm(30000, tmr.ALARM_SINGLE, function()
  if (cfg.production) then
    require('main')
  end
end)
