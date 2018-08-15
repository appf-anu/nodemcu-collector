print('wifi_client ...')
print('MAC: ', wifi.sta.getmac())
print('chip: ', node.chipid())

wifi.sta.clearconfig()
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

wifi.eventmon.register(wifi.STA_GOTIP, function()
    print("STATION_GOT_IP")
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
    appStatus.wifiConnected = true
    appStatus.configured = true 
end)

if cfg.ap ~= nil then
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
            appStatus.configured = true
        end)
      end,
      function(err, str)
        print("enduser_setup: Err #" .. err .. ": " .. str)
      end
    )
else
    wifi.setphymode(wifi.PHYMODE_B)
    wifi.setmode(wifi.STATION)
    wifi.sta.config({ssid = cfg.wifiSsid, pwd = cfg.wifiPass, auto = true})
end