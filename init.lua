print('init ...')
-- Settings
cfg = {}
gpioPins ={}
appStatus = {}
timerAllocation = {}

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

require('config')
node.setcpufreq(cfg.nodeCpuFreq)

print(dump(cfg))
-- print("compiling reader_bme280.lua")
-- node.compile("reader_bme280.lua")
-- print("compiling reader_bme680.lua")
-- node.compile("reader_bme680.lua")
-- print("compiling reader_dht.lua")
-- node.compile("reader_dht.lua")
-- print("compiling reader_bh1750.lua")
-- node.compile("reader_bh1750.lua")
-- print("compiling reader_slots.lua")
-- node.compile("reader_slots.lua")
-- print("compiling transmission_http.lua")
-- node.compile("transmission_http.lua")
-- print("compiling transmission.lua")
-- node.compile("transmission.lua")
-- print("compiling wifi_client.lua")
-- node.compile("wifi_client.lua")
-- print("compiling ntp_sync.lua")
-- node.compile("ntp_sync.lua")
-- print("compiling telnetsrv.lua")
-- node.compile("telnetsrv.lua")
-- print("compiling read_round.lua")
-- node.compile("read_round.lua")
--
-- print("compiling main.lua")
-- node.compile("main.lua")

require('pins')
require('status')
require('timers')

i2c.setup(0, gpioPins.sda, gpioPins.scl, i2c.SLOW)

for i=0,127 do
  i2c.start(0)
  resCode = i2c.address(0, i, i2c.TRANSMITTER)
  i2c.stop(0)
  if resCode == true then print("We have a device on address 0x" .. string.format("%02x", i) .. " (" .. i ..")") end
end

timerAllocation.initAlarm = tmr.create()
timerAllocation.initAlarm:alarm(10000, tmr.ALARM_SINGLE, function()
  require('main')
end)
