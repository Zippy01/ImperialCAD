if not Config.livemap then return end

local x, y
local lastSend = 0
local SEND_INTERVAL = 10000
local tracking = false

RegisterNetEvent('ImperialCAD:livemap:client:ToggleTracking', function(Atracking)
    tracking = Atracking
end)

TriggerEvent('chat:addSuggestion', '/ToggleTracking', 'Toggle ImperialCAD live tracking')

RegisterCommand("ToggleTracking", function()
    if tracking then
        tracking = false
        if Config.debug then print("Tracking disabled") end
    else 
        tracking = true
         if Config.debug then print("Tracking enabled") end
    end
end, false)

CreateThread(function()
    while true do
        Wait(3500)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local veh = GetVehiclePedIsIn(ped, false)
        local speed = math.floor(GetEntitySpeed(ped) * 2.23694)

        local status = "on_foot"
        if veh ~= 0 then
            local model = GetEntityModel(veh)
            if IsThisModelAHeli(model) or IsThisModelAPlane(model) then
                status = "aircraft"
            elseif IsThisModelABoat(model) then
                status = "boat"
            else
                status = "car"
            end
        end

        local now = GetGameTimer()
        local moved = (x ~= coords.x) or (y ~= coords.y)
        local timeout = (now - lastSend) >= SEND_INTERVAL

        if (moved or timeout) and tracking then
            TriggerServerEvent("ImperialCAD:livemap:send", {
                x = coords.x,
                y = coords.y,
                speed = speed,
                icon = status
            })

            x = coords.x
            y = coords.y
            lastSend = now
        end
    end
end)
