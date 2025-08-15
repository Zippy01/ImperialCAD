callsBySrc = {}  -- { [src] = callNo }

local function _asNumberOrString(v)
    return tonumber(v) or v
end

function addCall(src, callNo)
    if Config.debug then print('Adding call num: '..callNo..' to player: '..src) end
    callNo = _asNumberOrString(callNo)
    if not callNo then return false end
    callsBySrc[src] = callNo
    return true
end

function getCall(src)
    return callsBySrc[src] or nil
end

function removeCall(src)
    if Config.deubg then print('[ImperialCAD_calls] Removing call '..callsBySrc[src]..' from player '..src) end
    callsBySrc[src] = nil
end

AddEventHandler('playerDropped', function()
    if Config.deubg then print('[ImperialCAD_calls] Player dropped, clearing last stored call') end
    callsBySrc[source] = nil
end)

--[[ I may make this a thing later on..
exports('AddCallForSource', addCall)    
exports('GetCallForSource', getCall)   
exports('GetLastCallForSource', getLastCall)
exports('RemoveCallForSource', removeCall)
]] 
