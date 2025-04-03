--[[
    DONT TOUCH THIS FILE UNLESS YOU KNOW WHAT YOUR DOING!
--]]

if Config.isQB then

local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-vehicleshop:client:buyShowroomVehicle')
AddEventHandler('qb-vehicleshop:client:buyShowroomVehicle', function(vehicleModel, plate, source)

    Citizen.Wait(2000)

    local src = source

    local ped = PlayerPedId()
    if IsPedSittingInAnyVehicle(ped) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleHash = GetEntityModel(vehicle)
        local vehicleModelName = GetDisplayNameFromVehicleModel(vehicleHash)  -- Ensure this matches showroom model if needed
        local colorName = GetVehicleColorName(vehicle)
        local makeName = GetVehicleMakeName(vehicleModelName)

        if vehicleModelName == "CARNOTFOUND" or vehicleModelName == nil then
            vehicleModelName = "UNKNOWN"
            TriggerEvent("notify", "Model Unknown, Proceeding anyways...")
        end

        local data = {
            ssn = GetResourceKvpString("civ_ssn"),
            make = makeName or "UNKNOWN",
            color = colorName or "UNKNOWN",
            vehicle = vehicleModelName,
            plate = plate
        }

        if Config.debug then
            print("? Vehicle purchase detected: " .. vehicleModelName .. " | Plate: " .. plate .. " | Sending to the best cad in the world...")
            print(plate .. " " .. data.ssn)
        end

        if data.ssn then
            TriggerServerEvent('ImperialCAD:CreateVehicle', data, src)
            TriggerEvent("notify", "Vehicle has been sent to the DMV.")
            if Config.debug then
            TriggerEvent("notify", vehicleModelName .. " has been sent to the DMV, " .. (colorName or "UNKNOWN") .. " is color and " .. (makeName or "UNKNOWN") .. " is make.")
            end
        else
            TriggerEvent("notify", "Couldn't register in DMV, No active civilian profile.")
        end
    else
        TriggerEvent("notify", "Unable to register this vehicle, Try '/regveh' instead")
    end    

end)

end --end of qb

if Config.isQBX then

    if Config.debug then print("Client FW script for qbx loaded") end

    -- Very hacky lazy workaround - I need to improve this
    RegisterNetEvent('qbx_vehicleshop:imperial:client:boughtshowroomvehicle')
    AddEventHandler('qbx_vehicleshop:imperial:client:boughtshowroomvehicle', function()
        
        if Config.debug then print("Client received showroom vehicle purchase event!") end
        Citizen.Wait(3000)
        TriggerEvent("notify", "Please do not leave your vehicle, Registering to ImperialCAD")

        local src = source
    
        local ped = PlayerPedId()
        if IsPedSittingInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local vehicleHash = GetEntityModel(vehicle)
            local vehicleModelName = GetDisplayNameFromVehicleModel(vehicleHash)  -- Ensure this matches showroom model if needed
            local colorName = GetVehicleColorName(vehicle) -- This global in in ImperialCAD, this could conflict with another resources global if misused
            local makeName = GetVehicleMakeName(vehicleModelName) -- This global in in ImperialCAD, this could conflict with another resources global if misused
            local plate = GetVehicleNumberPlateText(vehicle)
    
            if vehicleModelName == "CARNOTFOUND" or vehicleModelName == nil then
                vehicleModelName = "UNKNOWN"
                TriggerEvent("notify", "Model Unknown, Proceeding anyways...")
            end
    
            local data = {
                ssn = GetResourceKvpString("civ_ssn"),
                make = makeName or "UNKNOWN",
                color = colorName or "UNKNOWN",
                vehicle = vehicleModelName,
                plate = plate
            }
    
            if Config.debug then
                print("? Vehicle purchase detected: " .. vehicleModelName .. " | Plate: " .. plate .. " | Sending to the best cad in the world...")
                print(plate .. " " .. data.ssn)
            end
    
            if data.ssn then
                TriggerServerEvent('ImperialCAD:QBXFramework:CreateVehicle', data, src)
                TriggerEvent("notify", "Vehicle has been sent to the DMV.")
                if Config.debug then
                TriggerEvent("notify", vehicleModelName .. " has been sent to the DMV, " .. (colorName or "UNKNOWN") .. " is color and " .. (makeName or "UNKNOWN") .. " is make.")
                end
            else
                TriggerEvent("notify", "Couldn't register in DMV, No active civilian profile.")
            end
        else
            TriggerEvent("notify", "Unable to register this vehicle, Try '/regveh' instead")
        end    
    
    end)
    
    
    
    end --end of qbx
    