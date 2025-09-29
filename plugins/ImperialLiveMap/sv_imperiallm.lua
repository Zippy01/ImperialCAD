TriggerEvent('chat:addSuggestion', '/ToggleTracking', 'Toggle ImperialCAD live tracking')

RegisterCommand("ToggleUsersTracking", function(args)

end, false)


RegisterServerEvent("ImperialCAD:livemap:send")
AddEventHandler("ImperialCAD:livemap:send", function(data)
    local src = source
    local discord = getDiscordId(src)
    local communityId = GetConvar("imperial_community_id", "")

    if not discord then return end
    if not IsUnitOnDuty(src) then print("[Imperial LiveMap] Not Sending data, unit is off duty") TriggerClientEvent('ImperialCAD:livemap:client:ToggleTracking', src, false) return end
    if Config.debug then print("[Imperial LiveMap] Sending livemap data") end

    PerformHttpRequest('https://map.imperial-solutions.net/livemap', function(err, text, headers) end, "POST", json.encode({
        verison = 2,
        cid = communityId,
        discord = discord,
        x = data.x,
        y = data.y,
        speed = data.speed,
        icon = data.icon
    }), { ["Content-Type"] = "application/json" })
end)