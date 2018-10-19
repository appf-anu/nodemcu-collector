print('wifi_client_enduser ...')
print('MAC: ', wifi.sta.getmac())

wifi.setphymode(wifi.PHYMODE_G)
wifi.setmode(wifi.STATION)
wifi.sta.autoconnect(1)
ssid, password, bssid_set, bssid=wifi.sta.getconfig()
print("config ssid: "..ssid)
ssid, password, bssid_set, bssid=wifi.sta.getdefaultconfig()
print("defultconfig ssid: "..ssid)
-- wifi.sta.clearconfig()
--register events for wifi reconnect

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
    print("STATION_GOT_IP")
    if wifi.sta.getip() == nil then
      return
    end
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
    appStatus.wifiConnected = true
    LFS.telnet():open()
    LFS.ntp_sync()
end)

wifi.eventmon.register(wifi.STA_CONNECTING, function(previousState)
    if(previousState == wifi.STA_GOTIP) then
        print("Station lost connection with access point\n\tAttempting to reconnect...")
        appStatus.wifiConnected = false
    else
        print("STATION_CONNECTING")
    end
end)

if cfg.wifiSsid ~= nil and cfg.wifiPass ~= nil then
  wifi.setmode(wifi.STATION)
  wifi.sta.config({ssid = cfg.wifiSsid, pwd = cfg.wifiPass, auto = true})
else
  wifi.setmode(wifi.STATIONAP)
  wifi.ap.config({ssid=cfg.influxTags.node.."-"..node.chipid(), auth=wifi.OPEN})
  enduser_setup.manual(true)

  enduser_setup.start(
    function()
      print("Connected to wifi as:" .. wifi.sta.getip())
      print("5 seconds until enduser_setup shutdown...")
      appStatus.wifiConnected = true
      tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
          print("syncing clock to NTP")
          LFS.ntp_sync()
          LFS.telnet():open()
          enduser_setup.stop()
          wifi.setmode(wifi.STATION)
      end)
    end,
    function(err, str)
      print("enduser_setup: Err #" .. err .. ": " .. str)
    end
  )
end
