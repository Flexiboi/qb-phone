local QBCore = exports['qb-core']:GetCoreObject()
local Pings = {}

QBCore.Commands.Add("ping", "", {{name = "actie", help="id | a (accepteer) | w (weiger)"}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local task = args[1]
    local PhoneItem = Player.Functions.GetItemByName("phone")

    if PhoneItem ~= nil then
        if task == "a" then
            if Pings[src] ~= nil then
                local SenderData = {
                    id = src,
                    name =  Player.PlayerData.charinfo.firstname,
                }
                TriggerClientEvent('phone-ping:client:AcceptPing', src, Pings[src], SenderData)
                TriggerClientEvent('QBCore:Notify', Pings[src].sender, Player.PlayerData.charinfo.firstname.." accepted your ping!")
                Pings[src] = nil
            else
                TriggerClientEvent('QBCore:Notify', src, "Je hebt geen ping open..", "error")
            end
        elseif task == "w" then
            if Pings[src] ~= nil then
                TriggerClientEvent('QBCore:Notify', Pings[src].sender, "Uw ping is afgewezen..", "error")
                TriggerClientEvent('QBCore:Notify', src, "Tiy rejected the ping..", "success")
                Pings[src] = nil
            else
                TriggerClientEvent('QBCore:Notify', src, "Je hebt geen ping open..", "error")
            end
        -- else
        --     TriggerClientEvent('phone-ping:client:DoPing', src, tonumber(args[1]))
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Je hebt geen telefoon..", "error")
    end
end)

RegisterNetEvent('phone-ping:server:SendPing', function(id, coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(id)
    local PhoneItem = Player.Functions.GetItemByName("phone")

    if PhoneItem ~= nil then
        if Target ~= nil then
            local OtherItem = Target.Functions.GetItemByName("phone")
            if OtherItem ~= nil then
                TriggerClientEvent('QBCore:Notify', src, "Je hebt een ping gestuurd")
                Pings[id] = {
                    coords = coords,
                    sender = src,
                }
                TriggerClientEvent('QBCore:Notify', id, "Je ontvangt een ping ontvangen! /ping 'a | w'")
            else
                TriggerClientEvent('QBCore:Notify', src, "Kon de ping niet verzenden, persoon kan geen telefoon hebben.", "error")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "Deze persoon is niet in de stad..", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Je hebt geen telefoon", "error")
    end
end)

RegisterNetEvent('phone-ping:server:SendLocation', function(PingData, SenderData)
    print(PingData.sender)
    TriggerClientEvent('phone-ping:client:SendLocation', PingData.sender, PingData, SenderData)
end)