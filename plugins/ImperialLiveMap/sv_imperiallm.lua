if not Config.livemap then return end

TriggerEvent('chat:addSuggestion', '/ToggleTracking', 'Toggle ImperialCAD live tracking')

RegisterCommand("ToggleUsersTracking", function(args)

end, false)


RegisterServerEvent("ImperialCAD:livemap:send")
AddEventHandler("ImperialCAD:livemap:send", function(data)
    local src = source
    local discord = getDiscordId(src)
    local communityId = GetConvar("imperial_community_id", "")

    if not discord then return end
    if type(IsUnitOnDuty) == "function" and not IsUnitOnDuty(src) then
        if Config.debug then print("[Imperial LiveMap] Not sending data; unit is off duty.") end
        TriggerClientEvent('ImperialCAD:livemap:client:ToggleTracking', src, false)
        return
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local coords = GetEntityCoords(ped)
    local speed = data and tonumber(data.speed) or 0
    local icon = data and data.icon or "on_foot"

    if icon ~= "on_foot" and icon ~= "car" and icon ~= "aircraft" and icon ~= "boat" then
        icon = "on_foot"
    end

    PerformHttpRequest('https://map.imperial-solutions.net/livemap', function(err, text, headers) end, "POST", json.encode({
        version = 2,
        cid = communityId,
        discord = discord,
        x = coords.x,
        y = coords.y,
        speed = speed,
        icon = icon
    }), { ["Content-Type"] = "application/json" })
end)
