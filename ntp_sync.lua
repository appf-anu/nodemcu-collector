print('ntp_sync ...')
local hourCount = 0
local sntpServerIp

function startNtpSync()
  if (rtctime.get() == 0) then
    hourCount = 0
  end
  if (hourCount == 0 and appStatus.wifiConnected) then
    net.dns.resolve(cfg.sntpServerName, function(sk, ip)
      if (ip) then
        print('Resolved ' .. cfg.sntpServerName .. ' to ' .. ip)
        sntpServerIp = ip
      else
        print('Resolve ' .. cfg.sntpServerName .. ' fail!')
        print('Fallback to ' .. cfg.sntpServerIp)
        sntpServerIp = cfg.sntpServerIbrop
      end

      doNtpSync()
    end)
  end

  hourCount = hourCount + 1
  if (hourCount >= cfg.sntpRefresh) then
    hourCount = 0
  end
end

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

timerAllocation.syncSntp = tmr.create()
timerAllocation.syncSntp:register(1800000, tmr.ALARM_AUTO, startNtpSync)
timerAllocation.syncSntp.start(timerAllocation.syncSntp)

startNtpSync()