--[[
    Imperial Export for FiveM
DO NOT EDIT THIS FILE UNLESS YOU KNOW WHAT YOUR DOING!
]]--

local function getVersionFromManifest()
    local path = GetResourcePath(GetCurrentResourceName()) .. '/fxmanifest.lua'
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()

        for line in string.gmatch(content, "[^\r\n]+") do
            local value = string.match(line, "^version%s+'(.+)'$")
            if value then
                return value
            end
        end
    end
    return 'unknown'
end

local currentVersion = getVersionFromManifest()
local versionUrl = 'https://raw.githubusercontent.com/Zippy01/ImperialCAD/main/version.json'  

function checkForUpdates()
    local currentVersion = getVersionFromManifest()

    PerformHttpRequest(versionUrl, function(err, responseText, headers)
        if err == 200 then  
            local data = json.decode(responseText)
            if data and data.latestVersion and data.latestVersion ~= currentVersion then
                print('[Current Version: ' .. currentVersion .. '] Update available! Please download the latest version: ' .. data.latestVersion)
            else
                print('ImperialCAD V'..currentVersion..' is up to date!')
            end
        else
                print('Failed to check for updates.')
        end
    end, 'GET', '')
end

CreateThread(function()

    if Config.DisableVersionCheck then return end -- If config is set to disable
    checkForUpdates()  -- Check for updates when the script starts

end)

--trys to find the discord ID
local function getDiscordId(src)
    if src == nil then return false end
    local identifiers = GetPlayerIdentifiers(src)
    for _, v in pairs(identifiers) do
        if string.sub(v, 1, 8) == "discord:" then
            return string.gsub(v, "discord:", "")
        end
    end
    return false
end

if Config.cadkickonleave then
AddEventHandler('playerDropped', function(reason, resourceName, clientDropReason)
    local playerName = GetPlayerName(source)
     print('Player' .. playerName .. ' dropped, telling ImperialCAD to cleanup')
    
     local discordId = getDiscordId(source)
     if not discordId then
        print("^3[WARN]^7 Discord ID not found for " .. playerName .. "Cannot attempt cleanup")
     else
        if Config.debug then
        print("Attempting to mark "..playerName.." off duty in cad, using the discord id "..discordId)
        end

     exports["ImperialCAD"]:Booter({
        users_discordID = discordId
     }, function(success, resultData)
        if success then
            local apires = json.decode(resultData)
            if Config.debug then
            print("[ImperialCleanup] Player was successfully marked off duty, and cleaned up in the CAD")
            end
        else
            if Config.debug then
            print("[ImperialCleanup] Unable to mark user off duty, This player might not be logged in")
            end
        end
     end)
    end end)
end

RegisterNetEvent('ImperialCAD:New911')
AddEventHandler('ImperialCAD:New911', function(callData)

    if not callData.name or not callData.street or not callData.crossStreet or not callData.postal or not callData.info then
        print("[Imperial911] Missing required call data to create a new 911 call, Will not create.")
        return  
    end

    local coords = callData.coords

    exports["ImperialCAD"]:Create911Call({
        name = callData.name,
        street = callData.street,
        crossStreet = callData.crossStreet,
        info = callData.info,
        postal = callData.postal,
        city = callData.city,
        county = callData.county
    }, function(success, resultData)
        if success then
            local apires = json.decode(resultData)
            if not apires or not apires.response or not apires.response.callId then
                print("^1[API_ERROR]^7 Invalid response or call ID not found")
                return false
            end

            local callNum = apires.response.callnum
            print("[Imperial911] 911 Call was successfully created")
             
            TriggerEvent('Imperial:911ChatMessage', callData.name, callData.street, callData.info, callData.crossStreet, callData.postal, callNum)
        
            if Config.callBlip then
            TriggerEvent("ImperialCAD:911Blip", coords)
            end

            Notify("Your call was successfully sent to emergency services.", source)

            else 

                print("[Imperial911] 911 Call tried but failed")

            end
    end)
end)

if Config.PlateThroughChat then
RegisterNetEvent('ImperialCAD:CheckPlate')
AddEventHandler('ImperialCAD:CheckPlate', function(callData)
    local src = source

    if Config.debug then
        print("[ImperialRplate] Checking plate: " .. callData.plate.." on the server side")
    end

    if not callData.plate then
        print("[ImperialRplate] Request made without plate, killing early")
        return
    end

    exports["ImperialCAD"]:CheckPlate({
        plate = callData.plate
    }, function(success, resultData)
        if not success or not resultData then
            Notify(""..callData.plate.." Was ran without a successful result, is it registered?", src)
        end

        local data = json.decode(resultData)
        if not data then
            print("[ImperialRplate] Invalid API response, Killing early")
            return
        end

        local response = data.response
        local messages = {}

        if success and resultData then 
            Notify("The following flags/alerts where found for plate: " .. response.plate, src) -- @TODO
        end

        if not success or not resultData then
            table.insert(messages, "Could not find vehicle with the plate: "..callData.plate)
        end

        if success then -- If api returns success then check the actual return

        if response.stolen then
            table.insert(messages, "Stolen Vehicle")
        end

        if not response.insurance then
            table.insert(messages, "No Insurance")
        end

        if response.insurance and response.insurance_status ~= "ACTIVE" then
            table.insert(messages, "Invalid Insurance")
        end

        if response.business then
            table.insert(messages, "Commercial Vehicle")
        end

        if response.reg_status ~= "ACTIVE" then
            table.insert(messages, "Invalid Vehicle registration")
        end

        if response.owner_wanted then
            table.insert(messages, "Owner Wanted")
        end

        if response.owner_dl_status ~= "ACTIVE" then
            table.insert(messages, "Invalid license")
        end

    end -- end of the addtional checks

    if #messages > 0 then
        TriggerClientEvent('ImperialCAD:Client:Notify', source, messages)
    end
    
    end)
end)
end

RegisterNetEvent('ImperialCAD:TrafficStop')
AddEventHandler('ImperialCAD:TrafficStop', function(callData)

    exports["ImperialCAD"]:CreateCall({
        users_discordID = getDiscordId(source),
        street = callData.street,
        cross_street = callData.crossStreet,
        postal = callData.postal,
        city = callData.city,
        county = callData.county,
        info = callData.info,
        nature = Config.trafficsnature,
        status = Config.trafficsstatus,
        priority = Config.trafficspriority
    }, function(success, resultData)
        if success then
            local apires = json.decode(resultData)
            if not apires or not apires.response or not apires.response.callId then
                print("^1[ERROR]^7 Invalid response or call ID not found")
                return
            end
            local callnum = apires.response.callnum
            print("Traffic Stop created successfully: Call ID -", callnum)
        else
            print(resultData)
        end
    end)
end)

RegisterNetEvent('ImperialCAD:AttachCall')
AddEventHandler('ImperialCAD:AttachCall', function(callData)
local player = source
    exports["ImperialCAD"]:AttachCall({
        users_discordID = getDiscordId(source),
        callnum = callData.callnum
    }, function(success, resultData)
        local result = json.decode(resultData)
        local status = result.status
        local message = result.message
        local response = result.response

        if success and status ~= "success" then success = false end

        if status == "NOT_RUN" then
            status = "Invalid call or not verfified"
        end
        
        if not success then
            Notify(string.format("[ImperialCAD] Unable to attach you, reason: %s", status), player)
        elseif success then
            Notify("[ImperialCAD] Attached to call number "..response.callnum, player)
        elseif not success and Config.debug then
            Notify(string.format("[ImperialCAD - Debug] Unable to attach you, Status: %s | Reason: %", status, message), player)
        end
    end)
end)

RegisterNetEvent('ImperialCAD:CloseCall')
AddEventHandler('ImperialCAD:CloseCall', function(callData)

    exports["ImperialCAD"]:DeleteCall({
        discordid = getDiscordId(source),
        callId = callData.callId,
    }, function(success, resultData)
    end)
end)

RegisterNetEvent('ImperialCAD:Panic')
AddEventHandler('ImperialCAD:Panic', function(callData)

    exports["ImperialCAD"]:Panic({
        users_discordID = getDiscordId(source),
        postal = callData.postal,
        street = callData.street
    }, function(success, resultData)
        if success then
            print("Panic was triggered")
        else
            print("Unable to trigger panic")
        end
    end)
end)

RegisterNetEvent('ImperialCAD:ClearPanic')
AddEventHandler('ImperialCAD:ClearPanic', function()

    exports["ImperialCAD"]:ClearPanic(function(success, resultData)
        if success then
            print("Panic was cleared")
        else 
            print("Unable to clear community panic")
        end
    end)
end)

function Notify(message, playerId)
    if playerId and message then
        if Config.debug then print("[ImperialCAD] Trying to notify player: "..playerId) end
        TriggerClientEvent('chat:addMessage', playerId, {
         color = {255, 0, 0},
         multiline = true,
         args = {"ImperialCAD", message}
        })
    elseif not message then
        print("[IMPERIAL_SV_NOTIFY] No message provided")
    elseif not playerId then
        print("[IMPERIAL_SV_NOTIFY] No playerId provided")
    else
        print("[IMPERIAL_SV_NOTIFY] Couldnt send message")
    end
end

RegisterNetEvent("ImperialCAD:Server:NewNotify")
AddEventHandler("ImperialCAD:Server:NewNotify", function(callData)

    local d = callData or {}
    if not d then print("ImperialCAD Could not create a new dispatch, No callData was found. Returning early") return false end
    local street = d.street or "Unknown"
    local crossStreet = d.crossStreet or "N/A"
    local postal = d.postal or "00000"
    local city = d.city or "N/A"
    local county = d.county or "N/A"
    local nature = d.nature or "No Nature Provided"
    local status = d.status or "ACTIVE"
    local priority = d.priority or 2
    if not d.cords or d.cords == "" then
        print("ImperialCAD Could not create a new dispatch, No cords were found. Returning early")
        return false
    end
    local cords = d.cords
    local message = d.message or "No information provided"
    local cmessage = d.cmessage or "No Information provided"
    local job = d.job or "Unknown"

    exports["ImperialCAD"]:CreateCall({
        users_discordID = "",
        street = street,
        cross_street = crossStreet,
        postal = postal,
        city = city,
        county = county,
        info = message,
        nature = nature,
        status = status,
        priority = priority
    }, function(success, resultData)
        if success then
            local apires = json.decode(resultData)
            if not apires or not apires.response or not apires.response.callId then
                print("^1[API_ERROR]^7 Invalid response or call ID not found")
                return false
            end

            local callNum = apires.response.callnum
            print("New Dispatch CAD Call created successfully: Call ID -", callNum)

            local chatMessage = {
                multiline = true,
                args = {
                    "^8(ImperialCAD - New Call For Service)",
                    "^7\nPostal: ^3" .. postal ..
                    "^7\nStreet: ^3" .. street ..
                    "^7\nCross Street: ^3" .. crossStreet ..
                    "^7\nInformation: ^3" .. cmessage ..
                    "^7\nCall Number: ^3" .. callNum
                }
            }

            local successDuty, onDutyUnits = pcall(function()
                if job == "LEO" then
                    return exports["ImperialDuty"]:GetOnDutyLEOUnits()
                elseif job == "FIRE" then
                    return exports["ImperialDuty"]:GetOnDutyFireUnits()
                else
                    return exports["ImperialDuty"]:GetOnDutyUnits()
                end
            end)

            if successDuty and onDutyUnits then
                for _, playerId in ipairs(onDutyUnits) do
                    TriggerClientEvent("chat:addMessage", playerId, chatMessage)
                    TriggerClientEvent("Imperial:911BlipForOnduty", playerId, cords)
                end
                if Config.debug then print("Blips and messages sent to on-duty units.") end
            else
                TriggerClientEvent("chat:addMessage", -1, chatMessage)
                if Config.debug then print("Duty unit fetch failed. Message sent to all.") end
            end

        else
            print("New Imperial Dispatch call failed: "..resultData)
        end
    end)

end)


RegisterNetEvent("Imperial:911ChatMessage")
AddEventHandler("Imperial:911ChatMessage", function(name, street, message, crossStreet, postal, callNum)

    local chatMessage = {
        multiline = true,
        args = {"^8(ImperialCAD - New Call For Service)",
            "\nName: ^3" .. name .. "^7\nPostal: ^3" .. postal .. "^7\nStreet: ^3" .. street .. 
            "^7\nCross Street: ^3" .. crossStreet .. "^7\nInformation: ^3" .. message .. "^7\nCall Number: ^3" .. callNum
        }
    }

    local success, onDutyUnits = pcall(function()
        return exports["ImperialDuty"]:GetOnDutyUnits()
    end)

    if success and onDutyUnits then
        for _, playerId in ipairs(onDutyUnits) do
            TriggerClientEvent("chat:addMessage", playerId, chatMessage)
        end
    else
        TriggerClientEvent("chat:addMessage", -1, chatMessage)
        end
end)

RegisterNetEvent("ImperialCAD:911Blip")
AddEventHandler("ImperialCAD:911Blip", function(coords)

    local success, OnDutyUnitsFound = pcall(function()
        return exports['ImperialDuty']:GetOnDutyUnits()
     end)
     
     if success then
    for _, playerId in ipairs(OnDutyUnitsFound) do

           if Config.debug then
           print("We found ImperialDuty, Proceeding with blips")
           end

        TriggerClientEvent("Imperial:911BlipForOnduty", playerId, coords)
    end
    else

           if Config.debug then
           print("Couldnt find ImperialDuty, proceeding without blip.")
           end

    end

end)