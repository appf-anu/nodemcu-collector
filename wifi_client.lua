print('wifi_client ...')
print('MAC: ', wifi.sta.getmac())
print('chip: ', node.chipid())
station_cfg={}
station_cfg.ssid = cfg.ssid
station_cfg.pwd = cfg.pwd
station_cfg.save = true
station_cfg.auto=true
wifi.setphymode(wifi.PHYMODE_N)
wifi.setmode(wifi.STATION)
wifi.sta.autoconnect(1)

wifi.sta.config(station_cfg)
=======
-- wifi.sta.clearconfig()
--register events for wifi reconnect
wifi.eventmon.register(wifi.STA_CONNECTING, function(previousState)
    if(previousState == wifi.STA_GOTIP) then
        print("Station lost connection with access point\n\tAttempting to reconnect...")
        appStatus.wifiConnected = false
    else
        print("STA_CONNECTING")
        print(wifi.sta.getip())
    end
end)
>>>>>>> a9b4ba6f20a10c06fe80990ad926e0d9eb9df540

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
    print("STATION_GOT_IP")
    if wifi.sta.getip() == nil then
      return
    end
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
    appStatus.wifiConnected = true
<<<<<<< HEAD
    startNtpSync()
end)

wifi.eventmon.register(wifi.STA_CONNECTING, function(previousState)
    if(previousState == wifi.STA_GOTIP) then 
        print("Station lost connection with access point\n\tAttempting to reconnect...")
        appStatus.wifiConnected = false
    else
        print("STATION_CONNECTING")
    end
end)
=======
end)

if cfg.wifiSsid ~= nil and cfg.wifiPass ~= nil then
  wifi.setmode(wifi.STATION)
  wifi.sta.config({ssid = cfg.wifiSsid, pwd = cfg.wifiPass, auto = true})
else
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.config({ssid="Node-"..node.chipid(), auth=wifi.OPEN})
  enduser_setup.manual(true)

  enduser_setup.start(
    function()
      print("Connected to wifi as:" .. wifi.sta.getip())
      wifi.sta.autoconnect(1)
      print("5 seconds until enduser_setup shutdown...")
      appStatus.wifiConnected = true
      tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
          print("syncing clock to NTP")
          startNtpSync()
          enduser_setup.stop()
          wifi.setmode(wifi.STATION)
      end)
    end,
    function(err, str)
      print("enduser_setup: Err #" .. err .. ": " .. str)
    end
  )
end
>>>>>>> a9b4ba6f20a10c06fe80990ad926e0d9eb9df540
