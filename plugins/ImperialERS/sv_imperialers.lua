if not Config.ERSsupport then return end

print("Loading ImperialCAD ERS Integration..")

local function GetCivilianData(firstname, lastname, cb)


    GetCharacterAdvanced({
        firstname = firstname,
        lastname = lastname
}, function(success, resultData)
        if success then
            local rData = resultData
            local status = rData.status
            if Config.debug then print("GetCharacter ERS DEBUG LINE:", status or rData) end
            if status == "success" then
                if Config.debug then print("[Imperial ERS] Received civilian data from CAD, Not registering the same civilian for ped") end
                cb(true)
            elseif status == "error" then
                if Config.debug then print("[Imperial ERS] Could not find civilian data in CAD, Registering a new civilian for ped") end
                cb(false)
            end
        else
            if Config.debug then print("[Imperial ERS] Could not preform CAD request, Will not not proceed with civilian ped") end
            cb(true)
        end
    end)

end

local function GetVehicleData(plate, cb)

    CheckPlate({
        plate = plate
}, function(success, resultData)
        if success then
             local rData = resultData
             local status = rData.status
             if Config.debug then print("CheckPlate ERS DEBUG LINE:", status or rData) end
            if Config.debug then print("[Imperial ERS] Vehicle already in cad, not registering again") end
            cb(true)
        else
            if Config.debug then print("[Imperial ERS] Vehicle not found in cad, attempting to register") end
            cb(false)
        end

    end)

end

RegisterNetEvent('ErsIntegration::OnFirstNPCInteraction')
AddEventHandler('ErsIntegration::OnFirstNPCInteraction', function(source, data, context)
    if Config.debug then print("Received ERS ped info", json.encode(data)) end
    local name = data.FirstName .. " " .. data.LastName

    GetCivilianData(data.FirstName, data.LastName, function(pedRegistered)

if not pedRegistered then 
    local pdata = data

    local DLStatus = string.upper(pdata.License_Car)
    local CDLStatus = string.upper(pdata.License_Truck)

    local licenseStatus = DLStatus == "INTERNATIONAL LICENSE (VALID)" and "ACTIVE"
              or DLStatus == "REPORTED STOLEN (VALID)" and "REVOKED" or DLStatus == "VALID" and "ACTIVE"
              or "NONE"

    local CLicenseStatus = CDLStatus == "INTERNATIONAL LICENSE (VALID)" and "ACTIVE"
              or CDLStatus == "REPORTED STOLEN (VALID)" and "REVOKED" or CDLStatus == "VALID" and "ACTIVE"
              or "NONE"

    NewCharacterAdvanced({
        commId = GetConvar("imperial_community_id", ""),
        Fname = pdata.FirstName,
        Mname = "", -- ERS doesn't provide middle name
        Lname = pdata.LastName,
        Birthdate = pdata.DOB,
        gender = pdata.Gender,
        race = string.upper(pdata.Nationality) or "nil",
        hairC = "nil", -- not provided
        eyeC = "nil", -- not provided
        height = "nil", -- not provided
        weight = "nil", -- not provided
        postal = pdata.PostalCode,
        address = pdata.Address,
        city = pdata.City,
        county = "nil",
        state = pdata.State,
        phonenum = pdata.PhoneNumber,
        licensedetails = {
            hasBoatLic = pdata.License_Boat_Is_Valid,
            hasCDL = pdata.License_Truck_Is_Valid,
            CDLNumber = GenerateRandomString(9), -- ERS doesn't provide, but we made a function
            CDLStatus = CLicenseStatus,
            hasDL = pdata.License_Car_Is_Valid,
            DLNumber = GenerateRandomString(9),
            DLStatus = licenseStatus,
            hasFirearmsCertification = false, -- not in ERS
            hasFishLic = false,
            hasHuntLic = false
        },
        misc = {
            missing = false
        }
    }
    , function(success, resultData)
    if success then

        if Config.debug then
            print("[IMPERIAL_ERS] Ped created in cad:", json.encode(resultData))
        end

    else

        if Config.debug then
            print("[IMPERIAL_ERS] Ped couldnt be created in cad:", json.encode(resultData))
        end

    end

    end)
else
    if Config.debug then print("[IMPERIAL_ERS] Here is the else statement meaning that this character should not be reg") end
end

end) -- checking/handling trying to create saved char in cad



end) -- Checking ped registry


RegisterNetEvent('ErsIntegration::OnFirstVehicleInteraction')
AddEventHandler('ErsIntegration::OnFirstVehicleInteraction', function(source, data, context)
    if Config.debug then print("[IMPERIAL_ERS] Received ERS vehicle info", json.encode(data)) end

    local fullName = data.owner_name

-- Use pattern matching to split into first and last?? idk trying it tho
    local firstName, lastName = fullName:match("^(%S+)%s+(.*)$")

    if Config.debug then
    print("[IMPERIAL_ERS] First name:", firstName)
    print("[IMPERIAL_ERS] Last name:", lastName)
    end

    local vehicle = data
    local insuranceStatus = vehicle.insurance and "ACTIVE" or "EXPIRED"
    local regStatus = vehicle.tax and "ACTIVE" or "EXPIRED"
    
GetVehicleData(vehicle.license_plate, function(isReg)

    if not isReg then

        CreateVehicleAdvanced({
                vehicleData = {
                    plate = vehicle.license_plate,
                    model = vehicle.model,
                    Make = vehicle.make,
                    color = vehicle.color,
                    year = tostring(vehicle.build_year),
                    regStatus = regStatus,
                    regExpDate = vehicle.registration_date,
                    vin = GenerateRandomString(17),
                    stolen = vehicle.stolen
                },
                vehicleInsurance = {
                    hasInsurance = vehicle.insurance,
                    insuranceStatus = insuranceStatus,
                    insurancePolicyNum = GenerateRandomString(12)
                },
                vehicleOwner = {
                    ownerSSN = "nil",
                    ownerFirstName = firstName,
                    ownerLastName = lastName,
                    ownerGender = "nil",
                    ownerAddress = "nil",
                    ownerCity = "nil"
                }
        }, function(success, resultData)
            
            if success then
            
                if Config.debug then print("[IMPERIAL_ERS] Registered advanced vehicle") end

            else

                if Config.debug and resultData then print("[IMPERIAL_ERS] Could not register advanced vehicle:", json.encode(resultData)) end

                if Config.debug and not resultData then print("[IMPERIAL_ERS] Could not register advanced vehicle: NO RESULT DATA AVAIL") end
            end

        end) -- end function of creating advanced vehicle in cad

    else

        if Config.debug then print("[IMPERIAL_ERS] Cannot and will not register this ped vehicle") end
        
    end

  end)

end)

RegisterNetEvent('ErsIntegration::OnAcceptedCalloutOffer')
AddEventHandler('ErsIntegration::OnAcceptedCalloutOffer', function(callData)
    if Config.debug then print("Received accepeted calloutoffer from ERS") end
local ers = callData
local src = source

local streetData = lib.callback.await('ImperialCAD:getNearestStreets', source, ers.Coordinates)

local street = streetData.street
local crossStreet = streetData.crossStreet or nil

    exports["ImperialCAD"]:CreateCall({
        users_discordID = getDiscordId(source),
        street = street,
        cross_street = crossStreet,
        postal = exports["ImperialCAD"]:getNearestPostalFromCoords(ers.Coordinates),
        city = exports["ImperialCAD"]:getNearestCityFromCoords(ers.Coordinates),
        county = exports["ImperialCAD"]:getNearestCountyFromCoords(ers.Coordinates),
        info = ers.Description,
        nature = ers.CalloutName,
        status = "ACTIVE",
        priority = "2"
    }, function(success, resultData)
        if success then
            local apires = json.decode(resultData)
            if not apires or not apires.response or not apires.response.callId then
                if Config.debug then print("^1[IMPERIAL_ERS_ERROR]^7 Invalid response or call ID not found") end
                return
            end
            local callnum = apires.response.callnum
            local callId = apires.response.callId
            if Config.debug then print("[IMPERIAL_ERS] Cad Call Created: Call num -", callnum) end
            addCall(src, callId)
        else
            if Config.debug then print(resultData) end
        end
    end)
end)

RegisterNetEvent('ErsIntegration::OnArrivedAtCallout')
AddEventHandler('ErsIntegration::OnArrivedAtCallout', function(callData)
    if Config.debug then print("Received arrived at callout from ERS") end
end)
if Config.UseERSCalloutEnded then
RegisterNetEvent('ErsIntegration::OnEndedACallout')
AddEventHandler('ErsIntegration::OnEndedACallout', function()
    if Config.debug then print("Received ended a callout from ERS") end
    local call = getCall(source)

    if call then
        if Config.debug then print('There is a ers call number saved, trying to delete it then') end
        exports["ImperialCAD"]:DeleteCall({
        callId = call,
        discordid = getDiscordId(source),
        }, function(success, resultData)
            if success then
             if Config.debug then print("^1[IMPERIAL_ERS]^7 Call deleted, call ended by ERS") end
            else
             if Config.debug then print("^1[IMPERIAL_ERS_error]^7 Unable to delete, call ended by ERS") end
            end
        end)
        removeCall(source)
    else
        if Config.debug then print('There is not a ers call number locally saved, not trying to delete it') end
    end
end)

RegisterServerEvent("ErsIntegration::OnCalloutCompletedSuccesfully")
AddEventHandler("ErsIntegration::OnCalloutCompletedSuccesfully", function(calloutData)
    if Config.debug then print("Received ended a callout from ERS") end
    local call = getCall(source)

    if call then
        if Config.debug then print('There is a ers call number saved, trying to delete it then') end
        exports["ImperialCAD"]:DeleteCall({
        callId = call,
        discordid = getDiscordId(source),
        }, function(success, resultData)
            if success then
             if Config.debug then print("^1[IMPERIAL_ERS]^7 Call deleted, call ended by ERS") end
            else
             if Config.debug then print("^1[IMPERIAL_ERS_error]^7 Unable to delete, call ended by ERS") end
            end
        end)
        removeCall(source)
    else
        if Config.debug then print('There is not a ers call number locally saved, not trying to delete it') end
    end
end)

RegisterServerEvent("ErsIntegration::OnPullover")
AddEventHandler("ErsIntegration::OnPullover", function(pedData, vehicleData)
    local src = source

    if Config.debug then print("Received started a pullover from ERS") end

    local ped = GetPlayerPed(src)
    local Coords

    local vehicle = vehicleData

    if ped and ped ~= 0 then
         Coords = GetEntityCoords(ped)
        if Config.debug then print(("Player %s coords: x=%.2f, y=%.2f, z=%.2f"):format(source, Coords.x, Coords.y, Coords.z)) end
    else
        if Config.debug then print("No ped found for player " .. source) end
    end

    local streetData = lib.callback.await('ImperialCAD:getNearestStreets', source, Coords)

    local street = streetData.street
    local crossStreet = streetData.crossStreet or nil

        exports["ImperialCAD"]:CreateCall({
        users_discordID = getDiscordId(source),
        street = street,
        cross_street = crossStreet,
        postal = exports["ImperialCAD"]:getNearestPostalFromCoords(Coords),
        city = exports["ImperialCAD"]:getNearestCityFromCoords(Coords),
        county = exports["ImperialCAD"]:getNearestCountyFromCoords(Coords),
        info = ("Traffic stop on a %s %s %s (%s) with the license plate %s. (Bolo Desc: %s)"):format(vehicle.build_year, vehicle.color, vehicle.make, vehicle.model, vehicle.license_plate, vehicle.bolo_description),
        nature = Config.trafficsnature,
        status = "ACTIVE",
        priority = Config.trafficspriority
    }, function(success, resultData)
        if success then
            local apires = json.decode(resultData)
            if not apires or not apires.response or not apires.response.callId then
                if Config.debug then print("^1[IMPERIAL_ERS_ERROR]^7 Invalid response or call ID not found") end
                return
            end
            local callnum = apires.response.callnum
            local callId = apires.response.callId
            if Config.debug then print("[IMPERIAL_ERS] Cad Call Created: Call num -", callnum) end
            addCall(src, callId)
        else
            if Config.debug then print(resultData) end
        end
    end)

end)

if Config.UseERSPulloverEnded then
RegisterServerEvent("ErsIntegration::OnPulloverEnded")
AddEventHandler("ErsIntegration::OnPulloverEnded", function(pedData, vehicleData)
    local src = source

    if Config.debug then print("Received ended a pullover from ERS") end
    local call = getCall(source)

    if call then
        if Config.debug then print('There is a ers call number saved, trying to delete it then') end
        exports["ImperialCAD"]:DeleteCall({
        callId = call,
        discordid = getDiscordId(source),
        }, function(success, resultData)
            if success then
             if Config.debug then print("^1[IMPERIAL_ERS]^7 Call deleted, call ended by ERS") end
            else
             if Config.debug then print("^1[IMPERIAL_ERS_error]^7 Unable to delete, call ended by ERS") end
            end
        end)
        removeCall(source)
    else
        if Config.debug then print('There is not a ers call number locally saved, not trying to delete it') end
    end
end)
end