local communityid = GetConvar("imperial_community_id", "")
local idVisible = false

function Notify(message)
    local fullMessage = "[IMPERIAL] " .. message
    SetNotificationTextEntry("STRING")
    AddTextComponentString(fullMessage)
    DrawNotification(false, true)
end

local function HideDriverLicense()
    if not idVisible then return end

    idVisible = false
    SendNUIMessage({ action = "hide" })
end

function GetStoredSSN()
    return GetResourceKvpString("civ_ssn")
end

function GetStoredName()
    return GetResourceKvpString("civ_name")
end

AddEventHandler('playerSpawned', function()
    local ssn = GetResourceKvpString("civ_ssn")
    local name = GetResourceKvpString("civ_name")
    local age = GetResourceKvpString("civ_age")
    local address = GetResourceKvpString("civ_address")
    local commId = GetResourceKvpString("commId")

    if (ssn and #ssn > 8) and name and age and address and (commId == communityid) then
        Notify("Your active civilian profile: " .. name)
    else
        Notify("You do not have an active civilian profile. Use /setciv to set one.")
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

        Notify("Civilian profile activated: " .. data.name)
    else
        Notify("Data error. Please check server logs.")
        DeleteResourceKvp("civ_ssn")
        DeleteResourceKvp("civ_name")
        DeleteResourceKvp("civ_age")
        DeleteResourceKvp("civ_address")
        DeleteResourceKvp("commId")
    end
end)

RegisterNetEvent("ImperialCAD:clientCivilianStatusUpdated")
AddEventHandler("ImperialCAD:clientCivilianStatusUpdated", function(data)
    if type(data) ~= "table" then return end

    if data.status == "deleted" and data.ssn == GetResourceKvpString("civ_ssn") then
        DeleteResourceKvp("civ_ssn")
        DeleteResourceKvp("civ_name")
        DeleteResourceKvp("civ_age")
        DeleteResourceKvp("civ_address")
        DeleteResourceKvp("commId")
        Notify("Your active civilian profile has been deleted externally.")
    end
end)

RegisterCommand(Config.commands.setciv, function(source, args, rawCommand)
    local ssn = args[1]
    if ssn and #ssn > 8 then
        TriggerServerEvent("ImperialCAD:getCivData", ssn)
    else
        Notify("Invalid SSN provided, Please check and try again.")
    end
end, false)

RegisterCommand(Config.commands.getciv, function()
    local name = GetResourceKvpString("civ_name")
    local age = GetResourceKvpString("civ_age")
    local commId = GetResourceKvpString("commId")

    if name and age then
        Notify("Current Civilian: Name - " .. name .. ", Age - " .. age .. ", Community ID - " .. commId)
    else
        Notify("No active civilian profile.")
    end
end, false)

RegisterCommand(Config.commands.clearciv, function()
    DeleteResourceKvp("civ_ssn")
    DeleteResourceKvp("civ_name")
    DeleteResourceKvp("civ_age")
    DeleteResourceKvp("civ_address")
    DeleteResourceKvp("commId")

    Notify("Active civilian profile has been cleared.")
end, false)

RegisterCommand(Config.commands.regveh, function()
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
                Notify("Model Unknown, Proceeding anyways...")
            end

            local primaryColor, _ = GetVehicleColours(vehicle)

            if Config.debug then
            print("Color ID for this request is " .. primaryColor)
            end
            TriggerServerEvent("ImperialCAD:registerVehicleToCAD", ssn, vehicleModelName, plate, colorName, makeName)
            Notify("Registration has been sent to the DMV.")
        else
            Notify("You must set an active civilian before registering a vehicle.")
        end
    else
        Notify("You must be in a vehicle to register it.")
    end
end, false)

RegisterCommand(Config.commands.id, function()
    local ssn = GetStoredSSN()

    if not ssn or ssn == "" or ssn == "nil" then
        Notify("No set civilian found!")
        return
    end

    TriggerServerEvent("fetchDriverLicenseData", ssn, GetPlayerServerId(PlayerId()))
end, false)


RegisterCommand(Config.commands.hideid, function()
    HideDriverLicense()
end, false)


RegisterCommand(Config.commands.giveid, function(source, args)
    local ssn = GetStoredSSN()
    if not ssn or ssn == "nil" then
        Notify('No set civilian found!')
        return
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local nearestPlayer, nearestDistance = nil, 2.0
    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)
            if distance < nearestDistance then
                nearestPlayer = GetPlayerServerId(playerId)
                nearestDistance = distance
            end
        end
    end

    if nearestPlayer then
        TriggerServerEvent("giveDriverLicenseData", ssn, nearestPlayer, GetPlayerServerId(PlayerId()))
    else
        Notify('No players are nearby!')
    end
end, false)


RegisterNetEvent("showDriverLicense")
AddEventHandler("showDriverLicense", function(data, id)
    local playerServerId = id

    SendNUIMessage({
        action = "show",
        fn = data.fn,
        ln = data.ln,
        address = data.address,
        dob = data.dob,
        license_number = data.license_number or "N/A",
        class = data.class,
        sex = data.sex,
        id = playerServerId
    })
    idVisible = true
end)

Citizen.CreateThread(function()
    while true do
        if idVisible then
            Citizen.Wait(0)
            -- ESC key (322) or Backspace key (177)
            if IsControlJustReleased(0, 322) or IsControlJustReleased(0, 177) then
                HideDriverLicense()
            end
        else
            Citizen.Wait(500)
        end
    end
end)

exports('GetStoredSSN', GetStoredSSN)
exports('GetStoredName', GetStoredName)
