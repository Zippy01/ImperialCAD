if not Config.ERSsupport then return end

exports['night_ers']:SetERSVehicleInfoDisplay(false) -- Sets the display for vehicle information on traffic stops to true or false.
exports['night_ers']:SetERSIDCardInfoDisplay(false) -- Sets the display for ID cards to true or false.

--[[
RegisterNetEvent('night_ers:ERS_GetPedDataFromServer_cb', function(_, data)
    TriggerServerEvent('ImperialCAD:ERSPED:SERVER', data)
end)

RegisterNetEvent('night_ers:receiveVehicleInformation', function(_, data)
  
    TriggerServerEvent('ImperialCAD:ERSVEHICLE:SERVER', data)

end)
]]