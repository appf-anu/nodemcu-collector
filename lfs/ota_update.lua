print('ntp_sync ...')
local sntpServerIp

function LFS_OTA()
  print("-----OTA-----")
  LFS.HTTP_OTA(cfg.otaHost, cfg.otaPath)
end

if rtctime.get()==0 then
  return
end

local tm = rtctime.epoch2cal(rtctime.get())
if tm.hour == cfg.otaRefresh then
  LFS_OTA()
end
