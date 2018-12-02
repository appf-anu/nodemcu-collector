gpioPins = {
  updatePin = 1,
  indicatorLed = 0,
  sda = 3,
  scl = 4,
  dht = 5
}
timerAllocation = {
  initAlarm = 0,
  notification = 1,
  otaUpdate = 2,
  syncSntp = 3,
  transmission = 4,
  readRound = 5
}
appStatus = {
  wifiConnected = false,
  transmitting = false,
  lastRoundSlot = 0,
  baseTz = false,
  dataFileExists = false,
  lastSeekPosition = 0,
  reading = false,
  ntpHour = 0,
  disp = nil,
  drawing = false
  ledState = false
}
