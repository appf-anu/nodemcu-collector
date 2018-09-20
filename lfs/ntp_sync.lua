print('ntp_sync ...')
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
  appStatus.hourCount = 0
end
if (appStatus.hourCount == 0 and appStatus.wifiConnected) then
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

appStatus.hourCount = appStatus.hourCount + 1
if (appStatus.hourCount >= cfg.sntpRefresh) then
  appStatus.hourCount = 0
end
