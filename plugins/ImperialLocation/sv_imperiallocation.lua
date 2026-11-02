local DATA_FOLDER = 'data'
local POSTAL_FILE = DATA_FOLDER .. '/postals.json'
local CITY_FILE = DATA_FOLDER .. '/cities.json'
local COUNTY_FILE = DATA_FOLDER .. '/counties.json'

local playerLocationData = {}
local GRID_CELL_SIZE = 250.0
local MAX_GRID_SEARCH_RADIUS = 8

local function loadData(fileName)
    local file = LoadResourceFile(GetCurrentResourceName(), fileName)
    if file then
        local ok, data = pcall(json.decode, file)
        if ok and type(data) == "table" then
            print("Loaded " .. fileName .. " successfully with " .. #data .. " entries.")
            return data
        else
            print("[Error] JSON decoding failed for " .. fileName)
            return {}
        end
    else
        print("[Error] Failed to load " .. fileName)
        return {}
    end
end

local postals, cities, counties = loadData(POSTAL_FILE), loadData(CITY_FILE), loadData(COUNTY_FILE)

local function calculateDistanceSquared(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return dx * dx + dy * dy
end

local function getGridKey(cellX, cellY)
    return cellX .. ":" .. cellY
end

local function getCell(value)
    return math.floor(value / GRID_CELL_SIZE)
end

local function getMinDistanceOutsideRadiusSq(x, y, originCellX, originCellY, radius)
    local minX = (originCellX - radius) * GRID_CELL_SIZE
    local maxX = (originCellX + radius + 1) * GRID_CELL_SIZE
    local minY = (originCellY - radius) * GRID_CELL_SIZE
    local maxY = (originCellY + radius + 1) * GRID_CELL_SIZE
    local dx = math.min(math.abs(x - minX), math.abs(maxX - x))
    local dy = math.min(math.abs(y - minY), math.abs(maxY - y))

    return math.min(dx * dx, dy * dy)
end

local function buildSpatialIndex(locations)
    local index = {}

    for _, location in ipairs(locations) do
        local x = tonumber(location.x)
        local y = tonumber(location.y)

        if x and y then
            location.x = x
            location.y = y

            local key = getGridKey(getCell(x), getCell(y))
            index[key] = index[key] or {}
            index[key][#index[key] + 1] = location
        end
    end

    return {
        buckets = index,
        locations = locations
    }
end

local postalIndex = buildSpatialIndex(postals)
local cityIndex = buildSpatialIndex(cities)
local countyIndex = buildSpatialIndex(counties)

local function getNearestFromList(coords, locations)
    local nearest = nil
    local shortestDistSq = math.huge

    for _, location in ipairs(locations) do
        local locationX = tonumber(location.x)
        local locationY = tonumber(location.y)

        if locationX and locationY then
            local distSq = calculateDistanceSquared(coords.x, coords.y, locationX, locationY)

            if distSq < shortestDistSq then
                nearest = location
                shortestDistSq = distSq
            end
        end
    end

    return nearest
end

local function getNearestLocation(coords, spatialIndex)
    local x = tonumber(coords and coords.x)
    local y = tonumber(coords and coords.y)

    if not x or not y then return nil end

    local originCellX = getCell(x)
    local originCellY = getCell(y)
    local nearest = nil
    local shortestDistSq = math.huge

    for radius = 0, MAX_GRID_SEARCH_RADIUS do
        local searchedAny = false

        for cellX = originCellX - radius, originCellX + radius do
            for cellY = originCellY - radius, originCellY + radius do
                if radius == 0 or cellX == originCellX - radius or cellX == originCellX + radius or cellY == originCellY - radius or cellY == originCellY + radius then
                    local bucket = spatialIndex.buckets[getGridKey(cellX, cellY)]

                    if bucket then
                        searchedAny = true

                        for _, location in ipairs(bucket) do
                            local distSq = calculateDistanceSquared(x, y, location.x, location.y)

                            if distSq < shortestDistSq then
                                nearest = location
                                shortestDistSq = distSq
                            end
                        end
                    end
                end
            end
        end

        if nearest and searchedAny and shortestDistSq <= getMinDistanceOutsideRadiusSq(x, y, originCellX, originCellY, radius) then
            return nearest
        end
    end

    return getNearestFromList({ x = x, y = y }, spatialIndex.locations)
end

RegisterNetEvent('ImperialLocation:updateNearest')
AddEventHandler('ImperialLocation:updateNearest', function(playerCoords, shouldDisplay)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = nil

    if ped and ped ~= 0 then
        local serverCoords = GetEntityCoords(ped)
        coords = {
            x = serverCoords.x,
            y = serverCoords.y
        }
    elseif playerCoords and playerCoords.x and playerCoords.y then
        coords = {
            x = tonumber(playerCoords.x),
            y = tonumber(playerCoords.y)
        }
    end

    if not coords or not coords.x or not coords.y then
        if Config.debug then print("[ImperialLocation] Missing coordinates for player " .. src .. ".") end
        return
    end

    local nearestPostal = getNearestLocation(coords, postalIndex)
    local nearestCity = getNearestLocation(coords, cityIndex)
    local nearestCounty = getNearestLocation(coords, countyIndex)

    local oldData = playerLocationData[src]
    local locationChanged = not oldData
        or (oldData.postal and oldData.postal.code) ~= (nearestPostal and nearestPostal.code)
        or (oldData.city and oldData.city.city) ~= (nearestCity and nearestCity.city)
        or (oldData.county and oldData.county.county) ~= (nearestCounty and nearestCounty.county)

    playerLocationData[src] = {
        postal = nearestPostal,
        city = nearestCity,
        county = nearestCounty
    }

    if locationChanged then
        TriggerClientEvent('ImperialLocation:receiveNearest', src, nearestPostal, nearestCity, nearestCounty)
    end

    if shouldDisplay then
        TriggerClientEvent('ImperialLocation:PrintNearest', src, nearestPostal, nearestCity, nearestCounty)
    end
end)

RegisterCommand("debugLocationData", function(src)
    print("^3[IMPERIAL DEBUG]^7 Dumping all player location data:")
    for playerId, data in pairs(playerLocationData) do
        print(("Player %s:"):format(playerId))
        print("  Postal:", data.postal and data.postal.code or "None")
        print("  City:  ", data.city and data.city.city or "None")
        print("  County:", data.county and data.county.county or "None")
    end
end, true)

RegisterCommand("debugCoordsLocation", function(src)
    local coords = { x = 1909.0826, y = 3654.7751 }
    local postal = exports["ImperialCAD"]:getNearestPostalFromCoords(coords)
    local city = exports["ImperialCAD"]:getNearestCityFromCoords(coords)
    local county = exports["ImperialCAD"]:getNearestCountyFromCoords(coords)
    
    print("^3[IMPERIAL DEBUG]^7 Nearest location info for coords: x=" .. coords.x .. ", y=" .. coords.y)
    print("  Postal:", postal)
    print("  City:  ", city)
    print("  County:", county)
end, true)

exports('getPostal', function(playerId)
    return playerLocationData[playerId] and playerLocationData[playerId].postal.code or "Unkown"
end)

exports('getCity', function(playerId)
    return playerLocationData[playerId] and playerLocationData[playerId].city.city or "Unkown"
end)

exports('getCounty', function(playerId)
    return playerLocationData[playerId] and playerLocationData[playerId].county.county or "Unkown"
end)

AddEventHandler('playerDropped', function()
    playerLocationData[source] = nil
end)

exports('getNearestPostalFromCoords', function(coords)
    local location = getNearestLocation(coords, postalIndex)
    return location and location.code or "Unknown"
end)

exports('getNearestCityFromCoords', function(coords)
    local location = getNearestLocation(coords, cityIndex)
    return location and location.city or "Unknown"
end)

exports('getNearestCountyFromCoords', function(coords)
    local location = getNearestLocation(coords, countyIndex)
    return location and location.county or "Unknown"
end)


