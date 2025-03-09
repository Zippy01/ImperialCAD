local communityid = GetConvar("imperial_community_id", "")

AddEventHandler('playerSpawned', function()
    local ssn = GetResourceKvpString("civ_ssn")
    local name = GetResourceKvpString("civ_name")
    local age = GetResourceKvpString("civ_age")
    local address = GetResourceKvpString("civ_address")
    local commId = GetResourceKvpString("commId")

    if (ssn and #ssn > 8) and name and age and address and (commId == communityid) then
        TriggerEvent("notify", "Your active civilian profile: " .. name)
    else
        TriggerEvent("notify", "You do not have an active civilian profile. Use /setciv to set one.")
    end
end)


RegisterNetEvent("ImperialCAD:setActiveCiv")
AddEventHandler("ImperialCAD:setActiveCiv", function(data)
    if data.ssn then
        SetResourceKvp("civ_ssn", data.ssn)
        SetResourceKvp("civ_name", data.name)
        SetResourceKvp("civ_age", data.age)
        SetResourceKvp("civ_address", data.address)
        SetResourceKvp("commId", communityid)

        TriggerEvent("notify", "Civilian profile activated: " .. data.name)
    else
        TriggerEvent("notify", "Data reception error. Please check logs.")
        DeleteResourceKvp("civ_ssn")
        DeleteResourceKvp("civ_name")
        DeleteResourceKvp("civ_age")
        DeleteResourceKvp("civ_address")
        DeleteResourceKvp("commId")
    end
end)

RegisterCommand("setciv", function(source, args, rawCommand)
    local ssn = args[1]
    if ssn and #ssn > 8 then
        TriggerServerEvent("ImperialCAD:getCivData", ssn)
    else
        TriggerEvent("notify", "Invalid SSN provided, Please check and try again.")
    end
end, false)

RegisterCommand("getciv", function(source, args, rawCommand)
    local name = GetResourceKvpString("civ_name")
    local age = GetResourceKvpString("civ_age")
    local commId = GetResourceKvpString("commId")

    if name and age then
        TriggerEvent("notify", "Current Civilian: Name - " .. name .. ", Age - " .. age .. ", Community ID - " .. commId)
    else
        TriggerEvent("notify", "No active civilian profile.")
    end
end, false)

RegisterCommand("clearciv", function(source, args, rawCommand)
    DeleteResourceKvp("civ_ssn")
    DeleteResourceKvp("civ_name")
    DeleteResourceKvp("civ_age")
    DeleteResourceKvp("civ_address")
    DeleteResourceKvp("commId")

    TriggerEvent("notify", "Active civilian profile has been cleared.")
end, false)

RegisterNetEvent("notify")
AddEventHandler("notify", function(message)
    local fullMessage = "[IMPERIAL] " .. message
    SetNotificationTextEntry("STRING")
    AddTextComponentString(fullMessage)
    DrawNotification(false, true)
end)


RegisterCommand("regveh", function(source, args, rawCommand)
    local ped = PlayerPedId()
    if IsPedSittingInAnyVehicle(ped) then
        local ssn = GetResourceKvpString("civ_ssn")
        if ssn then 
            local vehicle = GetVehiclePedIsIn(ped, false)
            local vehicleHash = GetEntityModel(vehicle)
            local vehicleModelName = GetDisplayNameFromVehicleModel(vehicleHash)
            local plate = GetVehicleNumberPlateText(vehicle)

            local colorName = GetVehicleColorName(vehicle)
            local makeName = GetVehicleMakeName(string.upper(vehicleModelName))
            
            if vehicleModelName == "CARNOTFOUND" or vehicleModelName == nil then
                vehicleModelName = "UNKNOWN"  
                TriggerEvent("notify", "Model Unknown, Proceeding anyways...")
            end

            local primaryColor, _ = GetVehicleColours(vehicle)

            if Config.debug then
            print("Color ID for this request is " .. primaryColor)
            end
            --TriggerServerEvent("ImperialCAD:registerVehicleToCAD", ssn, vehicleModelName, plate, colorName, makeName)
            TriggerEvent("notify", "Registration has been sent to the DMV.")
        else
            TriggerEvent("notify", "You must set an active civilian before registering a vehicle.")
        end
    else
        TriggerEvent("notify", "You must be in a vehicle to register it.")
    end
end, false)


function GetStoredSSN()
    return GetResourceKvpString("civ_ssn")
end

exports('GetStoredSSN', GetStoredSSN)
print ()


function GetStoredName()
    return GetResourceKvpString("civ_name")
end

exports('GetStoredName', GetStoredName)
print ()

