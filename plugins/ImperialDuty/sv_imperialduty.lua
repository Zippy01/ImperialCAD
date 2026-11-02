local OnDutyUnits = {}
local OnDutyLEOUnits = {}
local OnDutyFireUnits = {}
local OnDutyLookup = {}
local OnDutyLEOLookup = {}
local OnDutyFireLookup = {}
local UnitJob = {}

local sendWebhook = Config.SendWebhook
local webhookURL = Config.WebhookURL

local disabled = Config.DisableDutyCommand

local function addUnitOnce(list, lookup, serverId)
    if not lookup[serverId] then
        table.insert(list, serverId)
        lookup[serverId] = true
    end
end

local function removeUnit(list, lookup, serverId)
    if not lookup[serverId] then return end

    lookup[serverId] = nil
    for i, unitId in ipairs(list) do
        if unitId == serverId then
            table.remove(list, i)
            break
        end
    end
end

RegisterNetEvent("Imperial:AddUnitOnDuty")
AddEventHandler("Imperial:AddUnitOnDuty", function(job, target)
    local serverId = target or source
    addUnitOnce(OnDutyUnits, OnDutyLookup, serverId)
    local jobName = "Unkown"

    if job == "LEO" then
        addUnitOnce(OnDutyLEOUnits, OnDutyLEOLookup, serverId)
        jobName = "Law Enforcement Officer"
        UnitJob[serverId] = "LEO"
    elseif job == "FIRE" then
        addUnitOnce(OnDutyFireUnits, OnDutyFireLookup, serverId)
        jobName = "Fire/Medical"
        UnitJob[serverId] = "FIRE"
    end

    if sendWebhook then
        local playerName = GetPlayerName(serverId) 
        local webhookData = {
            ["embeds"] = {
                {
                    ["color"] = 16711680,
                    ["title"] = "Player went On-Duty",
                    ["description"] = "Player: "..playerName.."\nJob: "..jobName,
                    ["footer"] = {
                        ["text"] = "ImperialCAD - ImperialDuty | In-game"
                    }
                }
            }
        }

        PerformHttpRequest(webhookURL, function(err, text, headers)
            if err ~= 204 then
                print("^1[ImperialDuty] Error sending webhook: HTTP "..tostring(err).."^0")
                if text then print("^1[ImperialDuty] Response: "..text.."^0") end
            else
                print("^2[ImperialDuty] Webhook sent successfully.^0")
            end
        end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
    end

    print("Added to OnDuty Units: "..GetPlayerName(serverId).." Job: "..job)
end)

RegisterNetEvent("Imperial:RemoveUnitOnDuty")
AddEventHandler("Imperial:RemoveUnitOnDuty", function(job, target)
    local serverId = target or source
    job = job or UnitJob[serverId]
    local jobName = "Unkown" 

    removeUnit(OnDutyUnits, OnDutyLookup, serverId)

    if job == "LEO" then
            jobName = "Law Enforcement Officer"
        removeUnit(OnDutyLEOUnits, OnDutyLEOLookup, serverId)
    elseif job == "FIRE" then
            jobName = "Fire/Medical"
        removeUnit(OnDutyFireUnits, OnDutyFireLookup, serverId)
    end
    UnitJob[serverId] = nil

    if sendWebhook then
        local playerName = GetPlayerName(serverId)
        local webhookData = {
            ["embeds"] = {
                {
                    ["color"] = 16711680,
                    ["title"] = "Player Went Off-Duty",
                    ["description"] = "Player: "..playerName.."\nJob: "..jobName,
                    ["footer"] = {
                        ["text"] = "ImperialCAD - ImperialDuty | In-game"
                    }
                }
            }
        }

        PerformHttpRequest(webhookURL, function(err, text, headers)
            if err ~= 204 then
                print("^1[ImperialDuty] Error sending webhook: HTTP "..tostring(err).."^0")
                if text then print("^1[ImperialDuty] Response: "..text.."^0") end
            else
                print("^2[ImperialDuty] Webhook sent successfully.^0")
            end
        end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
    end

    print("Removed from OnDuty Units: " .. GetPlayerName(serverId))
end)

RegisterNetEvent("playerDropped")
AddEventHandler("playerDropped", function(reason)
    local serverId = source
    local playerName = GetPlayerName(serverId)

    local jobName = "Unknown"
    local jobType = nil

    if OnDutyLEOLookup[serverId] then
        jobName = "Law Enforcement Officer"
        jobType = "LEO"
    end

    if OnDutyFireLookup[serverId] then
        jobName = "Fire/Medical"
        jobType = "FIRE"
    end

    removeUnit(OnDutyUnits, OnDutyLookup, serverId)
    removeUnit(OnDutyLEOUnits, OnDutyLEOLookup, serverId)
    removeUnit(OnDutyFireUnits, OnDutyFireLookup, serverId)
    UnitJob[serverId] = nil

    print("[ImperialDuty] Player " .. serverId .. " disconnected. Removed from duty: " .. jobName)

    if sendWebhook and jobType then
        local webhookData = {
            ["embeds"] = {
                {
                    ["color"] = 16711680,
                    ["title"] = "Player Disconnected While On-Duty",
                    ["description"] = "**Player:** " .. playerName .. "\n**Job:** " .. jobName .. "\n**Reason:** " ..(reason),
                    ["footer"] = { ["text"] = "ImperialCAD - ImperialDuty | In-game" }
                }
            }
        }

        PerformHttpRequest(webhookURL, function(err, text, headers)
            if err ~= 204 then
                print("^1[ImperialDuty] Error sending webhook: HTTP " .. tostring(err) .. "^0")
                if text then print("^1[ImperialDuty] Response: " .. text .. "^0") end
            else
                print("^2[ImperialDuty] Disconnection webhook sent successfully.^0")
            end
        end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
    end
end)

function IsUnitOnDuty(serverId)
    return OnDutyLookup[serverId] == true
end


function GetOnDutyUnits()
    return OnDutyUnits
end

function GetOnDutyLEOUnits()
    return OnDutyLEOUnits
end

function GetOnDutyFireUnits()
    return OnDutyFireUnits
end

function PrintTable(tbl)
    for k, v in pairs(tbl) do
        print(k, v)
    end
end

if disabled then

RegisterNetEvent("Imperial:AddUnitOnDutydisabled")
AddEventHandler("Imperial:AddUnitOnDutydisabled", function(serverId, job)

    local job = job or "Unkown"

    addUnitOnce(OnDutyUnits, OnDutyLookup, serverId)

    if job == "LEO" then
        addUnitOnce(OnDutyLEOUnits, OnDutyLEOLookup, serverId)
        UnitJob[serverId] = "LEO"
    elseif job == "FIRE" then
        addUnitOnce(OnDutyFireUnits, OnDutyFireLookup, serverId)
        UnitJob[serverId] = "FIRE"
    end

    print("Added to OnDuty Units: "..GetPlayerName(serverId).." Job: "..job)
end)

RegisterNetEvent("Imperial:RemoveUnitOnDutydisabled")
AddEventHandler("Imperial:RemoveUnitOnDutydisabled", function(serverId, job)

    local job = job or "Unkown"
    job = job ~= "Unkown" and job or UnitJob[serverId]
    
    removeUnit(OnDutyUnits, OnDutyLookup, serverId)

    if job == "LEO" then

        removeUnit(OnDutyLEOUnits, OnDutyLEOLookup, serverId)

    elseif job == "FIRE" then

        removeUnit(OnDutyFireUnits, OnDutyFireLookup, serverId)

    end
    UnitJob[serverId] = nil

    print("Removed from OnDuty Units: " .. GetPlayerName(serverId))

end)

end

exports('GetOnDutyUnits', GetOnDutyUnits)
exports('GetOnDutyLEOUnits', GetOnDutyLEOUnits)
exports('GetOnDutyFireUnits', GetOnDutyFireUnits)
