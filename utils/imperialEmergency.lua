--[[
    Imperial Export for FiveM
DO NOT EDIT THIS FILE UNLESS YOU KNOW WHAT YOUR DOING!
]]--

local function checkConvar(name, description)
    local value = GetConvar(name, "")
    if not value or value == "" then
        error(string.format("Could not find required Convar '%s' for %s.", name, description))
    end
    print(string.format("%s '%s' found.", description, name))
end

checkConvar("imperial_community_id", "ImperialCAD Community ID")
checkConvar("imperialAPI", "Imperial API key")

local function performAPIRequest(url, data, headers, callback)
    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders, errorData)
        if errorCode ~= 200 then

            if Config.debug then
            print("^1[IMPERIAL_API_ERROR]^7 Response: " .. errorData)
            end

            if callback then
                if errorData then
                callback(false, errorData:match("{.*}"))
                else
                callback(false, "^1[IMPERIAL_API_CALLBACK]^7 request failed: No response data")
                end
            end

            return

        end

        if callback then
            if resultData then
            callback(true, resultData)
            else
            callback(true, "^1[IMPERIAL_API_CALLBACK]^7 request succeeded, But No response data was returned")
            end
        end
        
        if Config.debug then
            print("^1[IMPERIAL_API_DEBUG]^7 Result Data: " .. resultData) 
        end

    end, 'POST', json.encode(data), headers)
end

function Create911Call(data, callback)
    local data = {
        commId = GetConvar("imperial_community_id", ""),
        name = data.name,
        street = data.street,
        cross_street = data.crossStreet,
        info = data.info,
        postal = data.postal,
        city = data.city,
        county = data.county
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/911", data, headers, callback)
    
    if Config.debug then
       print("[Imperial_Export_Create911Call] Attemping to create a 911 call!")
    end

end

function DeleteCall(data, callback)
    local data = {
        callId = data.callId,
        discordid = data.discordId,
        communityId = GetConvar("imperial_community_id", "")
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/Calldelete", data, headers, callback)

    if Config.debug then
    print("[Imperial_Export_DeleteCall] Attemping to delete a 911 call!")
    end

end

function CreateCall(data, callback)
    local data = {
        commId = GetConvar("imperial_community_id", ""),
        users_discordID = data.users_discordID,
        street = data.street,
        cross_street = data.crossStreet,
        postal = data.postal,
        city = data.city,
        county = data.county,
        info = data.info,
        nature = data.nature,
        status = data.status,
        priority = data.priority
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/CallCreate", data, headers, callback)

    if Config.debug then
      print("[Imperial_Export_CreateCall] Attemping to create a new call!")
    end

end

function AttachCall(data, callback)
    local data = {
        commId = GetConvar("imperial_community_id", ""),
        users_discordID = data.users_discordID,
        callnum = data.callnum
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/AttachCall", data, headers, callback)

     if Config.debug then
    print("[Imperial_Export_AttachCall] Attemping to attach player "..source.." to call "..data.callnum)
     end

end

function NewCallNote(data, callback)
    local data = {
        commId = GetConvar("imperial_community_id", ""),
        users_discordID = data.users_discordID,
        description = data.description
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/callnote", data, headers, callback)

    if Config.debug then
      print("[Imperial_Export_NewCallNote] Attemping to create a new call note!")
    end

end

function Booter(data, callback)
    local data = {
        commId = GetConvar("imperial_community_id", ""),
        users_discordID = data.users_discordID,
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    if Config.debug then
    print("Discord ID:" .. data.users_discordID .. "Community ID:" .. data.commId)
    end

    performAPIRequest("https://imperialcad.app/api/1.1/wf/offduty", data, headers, callback)

    if Config.debug then
      print("[Imperial_Export_Booter] Attemping to boot a user from the cad!")
    end

end

function Panic(data, callback)
    local data = {
        commId = GetConvar("imperial_community_id", ""),
        users_discordID = data.users_discordID,
        postal = data.postal,
        street = data.street
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/panic", data, headers, callback)

    if Config.debug then
     print("[Imperial_Export_Panic] Attemping to trigger a user panic in cad!")
    end

end

function ClearPanic(callback)
    local data = {
        commId = GetConvar("imperial_community_id", "")
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/clearpanic", data, headers, callback)

    if Config.debug then
     print("[Imperial_Export_ClearPanic] Attemping to to clear a community panic")
    end

end

function CheckPlate(data, callback)
    local data = {
        communityId = GetConvar("imperial_community_id", ""),
        plate = data.plate
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/checkplate", data, headers, callback)

    if Config.debug then
    print("[Imperial_Export_CheckPlate] Attempting to check the plate " .. data.plate)
    end

end

exports('Create911Call', Create911Call)
exports('DeleteCall', DeleteCall)
exports('CreateCall', CreateCall)
exports('AttachCall', AttachCall)
exports('NewCallNote', NewCallNote)
exports('Booter', Booter)
exports('CheckPlate', CheckPlate)
exports('Panic', Panic)
exports('ClearPanic', ClearPanic)