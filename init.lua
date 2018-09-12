print('init ...')

-- Settings
cfg = {}
gpioPins ={}
appStatus = {}
timerAllocation = {}

function readSys()
 return node.heap(), wifi.sta.getrssi()
end

print("compiling reader_bmx280.lua")
node.compile("reader_bmx280.lua")
print("compiling reader_dht.lua")
node.compile("reader_dht.lua")
print("compiling reader_bh1750.lua")
node.compile("reader_bh1750.lua")
print("compiling transmission.lua")
node.compile("transmission.lua")
print("compiling wifi_client.lua")
node.compile("wifi_client.lua")
print("compiling ntp_sync.lua")
node.compile("ntp_sync.lua")
-- print("compiling telnetsrv.lua")
-- node.compile("telnetsrv.lua")
print("compiling read_round.lua")
node.compile("read_round.lua")

require('reader_bmx280')
require('reader_bh1750')
require('reader_dht')
require('config')
require('pins')
require('status')
require('timers')
-- require('telnetsrv')
i2c.setup(0, gpioPins.sda, gpioPins.scl, i2c.SLOW)
node.setcpufreq(cfg.nodeCpuFreq)
timerAllocation.initAlarm = tmr.create()
timerAllocation.initAlarm:alarm(10000, tmr.ALARM_SINGLE, function()
  if (cfg.production) then
    require('main')
  end
end)
