local currentPostal, currentCity, currentCounty

local function updateLocationData()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    TriggerServerEvent('ImperialLocation:updateNearest', {x = playerCoords.x, y = playerCoords.y})
end

Citizen.CreateThread(function()
    while true do
        updateLocationData()
        Citizen.Wait(Config.locationFrequency)
    end
end)

RegisterCommand("getlocation", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    TriggerServerEvent('ImperialLocation:updateNearest', {x = playerCoords.x, y = playerCoords.y}, true)
end, false)

RegisterNetEvent('ImperialLocation:PrintNearest')
AddEventHandler('ImperialLocation:PrintNearest', function(nearestPostal, nearestCity, nearestCounty)
    local postalText = nearestPostal and nearestPostal.code or "None"
    local cityText = nearestCity and nearestCity.city or "None"
    local countyText = nearestCounty and nearestCounty.county or "None"
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"Me", "Nearest Postal: " .. postalText .. ", City: " .. cityText .. ", County: " .. countyText}
    })
end)

RegisterNetEvent('ImperialLocation:receiveNearest')
AddEventHandler('ImperialLocation:receiveNearest', function(nearestPostal, nearestCity, nearestCounty)
    currentPostal = nearestPostal and nearestPostal.code or "None"
    currentCity = nearestCity and nearestCity.city or "None"
    currentCounty = nearestCounty and nearestCounty.county or "None"
end)

function GetImperialPostal()
    return currentPostal or "None"
end

exports('getPostal', GetImperialPostal)

function GetImperialCity()
    return currentCity or "None"
end

exports('getCity', GetImperialCity)

function GetImperialCounty()
    return currentCounty or "None"
end

exports('getCounty', GetImperialCounty)