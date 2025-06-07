local tabletVisible = false
local tabletProp = nil 

local function closeTablet()
    local ped = GetPlayerPed(-1)
    
    ClearPedTasks(ped)
    
    if tabletProp and DoesEntityExist(tabletProp) then
        DeleteEntity(tabletProp)
        tabletProp = nil
    end

    -- Additional delay to ensure everything clears properly
    Citizen.Wait(100)

    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "HIDE_TABLET"
    })
    tabletVisible = false
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
    cb({success = true, message = "Tablet closed via JavaScript"})
end)

RegisterCommand("tablet", function(source, args, rawCommand)
    local ped = GetPlayerPed(-1)

    if IsEntityPlayingAnim(ped, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3) then
        closeTablet()
    else

        RequestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@base")
        while not HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@base") do
            Citizen.Wait(100)
        end

        tabletProp = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(
            tabletProp, ped, GetPedBoneIndex(ped, 60309),
            0.03, 0.002, -0.02,
            0.0, 0.0, 0.0,
            true, true, false, true, 1, true
        )

        TaskPlayAnim(ped, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 8.0, -8.0, -1, 50, 0, false, false, false)

        Citizen.Wait(200)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "DISPLAY_TABLET"
        })
        tabletVisible = true
    end
end, false)

RegisterKeyMapping('Tablet', 'Open / close your tablet.', 'keyboard', 'PERIOD')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 200) then
            if tabletVisible then
                closeTablet()
            end
        end
    end
end)
