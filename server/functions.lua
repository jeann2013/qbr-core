QBCore = {}
QBCore.Player = {}
QBCore.Players = {}
QBCore.ServerCallbacks = {}

-- Shared

exports('GetGangs', function()
    return QBShared.Gangs
end)

exports('GetHorses', function()
    return QBShared.Horses
end)

exports('GetItems', function()
    return QBShared.Items
end)

exports('GetJobs', function()
    return QBShared.Jobs
end)

exports('GetVehicles', function()
    return QBShared.Vehicles
end)

exports('GetWeapons', function()
    return QBShared.Weapons
end)

-- Returns the entire player object
exports('GetQBPlayers', function()
    return QBCore.Players
end)

-- Returns a player's specific identifier
-- Accepts steamid, license, discord, xbl, liveid, ip
function GetIdentifier(source, idtype)
    if type(idtype) ~= "string" then return print('Invalid usage') end
    for _, identifier in pairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, idtype) then
            return identifier
        end
    end
    return nil
end
exports('GetIdentifier', GetIdentifier)

-- Returns the object of a single player by ID
function GetPlayer(source)
    return QBCore.Players[source]
end
exports('GetPlayer', GetPlayer)

-- Returns the object of a single player by Citizen ID
exports('GetPlayerByCitizenId', function(citizenid)
    for k, v in pairs(QBCore.Players) do
        local cid = citizenid
        if QBCore.Players[k].PlayerData.citizenid == cid then
            return QBCore.Players[k]
        end
    end
    return nil
end)

--- Gets a list of all on duty players of a specified job and the amount
exports('GetPlayersOnDuty', function(job)
    local players = {}
    local count = 0
    for k, v in pairs(QBCore.Players) do
        if v.PlayerData.job.name == job then
            if v.PlayerData.job.onduty then
                players[#players + 1] = k
                count = count + 1
            end
        end
    end
    return players, count
end)

-- Returns only the amount of players on duty for the specified job
exports('GetDutyCount', function(job)
    local count = 0
    for k, v in pairs(QBCore.Players) do
        if v.PlayerData.job.name == job then
            if v.PlayerData.job.onduty then
                count = count + 1
            end
        end
    end
    return count
end)

-- Callbacks

function CreateCallback(name, cb)
    QBCore.ServerCallbacks[name] = cb
end
exports('CreateCallback', CreateCallback)

function TriggerCallback(name, source, cb, ...)
    if not QBCore.ServerCallbacks[name] then return end
    QBCore.ServerCallbacks[name](source, cb, ...)
end
exports('TriggerCallback', TriggerCallback)

-- function CreateCallback(name, cb)
-- 	name = ('__cb_%s'):format(name)
-- 	RegisterServerEvent(name, function(id, ...)
-- 		TriggerClientEvent(name..id, source, {cb(source, ...)})
-- 	end)
-- end
--exports('CreateCallback', CreateCallback)

-- Items

-- Creates an item as usable
exports('CreateUsableItem', function(item, cb)
    QBCore.UsableItems[item] = cb
end)

-- Checks if an item can be used
exports('CanUseItem', function(item)
    return QBCore.UseableItems[item]
end)

-- Uses an item
exports('UseItem', function(source, item)
    QBCore.UseableItems[item.name](source, item)
end)

-- Kick Player with reason
exports('KickPlayer', function(source, reason, setKickReason, deferrals)
    reason = '\n' .. reason .. '\n🔸 Check our Discord for further information: ' .. QBConfig.Discord
    if setKickReason then
        setKickReason(reason)
    end
    CreateThread(function()
        if deferrals then
            deferrals.update(reason)
            Wait(2500)
        end
        if source then
            DropPlayer(source, reason)
        end
        local i = 0
        while (i <= 4) do
            i = i + 1
            while true do
                if source then
                    if (GetPlayerPing(source) >= 0) then
                        break
                    end
                    Wait(100)
                    CreateThread(function()
                        DropPlayer(source, reason)
                    end)
                end
            end
            Wait(5000)
        end
    end)
end)