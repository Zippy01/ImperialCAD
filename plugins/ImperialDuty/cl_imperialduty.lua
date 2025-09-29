local onduty = false
local leoweapons = Config.LEOWeapons
local fireweapons = Config.FIREWeapons

local weapons = {}

local disabled = Config.DisableDutyCommand

if disabled then return end

TriggerEvent('chat:addSuggestion', '/duty', 'Toggle your duty status for better ImperialCAD notifications', {
    { name="JOB", help="Specify the job you want to go on-duty as or blank for off duty" },
})

RegisterCommand("duty", function(source, args)
    local received = args[1] or nil
    local job = received and string.upper(received) or nil
    
    if onduty then

        onduty = false
        TriggerServerEvent("Imperial:RemoveUnitOnDuty", job)
        ShowNotification("You are now ~r~off-duty~w~.", job)
        TriggerEvent("Imperial:Client:UnSuitUnit")

    else
        print(received, job)
        if received == nil or (job ~= "LEO" and job ~= "FIRE") then
            ShowNotification("You need to specify a valid job. (LEO or FIRE)", "Imperial Duty")
            return
        end

        onduty = true
        TriggerServerEvent("Imperial:AddUnitOnDuty", job)
        TriggerEvent('Imperial:Client:SuitNewUnit', job)
        ShowNotification("You are now ~g~on-duty~w~.", job)
    end
end, false)

RegisterNetEvent("Imperial:Client:SuitNewUnit")
AddEventHandler("Imperial:Client:SuitNewUnit", function(job)
        SetPedArmour(PlayerPedId(), 100)
        TriggerEvent('ImperialCAD:livemap:client:ToggleTracking', true)

        if job == "LEO" and Config.GiveLEOWeapons then
            weapons = leoweapons
        elseif job == "FIRE" and Config.GiveFIREWeapons then
            weapons = fireweapons
        else
            weapons = {}
        end

        for _, weapon in ipairs(weapons) do
            GiveWeaponToPed(PlayerPedId(), GetHashKey(weapon), 250, false, true)
            SetPedAmmo(PlayerPedId(), GetHashKey(weapon), 250)
        end
end)

RegisterNetEvent("Imperial:Client:UnSuitUnit")
AddEventHandler("Imperial:Client:UnSuitUnit", function()
        for _, weapon in ipairs(weapons) do
            RemoveWeaponFromPed(PlayerPedId(), GetHashKey(weapon))
        end
        weapons = {} or nil
            TriggerEvent('ImperialCAD:livemap:client:ToggleTracking', false)
end)

function ShowNotification(message, job)  
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostMessagetext("CHAR_CHAT_CALL", "CHAR_CHAT_CALL", true, 1, "ImperialCAD", job)
end