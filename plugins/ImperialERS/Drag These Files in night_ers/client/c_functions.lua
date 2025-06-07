-- Client Functions

QBCore = nil
ESX = nil

Citizen.CreateThread(function()
    if Config.Enable_QBCore_Permissions.Check_By_Job or Config.Enable_QBCore_Permissions.Check_By_Permissions or (Config.GearData.Enable_Gear_Permissions and Config.GearData.Enable_QBCore_Permissions.Check_By_Job or Config.GearData.Enable_QBCore_Permissions.Check_By_Permissions) then
        QBCore = exports["qb-core"]:GetCoreObject()
    end

    if Config.Enable_ESX_Permissions.Check_By_Job or Config.Enable_ESX_Permissions.Check_By_Permissions or (Config.GearData.Enable_Gear_Permissions and Config.GearData.Enable_ESX_Permissions.Check_By_Job or Config.GearData.Enable_ESX_Permissions.Check_By_Permissions) then
        ESX = exports["es_extended"]:getSharedObject()
    end
end)

function OnIsOfferedCallout(calloutdata)
    -- Add your code here. Keep in mind they are offered a callout. It is possible they will not accept the callout.

    -- if Config.Debug then
    --     for k, v in pairs(calloutdata) do
    --         print("key: "..k)
    --         if type(v) == "table" then
    --             print(json.encode(v))
    --         else
    --             if type(v) == "boolean" then
    --                 print(v)
    --             else
    --                 print("value: "..v)
    --             end
    --         end
    --     end
    -- end
end

function OnAcceptedCalloutOffer(calloutdata)
    -- Add your code here. Keep in mind they have accepted a callout. It is possible they will cancel before arrival (and spawn of entities).
    --print("Accepted Callout Data:", json.encode(calloutdata))

    local ers = calloutdata

    local coords = ers.Coordinates
    local streetHash, crossStreetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)

    local callData = {
        street = GetStreetNameFromHashKey(streetHash),
        cross_street = GetStreetNameFromHashKey(crossStreetHash),
        postal = ers.Postal,
        city = exports["ImperialLocation"]:getCity(),
        county = exports["ImperialLocation"]:getCounty(),
        info = ers.Description,
        nature = ers.CalloutName,
        status = "ACTIVE",
        priority = "2"
    }

    TriggerServerEvent("ImperialCAD:ERS:CREATECALLOUT", callData)
end

function OnArrivedAtCallout(calloutdata)
    -- Add your code here. This is triggered right before the entities are built for a callout. This code will execute first.
end

function OnEndedACallout() -- Contains no callout data.
    -- Add your code here. This is triggered right before the entities are deleted or callout is cancelled serverside. This code will execute first.
end

function OnNPCGivesGear(data)
    local clothingData, weaponData, healthData = data.clothingData, data.weaponData, data.healthData

    -- Player ped model
    local isModelAMultiplayerModel = (clothingData.modelName == "mp_m_freemode_01" or clothingData.modelName == "mp_f_freemode_01")
    local pedEntityModelHash = GetEntityModel(PlayerPedId())
    if isModelAMultiplayerModel then
        if Config.GearData.ForceMPPedWhenPlayerIsNotAnMPPed then
            if pedEntityModelHash ~= GetHashKey(clothingData.modelName) then
                local newModel = GetHashKey(clothingData.modelName)
                RequestModel(newModel)
                
                local attempts = 0
                while not HasModelLoaded(newModel) and attempts < 10 do
                    Citizen.Wait(500)
                    attempts = attempts + 1
                end
                
                if HasModelLoaded(newModel) then
                    
                    SetPlayerModel(PlayerId(), newModel)
                    SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
                    
                    pedEntityModelHash = GetEntityModel(PlayerPedId())
                    
                    SetModelAsNoLongerNeeded(newModel)
                    Citizen.Wait(500)
                    
                    -- Confirm the model is set correctly
                    attempts = 0
                    while (pedEntityModelHash ~= GetHashKey(clothingData.modelName)) and attempts < 5 do
                        SetPlayerModel(PlayerId(), newModel)
                        Citizen.Wait(500)
                        pedEntityModelHash = GetEntityModel(PlayerPedId())
                        attempts = attempts + 1
                    end
                    
                    SetPedDefaultComponentVariation(PlayerPedId())
                    
                    if Config.Debug then
                        print("Set player model to: " .. newModel)
                    end
                else
                    print("ERROR: Could not load model, please try fetching gear again...")
                end
            end
        end
    else
        local model = clothingData.modelName
        if IsModelInCdimage(model) and IsModelValid(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end
            SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
        end
    end

    -- Clothes
    if Config.GearData.EnableSetClothing then
        if isModelAMultiplayerModel then
            ERS_SetOutfit(PlayerPedId(), clothingData)
            if Config.Debug then
                print("Setting outfit...")
            end
        end
    end

    -- Weapons
    if Config.GearData.EnableGiveWeapons then
        if QBCore or ESX then
            --Executed in s_functions.lua
            TriggerServerEvent(Config.EventPrefix..":setWeaponsAmmoComponents", weaponData)
        else 
            -- Default GTA V Weapons
            for k, v in pairs(weaponData) do
                local playerPed = PlayerPedId()
                GiveWeaponToPed(playerPed, GetHashKey(v.weaponName), v.ammoCount, false, true)
                if #v.componentList > 0 then
                    for i, component in pairs(v.componentList) do
                        GiveWeaponComponentToPed(playerPed, GetHashKey(v.weaponName), GetHashKey(component)) 
                        if Config.Debug then
                            print("Set component "..component.." to given weapon "..v.weaponName)
                        end
                    end
                end
            end
        end
    end

    -- Health and armor
    if healthData.Enabled then
        local playerPed = PlayerPedId()
        -- Health
        if healthData.Health then
            local entityHealth = GetEntityHealth(playerPed)
            local newHealth = math.min(entityHealth + healthData.Health, 200)
            
            if newHealth ~= entityHealth then
                SetEntityHealth(playerPed, newHealth)
            end
        end

        -- Armor
        if healthData.Armor then
            local entityArmor = GetPedArmour(playerPed)
            local newArmor = math.min(entityArmor + healthData.Armor, 200)
            
            if newArmor ~= entityArmor then
                SetPedArmour(playerPed, newArmor)
            end
        end
    end
end

function message(lineOne, lineTwo, lineThree, duration)
    BeginTextCommandDisplayHelp("THREESTRINGS")
    AddTextComponentSubstringPlayerName(lineOne)
    AddTextComponentSubstringPlayerName(lineTwo or "")
    AddTextComponentSubstringPlayerName(lineThree or "")
    EndTextCommandDisplayHelp(0, false, true, duration or 5000)
end

function notify(notificationText, notificationDuration, notificationPosition, notificationType)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(notificationText)
    DrawNotification(true, true)
end

function Draw3DText(x,y,z,text,scl) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        --SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString("~h~"..text)
        DrawText(_x,_y)
    end
end

function DrawTxt(text, x, y, scale, size)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(scale, size)
	SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextColour(255, 255, 255, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function allToUpper(str)
    return (string.upper(str))
end

function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do        
        Citizen.Wait(1)
    end
end

function PlaySound(folder, file, vol)
    SendNUIMessage({
        transactionType     = 'playSound',
        transactionFolder   = folder,
        transactionFile     = file, 
        transactionVolume   = vol
    })
end

function PlayRadioAnimation()
    local plyPed = PlayerPedId()
    local userServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(plyPed))
    local playerNetId = NetworkGetNetworkIdFromEntity(plyPed)

    local animDict = Config.RadioAnimationDictionary
    local animName = Config.RadioAnimationName
    local duration = Config.RadioAnimationDuration

    local taskType = "TaskPlayAnim"
    local paramsList = {
        initiatorSrc = userServerId,
        targetNetId = playerNetId,
        dict = animDict,
        anim = animName,
        blendInSpeed = 8.0,
        blendOutSpeed = -8.0,
        duration = duration,
        flag = 50,
        playbackRate = 0,
        lockX = false,
        lockY = false,
        lockZ = false
    }
    ERS_TriggerEntityTaskForAllClients(taskType, paramsList)
end

--============ POSTAL CODE INTEGRATION ============--

local raw = nil
local postals = nil
local nearestCalloutPostal = nil

if Config.Enable_Nearest_Postal then
    -- Use this, or adjust this to your postal system as an integration
    raw = LoadResourceFile("nearest-postal", GetResourceMetadata("nearest-postal", 'postal_file'))
    if raw == nil then
        print("^1ERROR^7 Postal resource 'nearest-postal' file does not exist (is not installed) or failed to load. Check https://docs.nights-software.com for installation support.")
    else
        postals = json.decode(raw)
    end
end

function getPostal(x, y) -- Editing this? Postals can not be anything other than numbers!
    if Config.Enable_Nearest_Postal then
        local theCalloutPostal = nil
        if postals ~= nil then
            local ndm = -1 -- nearest distance magnitude
            local ni = -1 -- nearest index
            for i, p in ipairs(postals) do
                local dm = (x - p.x) ^ 2 + (y - p.y) ^ 2 -- distance magnitude
                if ndm == -1 or dm < ndm then
                    ni = i
                    ndm = dm
                end
            end
            --setting the nearest
            if ni ~= -1 then
                local nd = math.sqrt(ndm) -- nearest distance
                nearestCalloutPostal = {i = ni, d = nd}
            end

            local text = postals[nearestCalloutPostal.i].code, nearestCalloutPostal.d
            theCalloutPostal = text
        else
            return "Unknown postal"
        end
        return theCalloutPostal
    else
        return "Unknown postal"
    end
end


-- Discord Webhook Integrations

function OnSendDispatchMessage(message)
    local messageData = {
        title = "DISPATCH MESSAGE SYSTEM",
        description = tostring(message),
        color = 11876095, -- https://www.mathsisfun.com/hexadecimal-decimal-colors.html (Decimal colors is what this requires, so the one with numbers only)
        authorname = "Emergency Response Simulator",
        -- authoravatarurl = player.discordMember.avatar,

        sender = "Discord user",
        senderdiscordid = 0, -- Set serverside

        -- subjecttitle = "Plate: "..plate,
        -- subjectdescription = PersonalData.userCurrentStreetName.." at postal: "..PersonalData.userCurrentPostal,

        footer = "Emergency Response Simulator - by Nights Software in collaboration with London Studios",
        footericon = "https://assets.ea-rp.com/img/ERS_Logo.png",

        thumbnail = "https://assets.ea-rp.com/img/ERS_Logo_Sq.png",
        image = "https://assets.ea-rp.com/img/ERS_Logo.png",

        discordwebhookurltype = "dispatch",
        systemname = "Dispatch - System",
    }
    TriggerServerEvent(Config.EventPrefix..":sendDiscordEmbedMessage", messageData)
end