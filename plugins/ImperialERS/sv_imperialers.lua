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
            print("DEBUG LINE:", status or rData)
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
             print("DEBUG LINE:", status or rData)
            if Config.debug then print("[Imperial ERS] Received data from CAD which isnt expected for a vehicle, Not registering the same vehicle for ped") end
            cb(true)
        else
            if Config.debug then print("[Imperial ERS] Did not receive data from CAD for vehicle, Will attempt to register vehicle") end
            cb(false)
        end

    end)

end

RegisterNetEvent('ImperialCAD:ERSPED:SERVER')
AddEventHandler('ImperialCAD:ERSPED:SERVER', function(data)
    if Config.debug then print("Received ERS ped info", json.encode(data)) end
    local name = data.FirstName .. " " .. data.LastName

    GetCivilianData(data.FirstName, data.LastName, function(pedRegistered)

if not pedRegistered then 

    local pdata = data
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
            CDLNumber = GenerateRandomString(9), -- ERS doesn't provide, but we will make a function
            CDLStatus = string.upper(pdata.License_Truck),
            hasDL = pdata.License_Car_Is_Valid,
            DLNumber = GenerateRandomString(9),
            DLStatus = string.upper(pdata.License_Car),
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
            print("Ped created in cad:", json.encode(resultData))
        end

    else

        if Config.debug then
            print("Ped couldnt be created in cad:", json.encode(resultData))
        end

    end

    end)
else
    if Config.debug then print("Here is the else statement meaning that this character should not be reg") end
end

end) -- checking/handling trying to create saved char in cad



end) -- Checking ped registry


RegisterNetEvent('ImperialCAD:ERSVEHICLE:SERVER')
AddEventHandler('ImperialCAD:ERSVEHICLE:SERVER', function(data)
    if Config.debug then print("Received ERS vehicle info", json.encode(data)) end

    local fullName = data.owner_name

-- Use pattern matching to split into first and last?? idk trying it tho
    local firstName, lastName = fullName:match("^(%S+)%s+(.*)$")

    print("First name:", firstName)
    print("Last name:", lastName)


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
            
                if Config.debug then print("[DEBUG] Registered advanced vehicle") end

            else

                if Config.debug and resultData then print("[DEBUG] Could not register advanced vehicle:", json.encode(resultData)) end

                if Config.debug and not resultData then print("[DEBUG] Could not register advanced vehicle: NO RESULT DATA AVAIL") end
            end

        end) -- end function of creating advanced vehicle in cad

    else

        if Config.debug then print("Cannot and will not register this ped vehicle") end
        
    end

  end)

end)

RegisterNetEvent('ImperialCAD:ERS:CREATECALLOUT')
AddEventHandler('ImperialCAD:ERS:CREATECALLOUT', function(callData)

    exports["ImperialCAD"]:CreateCall({
        users_discordID = getDiscordId(source),
        street = callData.street,
        cross_street = callData.crossStreet,
        postal = callData.postal,
        city = callData.city,
        county = callData.county,
        info = callData.info,
        nature = callData.nature,
        status = callData.status,
        priority = callData.priority
    }, function(success, resultData)
        if success then
            local apires = json.decode(resultData)
            if not apires or not apires.response or not apires.response.callId then
                if Config.debug then print("^1[ERROR]^7 Invalid response or call ID not found") end
                return
            end
            local callnum = apires.response.callnum
            if Config.debug then print("Night ERS Cad Call Created: Call ID -", callnum) end
        else
            if Config.debug then print(resultData) end
        end
    end)
end)
