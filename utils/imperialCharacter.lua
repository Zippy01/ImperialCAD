--[[
    Imperial Export for FiveM
DO NOT EDIT THIS FILE UNLESS YOU KNOW WHAT YOUR DOING!
]]--

local function checkConvar(name, description)
    local value = GetConvar(name, "")
    if not value or value == "" then
        error(string.format("Could not find required Convar '%s' for %s.", name, description))
    end
end

checkConvar("imperial_community_id", "ImperialCAD Community ID")
checkConvar("imperialAPI", "Imperial API key")

local function performAPIRequest(url, method, data, headers, callback) 
    method = method:upper()
    
    if method == "GET" then
        data = ""
    else
        data = json.encode(data)
    end

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

    end, method, data, headers) 
end

function NewCharacter(data, callback)
    local requestData = {
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
    performAPIRequest("https://imperialcad.app/api/1.1/wf/NewCharacter", "POST", requestData, headers, callback)
    
    if Config.debug then
       print("[ImperialExport] Attemping to create a new civilian CAD character!")
    end
end

function DeleteCharacter(data, callback)
    local requestData = {
        commId = GetConvar("imperial_community_id", ""),
        users_discordID = data.users_discordID,
        citizenid = data.citizenid
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/DeleteCharacter", "POST", requestData, headers, callback)
    
    if Config.debug then
       print("[ImperialExport] Attemping to delete civilian CAD character!")
    end
end

function GetCharacter(charid, commId, callback)

    if not charid or charid == "" then
        print("❌ Invalid Character ID. It must not be empty.")
        if callback then callback(false, "Invalid Character ID") end
        return
    end

    if not commId or commId == "" then
        print("❌ Invalid Community ID. It must not be empty.")
        if callback then callback(false, "Invalid Community ID") end
        return
    end

    local url = string.format(
        "http://imperialcad.app/api/1.1/wf/GetCharacter?charid=%s&commId=%s",
        charid,
        commId
    )

    performAPIRequest(url, "GET", nil, nil, function(success, response)
        if success then
            local data = json.decode(response)
            if data.status == "success" then
                print("✅ Character retrieved: " .. json.encode(data.response))
                if callback then callback(true, data.response) end
            else
                print("❌ Character not found.")
                if callback then callback(false, "Character not found.") end
            end
        else
            print("❌ API Request Failed: " .. response)
            if callback then callback(false, response) end
        end
    end)
end

function CreateVehicle(data, callback)
    local requestData = {
        commId = GetConvar("imperial_community_id", ""),
        ssn = data.ssn,
        vehicleModel = data.model,
        plate = data.plate,
        year = data.year or "2015",
        make = data.make or "UNKNOWN",
        color = data.color
    }
    local headers = {
        ["Content-Type"] = "application/json",
        ["APIKEY"] = GetConvar("imperialAPI", "")
    }
    performAPIRequest("https://imperialcad.app/api/1.1/wf/registerVehicle", "POST", requestData, headers, callback)
    
    if Config.debug then
       print("[ImperialExport] Attemping to reigster " .. data.plate .. " to CAD!")
    end
end

exports('GetCharacter', GetCharacter)
exports('NewCharacter', NewCharacter)
exports('DeleteCharacter', DeleteCharacter)
exports('CreateVehicle', CreateVehicle)
