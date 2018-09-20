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
timerAllocation.initAlarm:alarm(30000, tmr.ALARM_SINGLE, function()
  require('main')
end)
