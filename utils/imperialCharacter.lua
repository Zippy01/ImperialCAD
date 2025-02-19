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
    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            print("^1[ERROR]^7 HTTP Error Code: " .. errorCode)
            if callback then
                callback(false, "^1[ERROR]^7 request failed with code: " .. errorCode)
            end
            return
        end

        if callback then
            callback(true, resultData)
        end
        
        if Config.debug then
            print("Result Data: " .. resultData) 
        end

    end, 'POST', json.encode(data), headers)
end

function NewCharacter(data, callback)
    local data = {
        commId = GetConvar("imperial_community_id", ""),
        users_discordID = data.users_discordID,
        Fname = data.Fname,
        Mname = data.Mname,
        Lname = data.Lname,
        Birthdate = data.Birthdate,
        gender = data.gender,
        race = data.race,
        hairC = data.hairC,
        eyeC = data.eyeC,
        height = data.height,
        weight = data.weight,
        postal = data.postal,
        address = data.address,
        city = data.city,
        county = data.county,
        phonenum = data.phonenum,
        dlstatus = data.dlstatus,
        citizenid = data.citizenid
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/NewCharacter", data, headers, callback)
    
    if Config.debug then
       print("[ImperialExport] Attemping to create a new civilian CAD character!")
    end
end

function DeleteCharacter(data, callback)
    local data = {
        commId = GetConvar("imperial_community_id", ""),
        users_discordID = data.users_discordID,
        citizenid = data.citizenid
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/DeleteCharacter", data, headers, callback)
    
    if Config.debug then
       print("[ImperialExport] Attemping to delete civilian CAD character!")
    end
end

exports('NewCharacter', NewCharacter)
exports('DeleteCharacter', DeleteCharacter)
