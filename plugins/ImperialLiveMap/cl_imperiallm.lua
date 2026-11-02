if not Config.livemap then return end

local lastCoords = nil
local lastSend = 0
local SEND_INTERVAL = Config.locationFrequency * 1000
local MIN_MOVE_DISTANCE = 10.0
local tracking = false

local function SetTracking(enabled)
    tracking = enabled == true
    lastCoords = nil
    lastSend = 0

    if Config.debug then
        print(tracking and "Tracking enabled" or "Tracking disabled")
    end
end

RegisterNetEvent('ImperialCAD:livemap:client:ToggleTracking', function(Atracking)
    SetTracking(Atracking)
end)

TriggerEvent('chat:addSuggestion', '/ToggleTracking', 'Toggle ImperialCAD live tracking')

RegisterCommand("ToggleTracking", function()
    SetTracking(not tracking)
end, false)

CreateThread(function()
    while true do
        Wait(3500)

        if tracking then
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
            local moved = not lastCoords or #(coords - lastCoords) >= MIN_MOVE_DISTANCE
            local timeout = (now - lastSend) >= SEND_INTERVAL

            if moved or timeout then
                TriggerServerEvent("ImperialCAD:livemap:send", {
                    x = coords.x,
                    y = coords.y,
                    speed = speed,
                    icon = status
                })

                lastCoords = coords
                lastSend = now
            end
        end
    end
end)