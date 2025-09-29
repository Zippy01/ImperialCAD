local OnDutyUnits = {}
local OnDutyLEOUnits = {}
local OnDutyFireUnits = {}

local sendWebhook = Config.SendWebhook
local webhookURL = Config.WebhookURL

local disabled = Config.DisableDutyCommand

RegisterNetEvent("Imperial:AddUnitOnDuty")
AddEventHandler("Imperial:AddUnitOnDuty", function(job, src)
    local serverId = src or source
    table.insert(OnDutyUnits, serverId)
    local jobName = "Unkown"

    if job == "LEO" then
        table.insert(OnDutyLEOUnits, serverId)
        jobName = "Law Enforcement Officer"
    elseif job == "FIRE" then
        table.insert(OnDutyFireUnits, serverId)
        jobName = "Fire/Medical"
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
AddEventHandler("Imperial:RemoveUnitOnDuty", function(job, src)
    local serverId = src or source
    local jobName = "Unkown" 

    for i, unitId in ipairs(OnDutyUnits) do
        if unitId == serverId then
            table.remove(OnDutyUnits, i)
            break
        end
    end

    if job == "LEO" then
            jobName = "Law Enforcement Officer"
        for i, unitId in ipairs(OnDutyLEOUnits) do
            if unitId == serverId then
                table.remove(OnDutyLEOUnits, i)
                break
            end
        end
    elseif job == "FIRE" then
            jobName = "Fire/Medical"
        for i, unitId in ipairs(OnDutyFireUnits) do
            if unitId == serverId then
                table.remove(OnDutyFireUnits, i)
                break
            end
        end
    end

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

    for i, unitId in ipairs(OnDutyUnits) do
        if unitId == serverId then
            table.remove(OnDutyUnits, i)
            break
        end
    end

    local jobName = "Unknown"
    local jobType = nil

    for i, unitId in ipairs(OnDutyLEOUnits) do
        if unitId == serverId then
            table.remove(OnDutyLEOUnits, i)
            jobName = "Law Enforcement Officer"
            jobType = "LEO"
            break
        end
    end

    for i, unitId in ipairs(OnDutyFireUnits) do
        if unitId == serverId then
            table.remove(OnDutyFireUnits, i)
            jobName = "Fire/Medical"
            jobType = "FIRE"
            break
        end
    end

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
    for i, unitId in ipairs(OnDutyUnits) do
        if unitId == serverId then
            return true
        else
            return false
        end
    end
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

    table.insert(OnDutyUnits, serverId)

    if job == "LEO" then
        table.insert(OnDutyLEOUnits, serverId)
    elseif job == "FIRE" then
        table.insert(OnDutyFireUnits, serverId)
    end

    print("Added to OnDuty Units: "..GetPlayerName(serverId).." Job: "..job)
end)

RegisterNetEvent("Imperial:RemoveUnitOnDutydisabled")
AddEventHandler("Imperial:RemoveUnitOnDutydisabled", function(serverId, job)

    local job = job or "Unkown"
    
    for i, unitId in ipairs(OnDutyUnits) do

        if unitId == serverId then
            table.remove(OnDutyUnits, i)
            break
        end

    end

    if job == "LEO" then

        for i, unitId in ipairs(OnDutyLEOUnits) do
            if unitId == serverId then
                table.remove(OnDutyLEOUnits, i)
                break
            end
        end

    elseif job == "FIRE" then

        for i, unitId in ipairs(OnDutyFireUnits) do
            if unitId == serverId then
                table.remove(OnDutyFireUnits, i)
                break
            end
        end

    end

    print("Removed from OnDuty Units: " .. GetPlayerName(serverId))

end)

end

exports('GetOnDutyUnits', GetOnDutyUnits)
exports('GetOnDutyLEOUnits', GetOnDutyLEOUnits)
exports('GetOnDutyFireUnits', GetOnDutyFireUnits)