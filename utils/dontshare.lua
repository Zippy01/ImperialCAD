    -- Hook into the vehicle purchase event
    RegisterNetEvent('qb-vehicleshop:server:buyShowroomVehicle')
    AddEventHandler('qb-vehicleshop:server:buyShowroomVehicle', function(vehicle, plate)
        local src = source
        local pData = QBCore.Functions.GetPlayer(src)
        local citizenid = pData.PlayerData.citizenid
        local discordId = getDiscordId(src)
        local plate = plate or "N/A"
    
        print("🚗 Vehicle Purchase Event Triggered: " .. json.encode(vehicle) .. " with plate: " .. plate .. " for citizen ID: " .. citizenid)
    
        Wait(3000)
    
        MySQL.Async.fetchAll("SELECT plate FROM player_vehicles WHERE citizenid = @citizenid ORDER BY id DESC LIMIT 1", {
            ["@citizenid"] = citizenid
        }, function(result)
            if result[1] then
                local registeredPlate = result[1].plate
    
                print("✅ Vehicle Found in Database: " .. json.encode(vehicle) .. " with plate: " .. registeredPlate)
        --[[
        -- Register the vehicle in the CAD
        exports["ImperialCAD"]:RegisterVehicle({
            users_discordID = discordId,
            citizenid = citizenid,
            vehicle = vehicle,
            plate = plate
        }, function(success, resultData)
            if success then 
                print("✅ Vehicle Registered in CAD")
            else 
                print("⚠️ ERROR: Could not register vehicle in CAD.")
            end
        end)
        --]]
            else
                print("⚠️ ERROR: Vehicle not found in database!")
            end
        end)
    end)