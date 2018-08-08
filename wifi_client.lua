print('wifi_client ...')
print('MAC: ', wifi.sta.getmac())
print('chip: ', node.chipid())
print('heap: ', node.heap())

wifi.eventmon.register(wifi.STA_GOTIP, function()
    print("STATION_GOT_IP")
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
    appStatus.wifiConnected = true
end)

wifi.eventmon.register(wifi.STA_CONNECTING, function(previousState)
    if(previousState == wifi.STA_GOTIP) then
        print("Station lost connection with access point\n\tAttempting to reconnect...")
        appStatus.wifiConnected = false
    else
        print("STATION_CONNECTING")
    end
end)

wifi.setmode(wifi.STATIONAP)

ssid = "Node" .. node.chipid()
wifi.ap.config({ssid=ssid, auth=wifi.OPEN})
enduser_setup.manual(true)
enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
    appStatus.wifiConnected = true
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end
);
