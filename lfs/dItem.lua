return {
  dataItemToString = function(dataItem)
   return dataItem[1] .. ',' .. dataItem[2] .. ',' .. dataItem[3]
  end,
  stringToDataItem = function(string)
    local dataItem = {}
    for t, r, v in string.gmatch(string, '(%d+),(%d+),(.+)') do
      dataItem[1] = t
      dataItem[2] = r
      dataItem[3] = v
    end
    return dataItem
  end
}
