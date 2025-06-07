RegisterNetEvent("ImperialCAD:getCivData")
AddEventHandler("ImperialCAD:getCivData", function(ssn)
    local src = source
    local headers = {
        ["Content-Type"] = "application/json", 
        ["APIKEY"] = GetConvar("imperialAPI", ""), 
    }
    local url = "https://imperialcad.app/api/1.1/wf/getcivdata"
    local data = {
        ssn = ssn,
        commId = GetConvar("imperial_community_id", "") 
    }

    local jsonData = json.encode(data) 

    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local responseData = json.decode(response)
            if responseData and responseData.ssn then
                TriggerClientEvent("ImperialCAD:setActiveCiv", src, responseData) 
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
    if data.status == "deleted" and data.ssn == GetResourceKvpString("civ_ssn") then
        DeleteResourceKvp("civ_ssn")
        DeleteResourceKvp("civ_name")
        DeleteResourceKvp("civ_age")
        DeleteResourceKvp("civ_address")
        TriggerEvent("notify", "Your active civilian profile has been deleted externally.")
    end
end)

RegisterNetEvent("ImperialCAD:registerVehicleToCAD")
AddEventHandler("ImperialCAD:registerVehicleToCAD", function(ssn, vehicleModelName, plate, colorName, makeName, year)
    local src = source
    local commId = GetConvar("imperial_community_id", "")
    local apiKey = GetConvar("imperialAPI", "")

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
                local responseData = json.decode(response)
                if responseData and responseData.success then
                    TriggerClientEvent("notify", src, "Vehicle registered successfully to CAD.")
                end
            else
                TriggerClientEvent("notify", src, "Failed to register vehicle. Status Code: " .. statusCode)
            end
        end, 
        "POST", jsonData, headers)
end)


