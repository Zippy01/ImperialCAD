local function decodeJsonResponse(raw, context)
    if not raw or raw == "" then
        print("[ImperialCAD] Empty response while decoding " .. context .. ".")
        return nil
    end

    local ok, decoded = pcall(json.decode, raw)
    if not ok or type(decoded) ~= "table" then
        print("[ImperialCAD] Invalid JSON response while decoding " .. context .. ".")
        return nil
    end

    return decoded
end

RegisterNetEvent("ImperialCAD:getCivData")
AddEventHandler("ImperialCAD:getCivData", function(ssn)
    local src = source
    local headers = {
        ["Content-Type"] = "application/json", 
        ["APIKEY"] = ImperialAPI, 
    }
    local url = "https://imperialcad.app/api/1.1/wf/getcivdata"
    local data = {
        ssn = ssn,
        commId = GetConvar("imperial_community_id", "") 
    }

    local jsonData = json.encode(data) 

    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local responseData = decodeJsonResponse(response, "civilian data")
            if responseData and responseData.ssn then
                TriggerClientEvent("ImperialCAD:setActiveCiv", src, responseData)
                SetActiveCiv({users_discordID = getDiscordId(src), ssn = ssn}, false)
                
            else
                print("No SSN found in the data. Response: " .. response)
                TriggerClientEvent("notify", src, "No civilian found with this SSN.")
            end
        else
            print("Failed to retrieve data with status code: " .. statusCode)
            TriggerClientEvent("notify", src, "Failed to retrieve data. Check logs.")
        end
    end, "POST", jsonData, headers)
end)

RegisterNetEvent("ImperialCAD:updateCivilianStatus")
AddEventHandler("ImperialCAD:updateCivilianStatus", function(data)
    if data and data.status == "deleted" and data.ssn then
        TriggerClientEvent("ImperialCAD:clientCivilianStatusUpdated", -1, data)
    end
end)

RegisterNetEvent("ImperialCAD:registerVehicleToCAD")
AddEventHandler("ImperialCAD:registerVehicleToCAD", function(ssn, vehicleModelName, plate, colorName, makeName, year)
    local src = source
    local commId = GetConvar("imperial_community_id", "")
    local apiKey = ImperialAPI

    if not commId or commId == "" then
        TriggerClientEvent("notify", src, "Community ID is not set. Cannot proceed with registration.")
        return
    end

    if not apiKey or apiKey == "" then
        TriggerClientEvent("notify", src, "API Key is not set. Cannot proceed with registration.")
        return
    end

    local data = {
        ssn = ssn,
        vehicleModel = vehicleModelName or "UNKNOWN",
        plate = plate or "UNKNOWN",
        commId = commId,
        year = year or "UNKNOWN",
        make = makeName or "UNKNOWN",
        color = colorName or "UNKNOWN"
    }

    local jsonData = json.encode(data)

    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = apiKey
    }

    PerformHttpRequest("https://imperialcad.app/api/1.1/wf/registerVehicle", 
        function(statusCode, response, headers)
            if statusCode == 200 then
                local responseData = decodeJsonResponse(response, "vehicle registration")
                if responseData and responseData.success then
                    TriggerClientEvent("notify", src, "Vehicle registered successfully to CAD.")
                end
            else
                TriggerClientEvent("notify", src, "Failed to register vehicle. Status Code: " .. statusCode)
            end
        end, 
        "POST", jsonData, headers)
end)

RegisterNetEvent("fetchDriverLicenseData")
AddEventHandler("fetchDriverLicenseData", function(ssn, playerId)
    local src = source

    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = ImperialAPI,
    }

    local url = "https://imperialcad.app/api/1.1/wf/getLicenseData"

    local data = {
        ssn = ssn,
        commId = GetConvar("imperial_community_id", "")
    }

    local jsonData = json.encode(data)

    PerformHttpRequest(url, function(statusCode, response)
        if statusCode == 200 then
            local responseData = decodeJsonResponse(response, "driver license data")
            if responseData and responseData.fn and responseData.ln then
                TriggerClientEvent("showDriverLicense", src, responseData, playerId)
                TriggerClientEvent("notify", src, "Driver License data retrieved successfully.")
            else
                print("Invalid response data: " .. response)
                TriggerClientEvent("notify", src, "No driver license data found for the provided SSN.")
            end
        else
            print("Failed to retrieve driver license data. Status Code: " .. statusCode)
            TriggerClientEvent("notify", src, "Failed to retrieve driver license data. Status Code: " .. statusCode)
        end
    end, "POST", jsonData, headers)
end)

RegisterNetEvent("giveDriverLicenseData")
AddEventHandler("giveDriverLicenseData", function(ssn, nearestPlayer, sourcePlayerId)
    local src = source
    nearestPlayer = tonumber(nearestPlayer)

    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = ImperialAPI,
    }

    local commId = GetConvar("imperial_community_id", "")

    if not commId or commId == "" then
        TriggerClientEvent("notify", src, "Community ID is not set. Cannot proceed.")
        return
    end

    if not headers["APIKEY"] or headers["APIKEY"] == "" then
        TriggerClientEvent("notify", src, "API Key is not set. Cannot proceed.")
        return
    end

    if not ssn or ssn == "" then
        TriggerClientEvent("notify", src, "Invalid or missing SSN. Please provide a valid SSN.")
        return
    end

    if not nearestPlayer or nearestPlayer == 0 then
        TriggerClientEvent("notify", src, "No player nearby to give ID, Are they close enough?")
        return
    end

    if not GetPlayerName(nearestPlayer) then
        TriggerClientEvent("notify", src, "No player nearby to give ID, Are they close enough?")
        return
    end

    local srcPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(nearestPlayer)
    if srcPed and srcPed ~= 0 and targetPed and targetPed ~= 0 then
        local srcCoords = GetEntityCoords(srcPed)
        local targetCoords = GetEntityCoords(targetPed)
        if #(srcCoords - targetCoords) > 3.0 then
            TriggerClientEvent("notify", src, "No player nearby to give ID, Are they close enough?")
            return
        end
    end

    local url = "https://imperialcad.app/api/1.1/wf/getLicenseData"

    local data = {
        ssn = ssn,
        commId = commId
    }

    local jsonData = json.encode(data)

    PerformHttpRequest(url, function(statusCode, response)
        if statusCode == 200 then
            local responseData = decodeJsonResponse(response, "shared driver license data")
            if responseData and responseData.fn and responseData.ln then
                TriggerClientEvent("showDriverLicense", src, responseData, src)
                TriggerClientEvent("showDriverLicense", nearestPlayer, responseData, src)
                TriggerClientEvent("notify", src, "Driver License data sent successfully.")
                TriggerClientEvent("notify", nearestPlayer, "Driver License data received.")
            else
                print("Invalid response data: " .. response)
                TriggerClientEvent("notify", src, "No driver license data found for the provided SSN.")
            end
        else
            print("Failed to retrieve driver license data. Status Code: " .. statusCode)
            TriggerClientEvent("notify", src, "Failed to retrieve driver license data. Status Code: " .. statusCode)
        end
    end, "POST", jsonData, headers)
end)

