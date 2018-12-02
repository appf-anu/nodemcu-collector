print('---- wifi_client ----')
print('MAC: ', wifi.sta.getmac())
wifi.setphymode(wifi.PHYMODE_G)
wifi.setmode(wifi.STATION)

wifi.sta.autoconnect(1)
ssid, password, bssid_set, bssid=wifi.sta.getconfig()
print("config ssid: "..ssid)
ssid, password, bssid_set, bssid=wifi.sta.getdefaultconfig()
print("defultconfig ssid: "..ssid)

-- wifi.sta.clearconfig()

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
    print("STATION_GOT_IP")
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
    appStatus.wifiConnected = true
    LFS.ntp_sync()
    LFS.telnet():open()
    timerAllocation.notification.stop(timerAllocation.notification)
end)

wifi.eventmon.register(wifi.STA_CONNECTING, function(previousState)
    if(previousState == wifi.STA_GOTIP) then
        print("Station lost connection with access point\n\tAttempting to reconnect...")
        appStatus.wifiConnected = false
        timerAllocation.notification.start(timerAllocation.notification)
    else
        print("STATION_CONNECTING")
    end
end)

wifi.sta.config({ssid = cfg.wifiSsid, pwd = cfg.wifiPass, auto = true})
