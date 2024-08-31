local QBCore = exports['qb-core']:GetCoreObject()
local CurrentPings = {}

RegisterNetEvent('phone-ping:client:DoPing', function(id)
    local player = GetPlayerFromServerId(id)
    local ped = GetPlayerPed(player)
    local pos = GetEntityCoords(ped)
    local coords = {
        x = pos.x,
        y = pos.y,
        z = pos.z,
    }
    if not exports['qb-policejob']:IsHandcuffed() then
        TriggerServerEvent('phone-ping:server:SendPing', id, coords)
    else
        QBCore.Functions.Notify('You can\'t ping at the moment.', 'error')
    end
end)

RegisterNetEvent('phone-ping:client:AcceptPing', function(PingData, SenderData)
    local pos = GetEntityCoords(PlayerPedId())
    local newSendData = {
        id = SenderData.id,
        name = SenderData.name,
        loc = pos
    }
    if not exports['qb-policejob']:IsHandcuffed() then
        TriggerServerEvent('phone-ping:server:SendLocation', PingData, newSendData)
    else
        QBCore.Functions.Notify('You can\'t accept the ping at the moment.', 'error')
    end
end)

RegisterNetEvent('phone-ping:client:SendLocation', function(PingData, SenderData)
    QBCore.Functions.Notify('The location has been set on your GPS.', 'success')

    CurrentPings[SenderData.id] = AddBlipForCoord(SenderData.loc.x, SenderData.loc.y, SenderData.loc.z)
    SetBlipSprite(CurrentPings[SenderData.id], 280)
    SetBlipDisplay(CurrentPings[SenderData.id], 4)
    SetBlipScale(CurrentPings[SenderData.id], 1.1)
    SetBlipAsShortRange(CurrentPings[SenderData.idr], false)
    SetBlipColour(CurrentPings[SenderData.id], 0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(SenderData.name)
    EndTextCommandSetBlipName(CurrentPings[SenderData.id])

    SetTimeout(1 * (60 * 1000), function()
        QBCore.Functions.Notify('Ping '..SenderData.name..' Pin has expired..', 'error')
        RemoveBlip(CurrentPings[SenderData.id])
        CurrentPings[SenderData.id] = nil
    end)
end)