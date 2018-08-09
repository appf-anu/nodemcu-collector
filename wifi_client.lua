print('wifi_client ...')
print('MAC: ', wifi.sta.getmac())
print('chip: ', node.chipid())

--register events for wifi reconnect
wifi.eventmon.register(wifi.STA_CONNECTING, function(previousState)
    if(previousState == wifi.STA_GOTIP) then
        print("Station lost connection with access point\n\tAttempting to reconnect...")
        appStatus.wifiConnected = false
    else
        print("STA_CONNECTING")
    end
end)

wifi.eventmon.register(wifi.STA_GOTIP, function()
    if wifi.sta.getip() == nil then
        return
    end
    print("WiFi connection established, IP address: " .. wifi.sta.getip())
    appStatus.wifiConnected = true
end)

wifi.setmode(wifi.STATIONAP)
enduser_setup.start(
  function(
    print("Connected to wifi as:" .. wifi.sta.getip())
    appStatus.wifiConnected = true
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end
)
