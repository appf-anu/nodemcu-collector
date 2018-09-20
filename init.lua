print('init ...')

print('check for lfs.img')
if file.exists("lfs.img") then
  print("-----LFS-----")
  if file.exists("fs.img") then print("moving old lfs img") file.rename("fs.img", "backup.img") end
  print("moving new lfs.img to staging")
  file.rename("lfs.img", "fs.img")
  print("flashing new lfs. will reboot with WDT bootreason")
  local valid = node.flashreload("fs.img")
  print("invalid img recovering")
  file.remove("lfs.img")
  file.rename("backup.img", "lfs.img")
  node.restart()
end

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

require("programData")



local _initted = pcall(node.flashindex("_init"))
print("_initted: "..tostring(_initted))

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
