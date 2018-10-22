print("---- ntp_sync ----")
local sntpServerIp

function doNtpSync()
  sntp.sync(
    sntpServerIp,
    function(sec,usec,server)
      print('sntp sync success', sec, usec, server)
    end,
    function()
      print('sntp sync failed!')
    end
  )
end

if (rtctime.get() == 0) then
  appStatus.ntpHour = 0
end
if (appStatus.ntpHour == 0 and appStatus.wifiConnected) then
  net.dns.resolve(cfg.sntpServerName, function(sk, ip)
    if (ip) then
      print('resolved ' .. cfg.sntpServerName .. ' to ' .. ip)
      sntpServerIp = ip
    else
      print('resolve ' .. cfg.sntpServerName .. ' fail!')
      sntpServerIp = cfg.sntpServerIbrop
    end
    doNtpSync()
  end)
end

appStatus.ntpHour = appStatus.ntpHour + 1
if (appStatus.ntpHour >= cfg.sntpRefresh) then
  appStatus.ntpHour = 0
end
