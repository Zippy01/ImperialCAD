local tabletVisible = false
local tabletOpening = false
local tabletProp = nil

local animDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"

local function Notify(message)
    local fullMessage = "[IMPERIAL] " .. message
    SetNotificationTextEntry("STRING")
    AddTextComponentString(fullMessage)
    DrawNotification(false, true)
end

local function closeTablet()
    local ped = GetPlayerPed(-1)

    ClearPedTasks(ped)

    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end

    Citizen.Wait(100)

    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "HIDE_TABLET"
    })
    tabletVisible = false
    tabletOpening = false
    return { success = true, message = "Closed successfully" }
end

AddEventHandler('onResourceStop', function(resourceName)

    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    closeTablet()

    Citizen.Wait(100)
    print("Tablet resource stopped, closing and deleting tablet props")

    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end

  end)

RegisterNUICallback('closeTablet', function(data, cb)
    closeTablet()
    cb({ success = true, message = "Tablet closed via JavaScript" })
end)

RegisterCommand(Config.commands.tablet, function(source, args, rawCommand)
    if tabletOpening then
        return
    end

    local ped = GetPlayerPed(-1)
    local currentVehicle = GetVehiclePedIsIn(ped, false)

    if Config.tabletCarRestriction and GetVehicleClass(currentVehicle) ~= 18 then
        Notify("You must be in a Emergency Vehicle to use your Imperial Tablet.")
        return
    end

    if tabletVisible or IsEntityPlayingAnim(ped, animDict, "base", 3) then
        closeTablet()
    else
        tabletOpening = true

        RequestAnimDict(animDict)

        local timeoutAt = GetGameTimer() + 5000
        while not HasAnimDictLoaded(animDict) do
            if GetGameTimer() > timeoutAt then
                tabletOpening = false
                Notify("Tablet animation failed to load. Please try again.")
                return
            end

            Citizen.Wait(100)
        end

        if tabletProp and DoesEntityExist(tabletProp) then
            DeleteEntity(tabletProp)
            tabletProp = nil
        end

        tabletProp = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(
            tabletProp, ped, GetPedBoneIndex(ped, 60309),
            0.03, 0.002, -0.02,
            0.0, 0.0, 0.0,
            true, true, false, true, 1, true
        )

        TaskPlayAnim(ped, animDict, "base", 8.0, -8.0, -1, 50, 0, false, false, false)

        Citizen.Wait(200)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type   = "DISPLAY_TABLET",
            commId = GetConvar("imperial_community_id", "")
        })
        tabletVisible = true
        tabletOpening = false
    end
end, false)

RegisterKeyMapping(Config.commands.tablet, 'Open / close your tablet.', 'keyboard', 'PERIOD')

Citizen.CreateThread(function()
    while true do
        if tabletVisible then
            Citizen.Wait(0)
            if IsControlJustReleased(0, 200) then
                closeTablet()
            end
        else
            Citizen.Wait(500)
        end
    end
end)
