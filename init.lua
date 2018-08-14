print('init ...')

-- Settings
cfg = {}
gpioPins ={}
appStatus = {}
timerAllocation = {}

function readSys()
 return node.heap(), wifi.sta.getrssi()
end

require('reader_bmx280')
require('reader_bh1750')
require('reader_dht')
require('config')
require('pins')
require('status')
require('timers')
i2c.setup(0, gpioPins.sda, gpioPins.scl, i2c.SLOW)
node.setcpufreq(cfg.nodeCpuFreq)
timerAllocation.initAlarm = tmr.create()
timerAllocation.initAlarm:alarm(10000, tmr.ALARM_SINGLE, function()
  if (cfg.production) then
    require('main')
  end
end)
