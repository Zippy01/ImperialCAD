if not Config.ERSsupport then return end

RegisterNetEvent('night_ers:ERS_GetPedDataFromServer_cb', function(_, data)
    TriggerServerEvent('ImperialCAD:ERSPED:SERVER', data)
end)

RegisterNetEvent('night_ers:receiveVehicleInformation', function(_, data)
  
    TriggerServerEvent('ImperialCAD:ERSVEHICLE:SERVER', data)

end)