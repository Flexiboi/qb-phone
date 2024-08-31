local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
local patt = '[?!@#]'
local frontCam = false
local IsTyping = false
PhoneData = {
    MetaData = {},
    isOpen = false,
    isMute = false,
    PlayerData = nil,
    Contacts = {},
    Tweets = {},
    MentionedTweets = {},
    Hashtags = {},
    Chats = {},
    Invoices = {},
    CallData = {},
    RecentCalls = {},
    Garage = {},
    Notes = {},
    Mails = {},
    Adverts = {},
    GarageVehicles = {},
    AnimationData = {
        lib = nil,
        anim = nil,
    },
    SuggestedContacts = {},
    CryptoTransactions = {},
    Images = {},
}

--Ringtome
local xSound = exports.xsound
local ringToneList = {}
local ringtoneOn = false

-- Functions

function string:split(delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        result[#result + 1] = string.sub(self, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    result[#result + 1] = string.sub(self, from)
    return result
end

local function escape_str(s)
    return s
end

local function GenerateTweetId()
    local tweetId = 'TWAT-' .. math.random(11111111, 99999999)
    return tweetId
end

local function GenerateAdsId()
    local AdsId = 'Ads-' .. math.random(11111111, 99999999)
    return AdsId
end

local function IsNumberInContacts(num)
    local retval = num
    for _, v in pairs(PhoneData.Contacts) do
        if num == v.number then
            retval = v.name
        end
    end
    return retval
end

local function CalculateTimeToDisplay()
    local hour = GetClockHours()
    local minute = GetClockMinutes()

    local obj = {}

    if minute <= 9 then
        minute = '0' .. minute
    end

    obj.hour = hour
    obj.minute = minute

    return obj
end

local function GetClosestPlayer()
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())
    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

local function GetKeyByDate(Number, Date)
    local retval = nil
    if PhoneData.Chats[Number] ~= nil then
        if PhoneData.Chats[Number].messages ~= nil then
            for key, chat in pairs(PhoneData.Chats[Number].messages) do
                if chat.date == Date then
                    retval = key
                    break
                end
            end
        end
    end
    return retval
end

local function GetKeyByNumber(Number)
    local retval = nil
    if PhoneData.Chats then
        for k, v in pairs(PhoneData.Chats) do
            if v.number == Number then
                retval = k
            end
        end
    end
    return retval
end

local function ReorganizeChats(key)
    local ReorganizedChats = {}
    ReorganizedChats[1] = PhoneData.Chats[key]
    for k, chat in pairs(PhoneData.Chats) do
        if k ~= key then
            ReorganizedChats[#ReorganizedChats + 1] = chat
        end
    end
    PhoneData.Chats = ReorganizedChats
end

local function findVehFromPlateAndLocate(plate)
    local gameVehicles = QBCore.Functions.GetVehicles()
    for i = 1, #gameVehicles do
        local vehicle = gameVehicles[i]
        if DoesEntityExist(vehicle) then
            if QBCore.Functions.GetPlate(vehicle) == plate then
                local vehCoords = GetEntityCoords(vehicle)
                SetNewWaypoint(vehCoords.x, vehCoords.y)
                return true
            end
        end
    end
end

local function DisableDisplayControlActions()
    DisableControlAction(0, 1, true)   -- disable mouse look
    DisableControlAction(0, 2, true)   -- disable mouse look
    DisableControlAction(0, 3, true)   -- disable mouse look
    DisableControlAction(0, 4, true)   -- disable mouse look
    DisableControlAction(0, 5, true)   -- disable mouse look
    DisableControlAction(0, 6, true)   -- disable mouse look
    DisableControlAction(0, 263, true) -- disable melee
    DisableControlAction(0, 264, true) -- disable melee
    DisableControlAction(0, 257, true) -- disable melee
    DisableControlAction(0, 140, true) -- disable melee
    DisableControlAction(0, 141, true) -- disable melee
    DisableControlAction(0, 142, true) -- disable melee
    DisableControlAction(0, 143, true) -- disable melee
    DisableControlAction(0, 177, true) -- disable escape
    DisableControlAction(0, 200, true) -- disable escape
    DisableControlAction(0, 202, true) -- disable escape
    DisableControlAction(0, 322, true) -- disable escape
    DisableControlAction(0, 245, true) -- disable chat
end

local function LoadPhone()
    Wait(100)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetPhoneData', function(pData)
        PlayerJob = QBCore.Functions.GetPlayerData().job
        PhoneData.PlayerData = QBCore.Functions.GetPlayerData()
        local PhoneMeta = PhoneData.PlayerData.metadata['phone']
        PhoneData.MetaData = PhoneMeta

        if pData.InstalledApps ~= nil and next(pData.InstalledApps) ~= nil then
            for _, v in pairs(pData.InstalledApps) do
                local AppData = Config.StoreApps[v.app]
                Config.PhoneApplications[v.app] = {
                    app = v.app,
                    color = AppData.color,
                    icon = AppData.icon,
                    tooltipText = AppData.title,
                    tooltipPos = 'right',
                    job = AppData.job,
                    blockedjobs = AppData.blockedjobs,
                    slot = AppData.slot,
                    Alerts = 0,
                }
            end
        end

        if PhoneMeta.profilepicture == nil then
            PhoneData.MetaData.profilepicture = 'default'
        else
            PhoneData.MetaData.profilepicture = PhoneMeta.profilepicture
        end

        if pData.Applications ~= nil and next(pData.Applications) ~= nil then
            for k, v in pairs(pData.Applications) do
                Config.PhoneApplications[k].Alerts = v
            end
        end

        if pData.MentionedTweets ~= nil and next(pData.MentionedTweets) ~= nil then
            PhoneData.MentionedTweets = pData.MentionedTweets
        end

        if pData.Notes ~= nil and next(pData.Notes) ~= nil then 
            PhoneData.Notes = pData.Notes
        end

        if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then
            PhoneData.Contacts = pData.PlayerContacts
        end

        if pData.Chats ~= nil and next(pData.Chats) ~= nil then
            local Chats = {}
            for _, v in pairs(pData.Chats) do
                Chats[v.number] = {
                    name = IsNumberInContacts(v.number),
                    number = v.number,
                    messages = json.decode(v.messages)
                }
            end

            PhoneData.Chats = Chats
        end

        if pData.Invoices ~= nil and next(pData.Invoices) ~= nil then
            -- for _, invoice in pairs(pData.Invoices) do
            --     invoice.name = IsNumberInContacts(invoice.number)
            -- end
            PhoneData.Invoices = pData.Invoices
        end

        if pData.Hashtags ~= nil and next(pData.Hashtags) ~= nil then
            PhoneData.Hashtags = pData.Hashtags
        end

        if pData.Tweets ~= nil and next(pData.Tweets) ~= nil then
            PhoneData.Tweets = pData.Tweets
        end

        if pData.Mails ~= nil and next(pData.Mails) ~= nil then
            PhoneData.Mails = pData.Mails
        end

        if pData.Adverts ~= nil and next(pData.Adverts) ~= nil then
            PhoneData.Adverts = pData.Adverts
        end

        if pData.CryptoTransactions ~= nil and next(pData.CryptoTransactions) ~= nil then
            PhoneData.CryptoTransactions = pData.CryptoTransactions
        end
        if pData.Images ~= nil and next(pData.Images) ~= nil then
            PhoneData.Images = pData.Images
        end

        if PhoneMeta.isMute == nil then
            PhoneData.isMute = false
        else
            PhoneData.isMute = pData.isMute
        end

        SendNUIMessage({
            action = 'LoadPhoneData',
            PhoneData = PhoneData,
            PlayerData = PhoneData.PlayerData,
            PlayerJob = PhoneData.PlayerData.job,
            applications = Config.PhoneApplications,
            PlayerId = GetPlayerServerId(PlayerId())
        })
    end)
end

local function OpenPhone()
    QBCore.Functions.TriggerCallback('qb-phone:server:HasPhone', function(HasPhone, HasVpn)
        if HasPhone then
            PhoneData.PlayerData = QBCore.Functions.GetPlayerData()
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'open',
                Tweets = PhoneData.Tweets,
                AppData = Config.PhoneApplications,
                CallData = PhoneData.CallData,
                PlayerData = PhoneData.PlayerData,
                HasVpn = HasVpn,
            })
            PhoneData.isOpen = true
            PhoneData.HasVpn =  HasVpn

            CreateThread(function()
                while PhoneData.isOpen do
                    DisableDisplayControlActions()
                    Wait(1)
                end
            end)

            if not PhoneData.CallData.InCall then
                DoPhoneAnimation('cellphone_text_in')
            else
                DoPhoneAnimation('cellphone_call_to_text')
            end

            SetTimeout(250, function()
                newPhoneProp()
            end)

            QBCore.Functions.TriggerCallback('qb-garages:server:GetPlayerVehicles', function(vehicles)
                PhoneData.GarageVehicles = vehicles
            end)
        else
            QBCore.Functions.Notify("Je hebt geen telefoon", 'error')
        end
    end)
end

local function GenerateCallId(caller, target)
    local CallId = math.ceil(((tonumber(caller) + tonumber(target)) / 100 * 1))
    return CallId
end

local function CancelCall()
    stopRingtone()
    TriggerServerEvent('qb-phone:server:CancelCall', PhoneData.CallData)
    if PhoneData.CallData.CallType == 'ongoing' then
        exports['pma-voice']:removePlayerFromCall(PhoneData.CallData.CallId)
    end
    PhoneData.CallData.CallType = nil
    PhoneData.CallData.InCall = false
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = {}
    PhoneData.CallData.CallId = nil

    if not PhoneData.isOpen then
        StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        deletePhone()
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    end

    TriggerServerEvent('qb-phone:server:SetCallState', false)

    if not PhoneData.isOpen then
        SendNUIMessage({
            action = 'PhoneNotification',
            PhoneNotify = {
                title = 'Telefoon',
                text = 'De oproep is beëindigd',
                icon = 'fas fa-phone',
                color = '#e84118',
            },
        })
    else
        SendNUIMessage({
            action = 'PhoneNotification',
            PhoneNotify = {
                title = 'Telefoon',
                text = 'De oproep is beëindigd',
                icon = 'fas fa-phone',
                color = '#e84118',
            },
        })

        SendNUIMessage({
            action = 'SetupHomeCall',
            CallData = PhoneData.CallData,
        })

        SendNUIMessage({
            action = 'CancelOutgoingCall',
        })
    end
end

local function CallContact(CallData, AnonymousCall, NpcData)
    local RepeatCount = 0
    PhoneData.CallData.CallType = 'outgoing'
    PhoneData.CallData.InCall = true
    PhoneData.CallData.TargetData = CallData
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.CallId = GenerateCallId(PhoneData.PlayerData.charinfo.phone, CallData.number)
    if not NpcData.IsNpc then
        TriggerServerEvent('qb-phone:server:CallContact', PhoneData.CallData.TargetData, PhoneData.CallData.CallId, AnonymousCall)
    elseif tonumber(NpcData.event.args[1]) == 911 then
        TriggerServerEvent('qb-phone:server:Call911', PhoneData.CallData.CallId, AnonymousCall)
    end
    TriggerServerEvent('qb-phone:server:SetCallState', true)

    for _ = 1, Config.CallRepeats + 1, 1 do
        if not PhoneData.CallData.AnsweredCall then
            if RepeatCount + 1 ~= Config.CallRepeats + 1 then
                if PhoneData.CallData.InCall then
                    RepeatCount = RepeatCount + 1
                    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'calling', 0.1)
                else
                    break
                end
                Wait(Config.RepeatTimeout)
            else
                if NpcData.IsNpc then
                    if tonumber(NpcData.event.args[1]) ~= 911 then
                        if PhoneData.isOpen then
                            DoPhoneAnimation('cellphone_text_to_call')
                        else
                            DoPhoneAnimation('cellphone_call_listen_base')
                        end

                        if NpcData.event.call.time <= 0 then
                            if NpcData.event.type == 'client' then
                                TriggerEvent(NpcData.event.trigger, NpcData.event.args)
                            elseif NpcData.event.type == 'server' then
                                TriggerServerEvent(NpcData.event.trigger, NpcData.event.args)
                            end
                        else
                            TriggerServerEvent('InteractSound_SV:PlayOnSource', NpcData.event.call.sound, 0.1)
                            SetTimeout(1000 * NpcData.event.call.time, function()
                                if NpcData.event.type == 'client' then
                                    TriggerEvent(NpcData.event.trigger, NpcData.event.args)
                                elseif NpcData.event.type == 'server' then
                                    TriggerServerEvent(NpcData.event.trigger, NpcData.event.args)
                                end
                                CancelCall()
                            end)
                        end
                    else
                        CancelCall()
                    end
                else
                    CancelCall()
                end
                break
            end
        else
            break
        end
    end
end
exports('CallContact', CallContact)

local function CallContactData(ContactData, Anonymous)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetCallState', function(CanCall, IsOnline, NpcData, _)
        local status = {
            CanCall = CanCall,
            IsOnline = IsOnline,
            InCall = PhoneData.CallData.InCall,
        }
        if NpcData.IsNpc then
            status = {
                CanCall = CanCall,
                IsOnline = true,
                InCall = PhoneData.CallData.InCall,
            }
        end
        if CanCall and not status.InCall and (ContactData.number ~= PhoneData.PlayerData.charinfo.phone) then
            CallContact(ContactData, Anonymous, NpcData)
        end
    end, ContactData)
end
exports('CallContactData', CallContactData)

local function AnswerCall()
    if (PhoneData.CallData.CallType == 'incoming' or PhoneData.CallData.CallType == 'outgoing') and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = 'ongoing'
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0

        SendNUIMessage({ action = 'AnswerCall', CallData = PhoneData.CallData })
        SendNUIMessage({ action = 'SetupHomeCall', CallData = PhoneData.CallData })

        TriggerServerEvent('qb-phone:server:SetCallState', true)

        if PhoneData.isOpen then
            DoPhoneAnimation('cellphone_text_to_call')
        else
            DoPhoneAnimation('cellphone_call_listen_base')
        end

        CreateThread(function()
            while true do
                if PhoneData.CallData.AnsweredCall then
                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                    SendNUIMessage({
                        action = 'UpdateCallTime',
                        Time = PhoneData.CallData.CallTime,
                        Name = PhoneData.CallData.TargetData.name,
                    })
                else
                    break
                end

                Wait(1000)
            end
        end)

        TriggerServerEvent('qb-phone:server:AnswerCall', PhoneData.CallData)
        exports['pma-voice']:addPlayerToCall(PhoneData.CallData.CallId)
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        SendNUIMessage({
            action = 'PhoneNotification',
            PhoneNotify = {
                title = 'Telefoon',
                text = "Je hebt geen inkomende oproep..",
                icon = 'fas fa-phone',
                color = '#e84118',
            },
        })
    end
end

local function CellFrontCamActivate(activate)
    return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

-- Command

RegisterCommand('phone', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if not PhoneData.isOpen and LocalPlayer.state.isLoggedIn then
        if not PlayerData.metadata['ishandcuffed'] and not PlayerData.metadata['inlaststand'] and not PlayerData.metadata['isdead'] and not IsPauseMenuActive() then
            OpenPhone()
        else
            QBCore.Functions.Notify('Actie op dit moment niet beschikbaar..', 'error')
        end
    end
end)

RegisterKeyMapping('phone', 'Open Telefoon', 'keyboard', 'M')

-- NUI Callbacks

RegisterNUICallback('CancelOutgoingCall', function(_, cb)
    CancelCall()
    cb('ok')
end)

RegisterNUICallback('DenyIncomingCall', function(_, cb)
    CancelCall()
    cb('ok')
end)

RegisterNUICallback('CancelOngoingCall', function(_, cb)
    CancelCall()
    cb('ok')
end)

RegisterNUICallback('AnswerCall', function(_, cb)
    AnswerCall()
    cb('ok')
end)

RegisterNUICallback('ClearRecentAlerts', function(_, cb)
    TriggerServerEvent('qb-phone:server:SetPhoneAlerts', 'phone', 0)
    Config.PhoneApplications['phone'].Alerts = 0
    SendNUIMessage({ action = 'RefreshAppAlerts', AppData = Config.PhoneApplications })
    cb('ok')
end)

RegisterNUICallback('SetBackground', function(data, cb)
    local background = data.background
    PhoneData.MetaData.background = background
    TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData)
    cb('ok')
end)

RegisterNUICallback('isMute', function(data, cb)
    local isMute = data.isMute
    PhoneData.MetaData.isMute = isMute
    PhoneData.isMute = isMute
    Wait(10)
    TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData)
    cb('ok')
end)

RegisterNUICallback('GetMissedCalls', function(_, cb)
    cb(PhoneData.RecentCalls)
end)

RegisterNUICallback('GetSuggestedContacts', function(_, cb)
    cb(PhoneData.SuggestedContacts)
end)

RegisterNUICallback('HasPhone', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:HasPhone', function(HasPhone)
        cb(HasPhone)
    end)
end)

RegisterNUICallback('SetupGarageVehicles', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-garages:server:GetPlayerVehicles', function(vehicles)
        cb(vehicles)
    end)
end)

RegisterNUICallback('RemoveMail', function(data, cb)
    local MailId = data.mailId
    TriggerServerEvent('qb-phone:server:RemoveMail', MailId)
    cb('ok')
end)

RegisterNUICallback('Close', function(_, cb)
    if not PhoneData.CallData.InCall then
        DoPhoneAnimation('cellphone_text_out')
        SetTimeout(400, function()
            StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
            deletePhone()
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        end)
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
        DoPhoneAnimation('cellphone_text_to_call')
    end
    SetNuiFocus(false, false)
    SetTimeout(500, function()
        PhoneData.isOpen = false
    end)
    cb('ok')
end)

RegisterNUICallback('AcceptMailButton', function(data, cb)
    if data.buttonEvent ~= nil or data.buttonData ~= nil then
        TriggerEvent(data.buttonEvent, data.buttonData)
    end
    TriggerServerEvent('qb-phone:server:ClearButtonData', data.mailId)
    cb('ok')
end)

RegisterNUICallback('AddNewContact', function(data, cb)
    PhoneData.Contacts[#PhoneData.Contacts + 1] = {
        name = data.ContactName,
        number = data.ContactNumber,
        iban = data.ContactIban
    }
    Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[data.ContactNumber] ~= nil and next(PhoneData.Chats[data.ContactNumber]) ~= nil then
        PhoneData.Chats[data.ContactNumber].name = data.ContactName
    end
    TriggerServerEvent('qb-phone:server:AddNewContact', data.ContactName, data.ContactNumber, data.ContactIban)
end)

RegisterNUICallback('GetMails', function(_, cb)
    cb(PhoneData.Mails)
end)

RegisterNUICallback('GetmessageappChat', function(data, cb)
    if PhoneData.Chats[data.phone] ~= nil then
        cb(PhoneData.Chats[data.phone])
    else
        cb(false)
    end
end)

RegisterNUICallback('GetProfilePicture', function(data, cb)
    local number = data.number
    QBCore.Functions.TriggerCallback('qb-phone:server:GetPicture', function(picture)
        cb(picture)
    end, number)
end)

RegisterNUICallback('GetBankContacts', function(_, cb)
    cb(PhoneData.Contacts)
end)

RegisterNUICallback('GetInvoices', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetInvoices', function(invoices)
        PhoneData.Invoices = invoices
        cb(invoices)
    end)
    -- if PhoneData.Invoices ~= nil and next(PhoneData.Invoices) ~= nil then
    --     cb(PhoneData.Invoices)
    -- else
    --     cb(nil)
    -- end
end)

RegisterNUICallback('SharedLocation', function(data, cb)
    local x = data.coords.x
    local y = data.coords.y
    SetNewWaypoint(x, y)
    SendNUIMessage({
        action = 'PhoneNotification',
        PhoneNotify = {
            title = 'Berichtjes',
            text = 'Locatie is ingesteld!',
            icon = 'fab fa-messageapp',
            color = '#25D366',
            timeout = 1500,
        },
    })
    cb('ok')
end)

RegisterNUICallback('LoadNotes', function(_, cb)
    cb(PhoneData.Notes)
end)

RegisterNetEvent('qb-phone:client:UpdateNotes', function(Notes)
    PhoneData.Notes = Notes
    SendNUIMessage({
        action = "RefreshNotes",
        Notes = PhoneData.Notes
    })
end)

RegisterNetEvent('qb-phone:client:AddNote', function(data)
    PhoneData.Notes[#PhoneData.Notes+1] = data
    SendNUIMessage({
        action = "RefreshNotes",
        Notes = PhoneData.Notes
    })
end)

RegisterNUICallback('PostNote', function(data, cb)
    TriggerServerEvent('qb-phone:server:AddNote', data)
    cb('ok')
end)

RegisterNUICallback('EditNote', function(data, cb)
    for k, v in pairs(PhoneData.Notes) do
        if data.id == v.id then
            PhoneData.Notes[k]['title'] = data.title
            PhoneData.Notes[k]['body'] = data.body
            TriggerServerEvent('qb-phone:server:EditNote', data)
        end
    end
    cb('ok')
end)

RegisterNUICallback('DeleteNote', function(data, cb)
    TriggerServerEvent('qb-phone:server:DeleteNote', data)
    cb('ok')
end)

RegisterNUICallback('PostAdvert', function(data, cb)
    TriggerServerEvent('qb-phone:server:AddAdvert', data.message, data.url, data.category)
    cb('ok')
end)

RegisterNUICallback('DeleteAdvert', function(data, cb)
    TriggerServerEvent('qb-phone:server:DeleteAdvert', data.id)
    cb('ok')
end)

RegisterNUICallback('ClearAlerts', function(data, cb)
    local chat = data.number
    local ChatKey = GetKeyByNumber(chat)

    if PhoneData.Chats[ChatKey].Unread ~= nil then
        local newAlerts = (Config.PhoneApplications['messageapp'].Alerts - PhoneData.Chats[ChatKey].Unread)
        Config.PhoneApplications['messageapp'].Alerts = newAlerts
        TriggerServerEvent('qb-phone:server:SetPhoneAlerts', 'messageapp', newAlerts)

        PhoneData.Chats[ChatKey].Unread = 0

        SendNUIMessage({
            action = 'RefreshmessageappAlerts',
            Chats = PhoneData.Chats,
        })
        SendNUIMessage({ action = 'RefreshAppAlerts', AppData = Config.PhoneApplications })
    end
    cb('ok')
end)

RegisterNUICallback('PayInvoice', function(data, cb)
    local amount = data.amount
    local invoiceId = data.invoiceId
    QBCore.Functions.TriggerCallback('qb-phone:server:PayInvoice', function(CanPay)
        cb(CanPay)
    end, amount, invoiceId)
end)

RegisterNUICallback('DeclineInvoice', function(data, cb)
    local society = data.society
    local amount = data.amount
    local invoiceId = data.invoiceId
    QBCore.Functions.TriggerCallback('qb-phone:server:DeclineInvoice', function(_, Invoices)
        PhoneData.Invoices = Invoices
        cb('ok')
    end, society, amount, invoiceId)
    TriggerServerEvent('qb-phone:server:BillingEmail', data, false)
end)

RegisterNUICallback('EditContact', function(data, cb)
    local NewName = data.CurrentContactName
    local NewNumber = data.CurrentContactNumber
    local NewIban = data.CurrentContactIban
    local OldName = data.OldContactName
    local OldNumber = data.OldContactNumber
    local OldIban = data.OldContactIban
    for _, v in pairs(PhoneData.Contacts) do
        if v.name == OldName and v.number == OldNumber then
            v.name = NewName
            v.number = NewNumber
            v.iban = NewIban
        end
    end
    if PhoneData.Chats[NewNumber] ~= nil and next(PhoneData.Chats[NewNumber]) ~= nil then
        PhoneData.Chats[NewNumber].name = NewName
    end
    Wait(100)
    cb(PhoneData.Contacts)
    TriggerServerEvent('qb-phone:server:EditContact', NewName, NewNumber, NewIban, OldName, OldNumber, OldIban)
end)

RegisterNUICallback('SetTypeState', function(data, cb)
    IsTyping = data.IsTyping
    SetNuiFocusKeepInput(not IsTyping)
end)

RegisterNUICallback('GetHashtagMessages', function(data, cb)
    if PhoneData.Hashtags[data.hashtag] ~= nil and next(PhoneData.Hashtags[data.hashtag]) ~= nil then
        cb(PhoneData.Hashtags[data.hashtag])
    else
        cb(nil)
    end
end)

RegisterNUICallback('GetTweets', function(_, cb)
    cb(PhoneData.Tweets, PhoneData.HasVpn)
end)

RegisterNUICallback('UpdateProfilePicture', function(data, cb)
    local pf = data.profilepicture
    PhoneData.MetaData.profilepicture = pf
    TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData)
    cb('ok')
end)

RegisterNUICallback('PostNewTweet', function(data, cb)
    local TweetMessage = {
        firstName = PhoneData.PlayerData.charinfo.firstname,
        lastName = PhoneData.PlayerData.charinfo.lastname,
        citizenid = PhoneData.PlayerData.citizenid,
        message = escape_str(data.Message),
        time = data.Date,
        tweetId = GenerateTweetId(),
        picture = data.Picture,
        url = data.url,
        vpntweet = data.vpntweet,
    }

    local TwitterMessage = data.Message
    local MentionTag = TwitterMessage:split('@')
    local Hashtag = TwitterMessage:split('#')
    if #Hashtag <= 3 then
        for i = 2, #Hashtag, 1 do
            local Handle = Hashtag[i]:split(' ')[1]
            if Handle ~= nil or Handle ~= '' then
                local InvalidSymbol = string.match(Handle, patt)
                if InvalidSymbol then
                    Handle = Handle:gsub('%' .. InvalidSymbol, '')
                end
                TriggerServerEvent('qb-phone:server:UpdateHashtags', Handle, TweetMessage)
            end
        end

        for i = 2, #MentionTag, 1 do
            local Handle = MentionTag[i]:split(' ')[1]
            if Handle ~= nil or Handle ~= '' then
                local Fullname = Handle:split('_')
                local Firstname = Fullname[1]
                table.remove(Fullname, 1)
                local Lastname = table.concat(Fullname, ' ')

                if (Firstname ~= nil and Firstname ~= '') and (Lastname ~= nil and Lastname ~= '') then
                    if Firstname ~= PhoneData.PlayerData.charinfo.firstname and Lastname ~= PhoneData.PlayerData.charinfo.lastname then
                        TriggerServerEvent('qb-phone:server:MentionedPlayer', Firstname, Lastname, TweetMessage)
                    end
                end
            end
        end

        PhoneData.Tweets[#PhoneData.Tweets + 1] = TweetMessage
        Wait(100)
        cb(PhoneData.Tweets)

        TriggerServerEvent('qb-phone:server:UpdateTweets', PhoneData.Tweets, TweetMessage)
    else
        SendNUIMessage({
            action = 'PhoneNotification',
            PhoneNotify = {
                title = 'Twatter',
                text = 'Ongeldige tweet',
                icon = 'fab fa-twitter',
                color = '#1DA1F2',
                timeout = 1000,
            },
        })
    end
end)

RegisterNUICallback('DeleteTweet', function(data, cb)
    TriggerServerEvent('qb-phone:server:DeleteTweet', data.id)
    cb('ok')
end)

RegisterNUICallback('GetMentionedTweets', function(_, cb)
    cb(PhoneData.MentionedTweets, PhoneData.HasVpn)
end)

RegisterNUICallback('GetHashtags', function(_, cb)
    if PhoneData.Hashtags ~= nil and next(PhoneData.Hashtags) ~= nil then
        cb(PhoneData.Hashtags)
    else
        cb(nil)
    end
end)

RegisterNUICallback('FetchSearchResults', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:FetchResult', function(result)
        cb(result)
    end, data.input)
end)

local function GetFirstAvailableSlot() -- Placeholder
    return nil
end
local CanDownloadApps = false

RegisterNUICallback('InstallApplication', function(data, cb)
    local ApplicationData = Config.StoreApps[data.app]
    local NewSlot = GetFirstAvailableSlot()

    if not CanDownloadApps then
        return
    end

    if NewSlot <= Config.MaxSlots then
        TriggerServerEvent('qb-phone:server:InstallApplication', {
            app = data.app,
        })
        cb({
            app = data.app,
            data = ApplicationData
        })
    else
        cb(false)
    end
end)

RegisterNUICallback('RemoveApplication', function(data, cb)
    TriggerServerEvent('qb-phone:server:RemoveInstallation', data.app)
    cb('ok')
end)

RegisterNUICallback('GetTruckerData', function(_, cb)
    local TruckerMeta = QBCore.Functions.GetPlayerData().metadata['jobrep']['trucker']
    local TierData = exports['qb-trucker']:GetTier(TruckerMeta)
    cb(TierData)
end)

RegisterNUICallback('GetGalleryData', function(_, cb)
    local data = PhoneData.Images
    cb(data)
end)

RegisterNUICallback('DeleteImage', function(image, cb)
    TriggerServerEvent('qb-phone:server:RemoveImageFromGallery', image)
    Wait(400)
    TriggerServerEvent('qb-phone:server:getImageFromGallery')
    cb(true)
end)


RegisterNUICallback('track-vehicle', function(data, cb)
    local veh = data.veh
    if veh.state == 'In' then
        if veh.parkingspot then
            SetNewWaypoint(veh.parkingspot.x, veh.parkingspot.y)
            QBCore.Functions.Notify("Uw voertuig is gemarkeerd", "success")
        end
    elseif veh.state == 'Out' and findVehFromPlateAndLocate(veh.plate) then
        QBCore.Functions.Notify("Uw voertuig is gemarkeerd", "success")
    else
        QBCore.Functions.Notify("Dit voertuig kan niet worden gevonden", "error")
    end
    cb("ok")
end)

RegisterNUICallback('DeleteContact', function(data, cb)
    local Name = data.CurrentContactName
    local Number = data.CurrentContactNumber

    for k, v in pairs(PhoneData.Contacts) do
        if v.name == Name and v.number == Number then
            table.remove(PhoneData.Contacts, k)
            --if PhoneData.isOpen then
            SendNUIMessage({
                action = 'PhoneNotification',
                PhoneNotify = {
                    title = 'Telefoon',
                    text = 'U hebt contact verwijderd!',
                    icon = 'fa fa-phone-alt',
                    color = '#04b543',
                    timeout = 1500,
                },
            })
            break
        end
    end
    Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[Number] ~= nil and next(PhoneData.Chats[Number]) ~= nil then
        PhoneData.Chats[Number].name = Number
    end
    TriggerServerEvent('qb-phone:server:RemoveContact', Name, Number)
end)

RegisterNUICallback('GetCryptoData', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-crypto:server:GetCryptoData', function(CryptoData)
        cb(CryptoData)
    end, data.crypto)
end)

RegisterNUICallback('BuyCrypto', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-crypto:server:BuyCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNUICallback('SellCrypto', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-crypto:server:SellCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNUICallback('TransferCrypto', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-crypto:server:TransferCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNUICallback('GetCryptoTransactions', function(_, cb)
    local Data = {
        CryptoTransactions = PhoneData.CryptoTransactions
    }
    cb(Data)
end)

RegisterNUICallback('UpdateVehicle', function(data, cb)
    local info, class, perfRating, model, brand = exports['cw-performance']:getVehicleInfo(GetPlayersLastVehicle())
    local data = {
        brand = brand,
        rating = class..''..perfRating,
        accel = math.floor(info.accel*10)/10,
        speed =  math.floor(info.speed*10)/10,
        handling =  math.floor(info.handling*10)/10,
        braking =  math.floor(info.braking*10)/10,
        drivetrain = info.drivetrain,
        model = model
    }
    cb(data)
end)

RegisterNUICallback('GetAvailableRaces', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetRaces', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('JoinRace', function(data, cb)
    TriggerServerEvent('qb-lapraces:server:JoinRace', data.RaceData)
    cb('ok')
end)

RegisterNUICallback('LeaveRace', function(data, cb)
    TriggerServerEvent('qb-lapraces:server:LeaveRace', data.RaceData)
    cb('ok')
end)

RegisterNUICallback('StartRace', function(data, cb)
    TriggerServerEvent('qb-lapraces:server:StartRace', data.RaceData.RaceId)
    cb('ok')
end)

RegisterNUICallback('SetAlertWaypoint', function(data, cb)
    local coords = data.alert.coords
    QBCore.Functions.Notify('GPS -locatieset: ' .. data.alert.title)
    SetNewWaypoint(coords.x, coords.y)
    cb('ok')
end)

RegisterNUICallback('RemoveSuggestion', function(data, cb)
    data = data.data
    if PhoneData.SuggestedContacts ~= nil and next(PhoneData.SuggestedContacts) ~= nil then
        for k, v in pairs(PhoneData.SuggestedContacts) do
            if (data.name[1] == v.name[1] and data.name[2] == v.name[2]) and data.number == v.number and data.bank == v.bank then
                table.remove(PhoneData.SuggestedContacts, k)
            end
        end
    end
    cb('ok')
end)

RegisterNUICallback('FetchVehicleResults', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetVehicleSearchResults', function(result)
        if result ~= nil then
            for k, _ in pairs(result) do
                QBCore.Functions.TriggerCallback('police:IsPlateFlagged', function(flagged)
                    result[k].isFlagged = flagged
                end, result[k].plate)
                Wait(50)
            end
        end
        cb(result)
    end, data.input)
end)

RegisterNUICallback('FetchVehicleScan', function(_, cb)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local plate = QBCore.Functions.GetPlate(vehicle)
    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
    QBCore.Functions.TriggerCallback('qb-phone:server:ScanPlate', function(result)
        QBCore.Functions.TriggerCallback('police:IsPlateFlagged', function(flagged)
            result.isFlagged = flagged
            if QBCore.Shared.Vehicles[vehname] ~= nil then
                result.label = QBCore.Shared.Vehicles[vehname]['name']
            else
                result.label = 'Onbekend merk..'
            end
            cb(result)
        end, plate)
    end, plate)
end)

RegisterNUICallback('GetRaces', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetListedRaces', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('GetTrackData', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetTrackData', function(TrackData, CreatorData)
        TrackData.CreatorData = CreatorData
        cb(TrackData)
    end, data.RaceId)
end)

RegisterNUICallback('SetupRace', function(data, cb)
    TriggerServerEvent('qb-lapraces:server:SetupRace', data.RaceId, tonumber(data.AmountOfLaps))
    cb('ok')
end)

RegisterNUICallback('HasCreatedRace', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:HasCreatedRace', function(HasCreated)
        cb(HasCreated)
    end)
end)

RegisterNUICallback('IsInRace', function(_, cb)
    local InRace = exports['qb-lapraces']:IsInRace()
    cb(InRace)
end)

RegisterNUICallback('IsAuthorizedToCreateRaces', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:IsAuthorizedToCreateRaces', function(IsAuthorized, NameAvailable)
        data = {
            IsAuthorized = IsAuthorized,
            IsBusy = exports['qb-lapraces']:IsInEditor(),
            IsNameAvailable = NameAvailable,
        }
        cb(data)
    end, data.TrackName)
end)

RegisterNUICallback('StartTrackEditor', function(data, cb)
    TriggerServerEvent('qb-lapraces:server:CreateLapRace', data.TrackName)
    cb('ok')
end)

RegisterNUICallback('GetRacingLeaderboards', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetRacingLeaderboards', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('RaceDistanceCheck', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:GetRacingData', function(RaceData)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local checkpointcoords = RaceData.Checkpoints[1].coords
        local dist = #(coords - vector3(checkpointcoords.x, checkpointcoords.y, checkpointcoords.z))
        if dist <= 115.0 then
            if data.Joined then
                TriggerEvent('qb-lapraces:client:WaitingDistanceCheck')
            end
            cb(true)
        else
            QBCore.Functions.Notify('Je bent te ver weg van de race. GPS is ingesteld op de race.', 'error', 5000)
            SetNewWaypoint(checkpointcoords.x, checkpointcoords.y)
            cb(false)
        end
    end, data.RaceId)
end)

RegisterNUICallback('IsBusyCheck', function(data, cb)
    if data.check == 'editor' then
        cb(exports['qb-lapraces']:IsInEditor())
    else
        cb(exports['qb-lapraces']:IsInRace())
    end
end)

RegisterNUICallback('CanRaceSetup', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-lapraces:server:CanRaceSetup', function(CanSetup)
        cb(CanSetup)
    end)
end)

RegisterNUICallback('GetPlayerHouses', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetPlayerHouses', function(Houses)
        cb(Houses)
    end)
end)

RegisterNUICallback('GetPlayerKeys', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetHouseKeys', function(Keys)
        cb(Keys)
    end)
end)

RegisterNUICallback('SetHouseLocation', function(data, cb)
    SetNewWaypoint(data.HouseData.HouseData.coords.enter.x, data.HouseData.HouseData.coords.enter.y)
    QBCore.Functions.Notify('GPS is ingesteld op ' .. data.HouseData.HouseData.adress .. '!', 'success')
    cb('ok')
end)

RegisterNUICallback('RemoveKeyholder', function(data, cb)
    TriggerServerEvent('qb-houses:server:removeHouseKey', data.HouseData.name, {
        citizenid = data.HolderData.citizenid,
        firstname = data.HolderData.charinfo.firstname,
        lastname = data.HolderData.charinfo.lastname,
    })
    cb('ok')
end)

RegisterNUICallback('TransferCid', function(data, cb)
    local TransferedCid = data.newBsn
    QBCore.Functions.TriggerCallback('qb-phone:server:TransferCid', function(CanTransfer)
        cb(CanTransfer)
    end, TransferedCid, data.HouseData)
end)

RegisterNUICallback('FetchPlayerHouses', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:MeosGetPlayerHouses', function(result)
        cb(result)
    end, data.input)
end)

RegisterNUICallback('SetGPSLocation', function(data, cb)
    SetNewWaypoint(data.coords.x, data.coords.y)
    QBCore.Functions.Notify('GPS is vastgesteld!', 'success')
    cb('ok')
end)

RegisterNUICallback('SetApartmentLocation', function(data, cb)
    local ApartmentData = data.data.appartmentdata
    local TypeData = Apartments.Locations[ApartmentData.type]
    SetNewWaypoint(TypeData.coords.enter.x, TypeData.coords.enter.y)
    QBCore.Functions.Notify('GPS is vastgesteld!', 'success')
    cb('ok')
end)

RegisterNUICallback('GetCurrentLawyers', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetCurrentLawyers', function(lawyers)
        cb(lawyers)
    end)
end)

RegisterNUICallback('SetupStoreApps', function(_, cb)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local data = {
        StoreApps = Config.StoreApps,
        PhoneData = PlayerData.metadata['phonedata']
    }
    cb(data)
end)

RegisterNUICallback('ClearMentions', function(_, cb)
    Config.PhoneApplications['twitter'].Alerts = 0
    SendNUIMessage({
        action = 'RefreshAppAlerts',
        AppData = Config.PhoneApplications
    })
    TriggerServerEvent('qb-phone:server:SetPhoneAlerts', 'Twatter', 0)
    SendNUIMessage({ action = 'RefreshAppAlerts', AppData = Config.PhoneApplications })
    cb('ok')
end)

RegisterNUICallback('ClearGeneralAlerts', function(data, cb)
    SetTimeout(400, function()
        Config.PhoneApplications[data.app].Alerts = 0
        SendNUIMessage({
            action = 'RefreshAppAlerts',
            AppData = Config.PhoneApplications
        })
        TriggerServerEvent('qb-phone:server:SetPhoneAlerts', data.app, 0)
        SendNUIMessage({ action = 'RefreshAppAlerts', AppData = Config.PhoneApplications })
        cb('ok')
    end)
end)

RegisterNUICallback('TransferMoney', function(data, cb)
    data.amount = tonumber(data.amount)
    if tonumber(PhoneData.PlayerData.money.bank) >= data.amount then
        local amaountata = PhoneData.PlayerData.money.bank - data.amount
        TriggerServerEvent('qb-phone:server:TransferMoney', data.iban, data.amount)
        local cbdata = {
            CanTransfer = true,
            NewAmount = amaountata
        }
        cb(cbdata)
    else
        local cbdata = {
            CanTransfer = false,
            NewAmount = nil,
        }
        cb(cbdata)
    end
end)

RegisterNUICallback('CanTransferMoney', function(data, cb)
    local amount = tonumber(data.amountOf)
    local iban = data.sendTo
    local PlayerData = QBCore.Functions.GetPlayerData()

    if (PlayerData.money.bank - amount) >= 0 then
        QBCore.Functions.TriggerCallback('qb-phone:server:CanTransferMoney', function(Transferd, newbalance)
            if Transferd then
                cb({ TransferedMoney = true, NewBalance = (PlayerData.money.bank - amount) })
            else
                SendNUIMessage({ action = 'PhoneNotification', PhoneNotify = { timeout = 3000, title = 'Bank', text = 'Account bestaat niet!', icon = 'fas fa-university', color = '#ff0000', }, })
                cb({ TransferedMoney = false })
            end
        end, amount, iban)
    else
        cb({ TransferedMoney = false })
    end
end)

RegisterNUICallback('GetmessageappChats', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetContactPictures', function(Chats)
        cb(Chats)
    end, PhoneData.Chats)
end)

RegisterNUICallback('CallContact', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetCallState', function(CanCall, IsOnline, NpcData, _)
        local status = {
            CanCall = CanCall,
            IsOnline = IsOnline,
            InCall = PhoneData.CallData.InCall,
        }
        if NpcData.IsNpc then
            status = {
                CanCall = CanCall,
                IsOnline = true,
                InCall = PhoneData.CallData.InCall,
            }
        end
        cb(status)
        if CanCall and not status.InCall and (data.ContactData.number ~= PhoneData.PlayerData.charinfo.phone) then
            CallContact(data.ContactData, data.Anonymous, NpcData)
        end
    end, data.ContactData)
end)

RegisterNUICallback('CallAds', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:GetCallStateAds', function(CanCall, IsOnline, NpcData, _)
        local status = {
            CanCall = CanCall,
            IsOnline = IsOnline,
            InCall = PhoneData.CallData.InCall,
        }
        if NpcData.IsNpc then
            status = {
                CanCall = CanCall,
                IsOnline = true,
                InCall = PhoneData.CallData.InCall,
            }
        end
        cb(status)
        if CanCall and not status.InCall and (data.ContactData.number ~= PhoneData.PlayerData.charinfo.phone) then
            CallContact(data.ContactData, data.Anonymous, NpcData)
        end
    end, data.ContactData)
end)

RegisterNUICallback('SendMessage', function(data, cb)
    local ChatMessage = data.ChatMessage
    local ChatDate = data.ChatDate
    local ChatNumber = data.ChatNumber
    local ChatTime = data.ChatTime
    local ChatType = data.ChatType
    local Ped = PlayerPedId()
    local Pos = GetEntityCoords(Ped)
    local NumberKey = GetKeyByNumber(ChatNumber)
    local ChatKey = GetKeyByDate(NumberKey, ChatDate)
    if PhoneData.Chats[NumberKey] ~= nil then
        if (PhoneData.Chats[NumberKey].messages == nil) then
            PhoneData.Chats[NumberKey].messages = {}
        end
        if PhoneData.Chats[NumberKey].messages[ChatKey] ~= nil then
            if ChatType == 'message' then
                PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages + 1] = {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                }
            elseif ChatType == 'location' then
                PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages + 1] = {
                    message = 'Gedeelde locatie',
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        x = Pos.x,
                        y = Pos.y,
                    },
                }
            elseif ChatType == 'picture' then
                PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages + 1] = {
                    message = 'Foto',
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        url = data.url
                    },
                }
            end
            TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, false)
            NumberKey = GetKeyByNumber(ChatNumber)
            ReorganizeChats(NumberKey)
        else
            PhoneData.Chats[NumberKey].messages[#PhoneData.Chats[NumberKey].messages + 1] = {
                date = ChatDate,
                messages = {},
            }
            ChatKey = GetKeyByDate(NumberKey, ChatDate)
            if ChatType == 'message' then
                PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages + 1] = {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                }
            elseif ChatType == 'location' then
                PhoneData.Chats[NumberKey].messages[ChatDate].messages[#PhoneData.Chats[NumberKey].messages[ChatDate].messages + 1] = {
                    message = 'Gedeelde locatie',
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        x = Pos.x,
                        y = Pos.y,
                    },
                }
            elseif ChatType == 'picture' then
                PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages + 1] = {
                    message = 'Foto',
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        url = data.url
                    },
                }
            end
            TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, true)
            NumberKey = GetKeyByNumber(ChatNumber)
            ReorganizeChats(NumberKey)
        end
    else
        PhoneData.Chats[#PhoneData.Chats + 1] = {
            name = IsNumberInContacts(ChatNumber),
            number = ChatNumber,
            messages = {},
        }
        NumberKey = GetKeyByNumber(ChatNumber)
        PhoneData.Chats[NumberKey].messages[#PhoneData.Chats[NumberKey].messages + 1] = {
            date = ChatDate,
            messages = {},
        }
        ChatKey = GetKeyByDate(NumberKey, ChatDate)
        if ChatType == 'message' then
            PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages + 1] = {
                message = ChatMessage,
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {},
            }
        elseif ChatType == 'location' then
            PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages + 1] = {
                message = 'Gedeelde locatie',
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {
                    x = Pos.x,
                    y = Pos.y,
                },
            }
        elseif ChatType == 'picture' then
            PhoneData.Chats[NumberKey].messages[ChatKey].messages[#PhoneData.Chats[NumberKey].messages[ChatKey].messages + 1] = {
                message = 'Foto',
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {
                    url = data.url
                },
            }
        end
        TriggerServerEvent('qb-phone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, true)
        NumberKey = GetKeyByNumber(ChatNumber)
        ReorganizeChats(NumberKey)
    end

    QBCore.Functions.TriggerCallback('qb-phone:server:GetContactPicture', function(Chat)
        SendNUIMessage({
            action = 'UpdateChat',
            chatData = Chat,
            chatNumber = ChatNumber,
        })
    end, PhoneData.Chats[GetKeyByNumber(ChatNumber)])
    cb('ok')
end)

local function SaveToInternalGallery()
    BeginTakeHighQualityPhoto()
    SaveHighQualityPhoto(0)
    FreeMemoryForHighQualityPhoto()
end

RegisterNUICallback('TakePhoto', function(_, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    CreateMobilePhone(1)
    CellCamActivate(true, true)
    local takePhoto = true
    while takePhoto do
        if IsControlJustPressed(1, 27) then -- Toogle Mode
            frontCam = not frontCam
            CellFrontCamActivate(frontCam)
        elseif IsControlJustPressed(1, 177) then -- CANCEL
            DestroyMobilePhone()
            CellCamActivate(false, false)
            cb(json.encode({ url = nil }))
            break
        elseif IsControlJustPressed(1, 176) then -- TAKE.. PIC
            QBCore.Functions.TriggerCallback('qb-phone:server:GetWebhook', function(hook)
                if not hook then
                    QBCore.Functions.Notify('Camera niet ingesteld', 'error')
                    return
                end
                exports['screenshot-basic']:requestScreenshotUpload(tostring(hook), 'files[]', function(data)
                    SaveToInternalGallery()
                    local image = json.decode(data)
                    DestroyMobilePhone()
                    CellCamActivate(false, false)
                    TriggerServerEvent('qb-phone:server:addImageToGallery', image.attachments[1].proxy_url)
                    Wait(400)
                    TriggerServerEvent('qb-phone:server:getImageFromGallery')
                    cb(json.encode(image.attachments[1].proxy_url))
                    takePhoto = false
                end)
            end)
        end
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(19)
        HideHudAndRadarThisFrame()
        EnableAllControlActions(0)
        Wait(0)
    end
    Wait(1000)
    OpenPhone()
end)

-- RegisterCommand('ping', function(_, args)
--     if not args[1] then
--         QBCore.Functions.Notify('You need to input a Player ID', 'error')
--     else
--         TriggerServerEvent('qb-phone:server:sendPing', args[1])
--     end
-- end, false)

-- Handler Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LoadPhone()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PhoneData = {
        MetaData = {},
        isOpen = false,
        PlayerData = nil,
        Contacts = {},
        Tweets = {},
        MentionedTweets = {},
        Hashtags = {},
        Chats = {},
        Invoices = {},
        CallData = {},
        RecentCalls = {},
        Garage = {},
        Notes = {},
        Mails = {},
        Adverts = {},
        GarageVehicles = {},
        AnimationData = {
            lib = nil,
            anim = nil,
        },
        SuggestedContacts = {},
        CryptoTransactions = {},
    }
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    SendNUIMessage({
        action = 'UpdateApplications',
        JobData = JobInfo,
        applications = Config.PhoneApplications
    })

    PlayerJob = JobInfo
end)

-- Events

RegisterNetEvent('qb-phone:client:ClosePhone', function()
    if not PhoneData.CallData.InCall then
        DoPhoneAnimation('cellphone_text_out')
        SetTimeout(400, function()
            StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
            deletePhone()
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        end)
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
        DoPhoneAnimation('cellphone_text_to_call')
    end
    SetNuiFocus(false, false)
    SetTimeout(500, function()
        PhoneData.isOpen = false
    end)
end)

RegisterNetEvent('qb-phone:client:PhoneNotify', function(title, text, icon, color)
    SendNUIMessage({
        action = 'PhoneNotification',
        PhoneNotify = {
            title = title,
            text = text,
            icon = icon,
            color = color,
            timeout = 1000,
        },
    })
end)

RegisterNetEvent('qb-phone:client:TransferMoney', function(amount, newmoney)
    PhoneData.PlayerData.money.bank = newmoney
    SendNUIMessage({ action = 'PhoneNotification', PhoneNotify = { title = 'Fleeca', text = '&#8364;' .. amount .. ' is aan uw account toegevoegd!', icon = 'fas fa-university', color = '#8c7ae6', }, })
    SendNUIMessage({ action = 'UpdateBank', NewBalance = PhoneData.PlayerData.money.bank })
end)

-- RegisterNetEvent('qb-phone:client:UpdateTweetsDel', function(source, Tweets)
--     PhoneData.Tweets = Tweets
--     print(source)
--     print(PhoneData.PlayerData.source)
--     --local MyPlayerId = PhoneData.PlayerData.source
--     --GetPlayerServerId(PlayerPedId())
--     if source ~= MyPlayerId then
--         SendNUIMessage({
--             action = "UpdateTweets",
--             Tweets = PhoneData.Tweets
--         })
--     end
-- end)

RegisterNetEvent('qb-phone:client:UpdateTweets', function(src, Tweets, NewTweetData, delete)
    PhoneData.Tweets = Tweets
    local MyPlayerId = PhoneData.PlayerData.source
    if not delete then -- New Tweet
        if src ~= MyPlayerId then
            if not NewTweetData.vpntweet then
                SendNUIMessage({
                    action = 'PhoneNotification',
                    PhoneNotify = {
                        title = 'Nieuwe twat (@' .. NewTweetData.firstName .. ' ' .. NewTweetData.lastName .. ')',
                        text = 'Een nieuwe tweet zoals gepost.',
                        icon = 'fab fa-twitter',
                        color = '#1DA1F2',
                    },
                })
            elseif PhoneData.HasVpn then
                SendNUIMessage({
                    action = 'PhoneNotification',
                    PhoneNotify = {
                        title = 'Nieuwe twat (@' .. NewTweetData.firstName .. ' ' .. NewTweetData.lastName .. ')',
                        text = 'Een nieuwe twat zoals gepost.',
                        icon = 'fab fa-twitter',
                        color = '#1DA1F2',
                    },
                })
            end
            SendNUIMessage({
                action = 'UpdateTweets',
                Tweets = PhoneData.Tweets
            })
        else
            SendNUIMessage({
                action = 'PhoneNotification',
                PhoneNotify = {
                    title = 'Twatter',
                    text = 'De tweet is gepost!',
                    icon = 'fab fa-twitter',
                    color = '#1DA1F2',
                    timeout = 1000,
                },
            })
        end
    else -- Deleting a tweet
        if src == MyPlayerId then
            SendNUIMessage({
                action = 'PhoneNotification',
                PhoneNotify = {
                    title = 'Twatter',
                    text = 'The Tweet has been deleted!',
                    icon = 'fab fa-twitter',
                    color = '#1DA1F2',
                    timeout = 1000,
                },
            })
        end
        SendNUIMessage({
            action = 'UpdateTweets',
            Tweets = PhoneData.Tweets
        })
    end
end)

RegisterNetEvent('qb-phone:client:RaceNotify', function(message)
    SendNUIMessage({
        action = 'PhoneNotification',
        PhoneNotify = {
            title = 'Racing',
            text = message,
            icon = 'fas fa-flag-checkered',
            color = '#353b48',
            timeout = 3500,
        },
    })
end)

RegisterNetEvent('qb-phone:client:AddRecentCall', function(data, time, type)
    PhoneData.RecentCalls[#PhoneData.RecentCalls + 1] = {
        name = IsNumberInContacts(data.number),
        time = time,
        type = type,
        number = data.number,
        anonymous = data.anonymous
    }
    TriggerServerEvent('qb-phone:server:SetPhoneAlerts', 'phone')
    Config.PhoneApplications['phone'].Alerts = Config.PhoneApplications['phone'].Alerts + 1
    SendNUIMessage({
        action = 'RefreshAppAlerts',
        AppData = Config.PhoneApplications
    })
end)

RegisterNetEvent('qb-phone-new:client:BankNotify', function(text)
    SendNUIMessage({
        action = 'PhoneNotification',
        NotifyData = {
            title = 'Bank',
            content = text,
            icon = 'fas fa-university',
            timeout = 3500,
            color = '#ff002f',
        },
    })
end)

RegisterNetEvent('qb-phone:client:NewMailNotify', function(MailData)
    SendNUIMessage({
        action = 'PhoneNotification',
        PhoneNotify = {
            title = 'Mail',
            text = 'U ontving een nieuwe mail van ' .. MailData.sender,
            icon = 'fas fa-envelope',
            color = '#ff002f',
            timeout = 1500,
        },
    })
    Config.PhoneApplications['mail'].Alerts = Config.PhoneApplications['mail'].Alerts + 1
    TriggerServerEvent('qb-phone:server:SetPhoneAlerts', 'mail')
end)

RegisterNetEvent('qb-phone:client:UpdateMails', function(NewMails)
    SendNUIMessage({
        action = 'UpdateMails',
        Mails = NewMails
    })
    PhoneData.Mails = NewMails
end)

RegisterNetEvent('qb-phone:client:BillingEmail', function(data, paid, name)
    if paid then
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = 'Factureringsafdeling',
            subject = 'factuur betaald',
            message = 'Factuur is betaald ' .. name .. ' In het aantal van €' .. data.amount,
        })
    else
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = 'Factureringsafdeling',
            subject = 'Factuur daalde',
            message = 'Factuur is afgewezen ' .. name .. ' In het aantal van €' .. data.amount,
        })
    end
end)

RegisterNUICallback('DoPing', function(data, cb)
    local playerNumber = tonumber(data.PlayerNumber)
    TriggerEvent('phone-ping:client:DoPing', playerNumber)
    cb('ok')
end)

RegisterNetEvent('qb-phone:client:CancelCall', function()
    if PhoneData.CallData.CallType == 'ongoing' then
        SendNUIMessage({
            action = 'CancelOngoingCall'
        })
        exports['pma-voice']:removePlayerFromCall(PhoneData.CallData.CallId)
    end
    PhoneData.CallData.CallType = nil
    PhoneData.CallData.InCall = false
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = {}

    if not PhoneData.isOpen then
        StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        deletePhone()
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    end

    TriggerServerEvent('qb-phone:server:SetCallState', false)

    if not PhoneData.isOpen then
        SendNUIMessage({
            action = 'PhoneNotification',
            NotifyData = {
                title = 'Telefoon',
                content = 'De oproep is beëindigd',
                icon = 'fas fa-phone',
                timeout = 3500,
                color = '#e84118',
            },
        })
    else
        SendNUIMessage({
            action = 'PhoneNotification',
            PhoneNotify = {
                title = 'Telefoon',
                text = 'De oproep is beëindigd',
                icon = 'fas fa-phone',
                color = '#e84118',
            },
        })

        SendNUIMessage({
            action = 'SetupHomeCall',
            CallData = PhoneData.CallData,
        })

        SendNUIMessage({
            action = 'CancelOutgoingCall',
        })
    end
end)

RegisterNetEvent('qb-phone:client:GetCalled', function(CallerNumber, CallId, AnonymousCall)
    local RepeatCount = 0
    local CallData = {
        number = CallerNumber,
        name = IsNumberInContacts(CallerNumber),
        anonymous = AnonymousCall
    }

    if AnonymousCall then
        CallData.name = 'Anonymous'
    end

    PhoneData.CallData.CallType = 'incoming'
    PhoneData.CallData.InCall = true
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = CallData
    PhoneData.CallData.CallId = CallId

    TriggerServerEvent('qb-phone:server:SetCallState', true)

    SendNUIMessage({
        action = 'SetupHomeCall',
        CallData = PhoneData.CallData,
    })

    for _ = 1, Config.CallRepeats + 1, 1 do
        if not PhoneData.CallData.AnsweredCall then
            if RepeatCount + 1 ~= Config.CallRepeats + 1 then
                if PhoneData.CallData.InCall then
                    QBCore.Functions.TriggerCallback('qb-phone:server:HasPhone', function(HasPhone)
                        if HasPhone then
                            RepeatCount = RepeatCount + 1
                            local muteState = PhoneData.isMute
                            if muteState then
                                startRingtone(Config.ringtoneFile.muted)
                            else
                                startRingtone(Config.ringtoneFile.sound)
                            end

                            if not PhoneData.isOpen then
                                SendNUIMessage({
                                    action = 'IncomingCallAlert',
                                    CallData = PhoneData.CallData.TargetData,
                                    Canceled = false,
                                    AnonymousCall = AnonymousCall,
                                })
                            end
                        end
                    end)
                else
                    SendNUIMessage({
                        action = 'IncomingCallAlert',
                        CallData = PhoneData.CallData.TargetData,
                        Canceled = true,
                        AnonymousCall = AnonymousCall,
                    })
                    TriggerServerEvent('qb-phone:server:AddRecentCall', 'missed', CallData)
                    break
                end
                Wait(Config.RepeatTimeout)
            else
                SendNUIMessage({
                    action = 'IncomingCallAlert',
                    CallData = PhoneData.CallData.TargetData,
                    Canceled = true,
                    AnonymousCall = AnonymousCall,
                })
                TriggerServerEvent('qb-phone:server:AddRecentCall', 'missed', CallData)
                break
            end
        else
            TriggerServerEvent('qb-phone:server:AddRecentCall', 'missed', CallData)
            break
        end
    end
end)

RegisterNetEvent('qb-phone:client:UpdateMessages', function(ChatMessages, SenderNumber, New)
    local NumberKey = GetKeyByNumber(SenderNumber)

    if New then
        PhoneData.Chats[#PhoneData.Chats + 1] = {
            name = IsNumberInContacts(SenderNumber),
            number = SenderNumber,
            messages = {},
        }

        NumberKey = GetKeyByNumber(SenderNumber)

        PhoneData.Chats[NumberKey] = {
            name = IsNumberInContacts(SenderNumber),
            number = SenderNumber,
            messages = ChatMessages
        }

        if PhoneData.Chats[NumberKey].Unread ~= nil then
            PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + 1
        else
            PhoneData.Chats[NumberKey].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = 'PhoneNotification',
                    PhoneNotify = {
                        title = 'Berichten',
                        text = 'Nieuw bericht van ' .. IsNumberInContacts(SenderNumber) .. '!',
                        icon = 'fab fa-messageapp',
                        color = '#25D366',
                        timeout = 1500,
                    },
                })
            else
                SendNUIMessage({
                    action = 'PhoneNotification',
                    PhoneNotify = {
                        title = 'Berichten',
                        text = 'Stalde uzelf in een bericht',
                        icon = 'fab fa-messageapp',
                        color = '#25D366',
                        timeout = 4000,
                    },
                })
            end

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Wait(100)
            QBCore.Functions.TriggerCallback('qb-phone:server:GetContactPictures', function(Chats)
                SendNUIMessage({
                    action = 'UpdateChat',
                    chatData = Chats[GetKeyByNumber(SenderNumber)],
                    chatNumber = SenderNumber,
                    Chats = Chats,
                })
            end, PhoneData.Chats)
        else
            SendNUIMessage({
                action = 'PhoneNotification',
                PhoneNotify = {
                    title = 'messageapp',
                    text = 'Nieuw bericht van ' .. IsNumberInContacts(SenderNumber) .. '!',
                    icon = 'fab fa-messageapp',
                    color = '#25D366',
                    timeout = 3500,
                },
            })
            Config.PhoneApplications['messageapp'].Alerts = Config.PhoneApplications['messageapp'].Alerts + 1
            TriggerServerEvent('qb-phone:server:SetPhoneAlerts', 'messageapp')
        end
    else
        PhoneData.Chats[NumberKey].messages = ChatMessages

        if PhoneData.Chats[NumberKey].Unread ~= nil then
            PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + 1
        else
            PhoneData.Chats[NumberKey].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = 'PhoneNotification',
                    PhoneNotify = {
                        title = 'Berichten',
                        text = 'Nieuw bericht van ' .. IsNumberInContacts(SenderNumber) .. '!',
                        icon = 'fab fa-messageapp',
                        color = '#25D366',
                        timeout = 1500,
                    },
                })
            else
                SendNUIMessage({
                    action = 'PhoneNotification',
                    PhoneNotify = {
                        title = 'Berichten',
                        text = 'Je schreef je zelf een bericht',
                        icon = 'fab fa-messageapp',
                        color = '#25D366',
                        timeout = 4000,
                    },
                })
            end

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Wait(100)
            QBCore.Functions.TriggerCallback('qb-phone:server:GetContactPictures', function(Chats)
                SendNUIMessage({
                    action = 'UpdateChat',
                    chatData = Chats[GetKeyByNumber(SenderNumber)],
                    chatNumber = SenderNumber,
                    Chats = Chats,
                })
            end, PhoneData.Chats)
        else
            SendNUIMessage({
                action = 'PhoneNotification',
                PhoneNotify = {
                    title = 'Berichten',
                    text = 'Nieuw bericht uit ' .. IsNumberInContacts(SenderNumber) .. '!',
                    icon = 'fab fa-messageapp',
                    color = '#25D366',
                    timeout = 3500,
                },
            })

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Config.PhoneApplications['messageapp'].Alerts = Config.PhoneApplications['messageapp'].Alerts + 1
            TriggerServerEvent('qb-phone:server:SetPhoneAlerts', 'messageapp')
        end
    end
end)

RegisterNetEvent('qb-phone:client:RemoveBankMoney', function(amount)
    if amount > 0 then
        SendNUIMessage({
            action = 'PhoneNotification',
            PhoneNotify = {
                title = 'Bank',
                text = '€' .. amount .. ' is uit uw saldo verwijderd!',
                icon = 'fas fa-university',
                color = '#ff002f',
                timeout = 3500,
            },
        })
    end
end)

RegisterNetEvent('qb-phone:RefreshPhone', function()
    LoadPhone()
    SetTimeout(250, function()
        SendNUIMessage({
            action = 'RefreshAlerts',
            AppData = Config.PhoneApplications,
        })
    end)
end)

RegisterNetEvent('qb-phone:client:AddTransaction', function(_, _, Message, Title)
    local Data = {
        TransactionTitle = Title,
        TransactionMessage = Message,
    }
    PhoneData.CryptoTransactions[#PhoneData.CryptoTransactions + 1] = Data
    SendNUIMessage({
        action = 'PhoneNotification',
        PhoneNotify = {
            title = 'Crypto',
            text = Message,
            icon = 'fas fa-chart-pie',
            color = '#04b543',
            timeout = 1500,
        },
    })
    SendNUIMessage({
        action = 'UpdateTransactions',
        CryptoTransactions = PhoneData.CryptoTransactions
    })

    TriggerServerEvent('qb-phone:server:AddTransaction', Data)
end)

RegisterNetEvent('qb-phone:client:AddNewSuggestion', function(SuggestionData)
    PhoneData.SuggestedContacts[#PhoneData.SuggestedContacts + 1] = SuggestionData
    SendNUIMessage({
        action = 'PhoneNotification',
        PhoneNotify = {
            title = 'Telefoon',
            text = 'U hebt een nieuw voorgesteld contact!',
            icon = 'fa fa-phone-alt',
            color = '#04b543',
            timeout = 1500,
        },
    })
    Config.PhoneApplications['phone'].Alerts = Config.PhoneApplications['phone'].Alerts + 1
    TriggerServerEvent('qb-phone:server:SetPhoneAlerts', 'phone', Config.PhoneApplications['phone'].Alerts)
end)

RegisterNetEvent('qb-phone:client:UpdateHashtags', function(Handle, msgData)
    if PhoneData.Hashtags[Handle] ~= nil then
        PhoneData.Hashtags[Handle].messages[#PhoneData.Hashtags[Handle].messages + 1] = msgData
    else
        PhoneData.Hashtags[Handle] = {
            hashtag = Handle,
            messages = {}
        }
        PhoneData.Hashtags[Handle].messages[#PhoneData.Hashtags[Handle].messages + 1] = msgData
    end

    SendNUIMessage({
        action = 'UpdateHashtags',
        Hashtags = PhoneData.Hashtags,
    })
end)

RegisterNetEvent('qb-phone:client:AnswerCall', function()
    stopRingtone()
    if (PhoneData.CallData.CallType == 'incoming' or PhoneData.CallData.CallType == 'outgoing') and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = 'ongoing'
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0

        SendNUIMessage({ action = 'AnswerCall', CallData = PhoneData.CallData })
        SendNUIMessage({ action = 'SetupHomeCall', CallData = PhoneData.CallData })

        TriggerServerEvent('qb-phone:server:SetCallState', true)

        if PhoneData.isOpen then
            DoPhoneAnimation('cellphone_text_to_call')
        else
            DoPhoneAnimation('cellphone_call_listen_base')
        end

        CreateThread(function()
            while true do
                if PhoneData.CallData.AnsweredCall then
                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                    SendNUIMessage({
                        action = 'UpdateCallTime',
                        Time = PhoneData.CallData.CallTime,
                        Name = PhoneData.CallData.TargetData.name,
                    })
                else
                    break
                end

                Wait(1000)
            end
        end)
        exports['pma-voice']:addPlayerToCall(PhoneData.CallData.CallId)
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        SendNUIMessage({
            action = 'PhoneNotification',
            PhoneNotify = {
                title = 'Telefoon',
                text = "Je hebt geen inkomende oproep..",
                icon = 'fas fa-phone',
                color = '#e84118',
            },
        })
    end
end)

RegisterNetEvent('qb-phone:client:addPoliceAlert', function(alertData)
    PlayerJob = QBCore.Functions.GetPlayerData().job
    if PlayerJob.name == ('police' or 'sasp') and PlayerJob.onduty then
        SendNUIMessage({
            action = 'AddPoliceAlert',
            alert = alertData,
        })
    end
end)

RegisterNetEvent('qb-phone:client:GiveContactDetails', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local PlayerId = GetPlayerServerId(player)
        TriggerServerEvent('qb-phone:server:GiveContactDetails', PlayerId)
    else
        QBCore.Functions.Notify('Niemand in de buurt!', 'error')
    end
end)

RegisterNetEvent('qb-phone:client:UpdateLapraces', function()
    SendNUIMessage({
        action = 'UpdateRacingApp',
    })
end)

RegisterNetEvent('qb-phone:client:GetMentioned', function(TweetMessage, AppAlerts)
    Config.PhoneApplications['Twatter'].Alerts = AppAlerts
    SendNUIMessage({ action = 'PhoneNotification', PhoneNotify = { title = 'Je bent genoemd in een Twat!', text = TweetMessage.message, icon = 'fab fa-twitter', color = '#1DA1F2', }, })
    TweetMessage = { firstName = TweetMessage.firstName, lastName = TweetMessage.lastName, message = escape_str(TweetMessage.message), time = TweetMessage.time, picture = TweetMessage.picture }
    PhoneData.MentionedTweets[#PhoneData.MentionedTweets + 1] = TweetMessage
    SendNUIMessage({ action = 'RefreshAppAlerts', AppData = Config.PhoneApplications })
    SendNUIMessage({ action = 'UpdateMentionedTweets', Tweets = PhoneData.MentionedTweets })
end)

RegisterNetEvent('qb-phone:refreshImages', function(images)
    PhoneData.Images = images
end)

RegisterNetEvent('qb-phone:client:CustomNotification', function(title, text, icon, color, timeout) -- Send a PhoneNotification to the phone from anywhere
    SendNUIMessage({
        action = 'PhoneNotification',
        PhoneNotify = {
            title = title,
            text = text,
            icon = icon,
            color = color,
            timeout = timeout,
        },
    })
end)

-- Track car
local TrackingCar, CurrentCarBlip, CurrentVehcile, driver, InVehicleCheck = false, nil, nil, nil, false
local onTheWay = false
local ValetTime = false

RegisterNUICallback('GetCar', function(data)
    local plate = data.profilepicture
    local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 70.5, 75.0, 0.0)
    if onTheWay then
        TriggerEvent('qb-phone:client:GarageNotify', "Er is al een wagen onder weg", 2000)
        return
    end
    if ValetTime then
        TriggerEvent('qb-phone:client:GarageNotify', "U kunt een tijdje niet profiteren van valetservice", 2000)
        return
    end
    QBCore.Functions.TriggerCallback('qb-phone:server:GetInvoicesAll', function(invoice)
        local invoicesamount = 0
        for k, v in pairs(invoice) do
            invoicesamount = v.amount
        end
        if invoicesamount < 1000 then
            onTheWay = true
            QBCore.Functions.TriggerCallback('qb-phone:server:GetVehicleByPlate', function(result)
                for k, v in pairs(result) do
                    if v.state == 1 then
                        TriggerEvent('qb-phone:client:GarageNotify', "Uw auto is afgeleverd bij de parkeerservice en zal binnenkort hier zijn", 2000)
                        Citizen.Wait(1000)
                        local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(coords.x + math.random(-40.0, 40.0), coords.y + math.random(-40.0, 40.0), coords.z, 0, 3, 0)
                        local driverhash = GetHashKey('ig_andreas')
                        while not HasModelLoaded(driverhash) and RequestModel(driverhash) do
                            RequestModel(driverhash)
                            Citizen.Wait(0)
                        end
                        local veh = QBCore.Functions.SpawnVehicle(v.vehicle, true, vec4(spawnPos.x, spawnPos.y, spawnPos.z, spawnHeading), true, false)
                        if veh then
                            CurrentVehcile = veh
                            QBCore.Functions.TriggerCallback('qb-garage:server:GetVehicleProperties', function(properties)
                                QBCore.Functions.SetVehicleProperties(veh, properties)
                                SetVehicleNumberPlateText(veh, v.plate)
                                exports['cdn-fuel']:SetFuel(veh, v.fuel)
                                SetEntityAsMissionEntity(veh, true, true)
                                TriggerServerEvent('qb-garage:server:updateVehicleState', 0, v.plate, "Out")
                                exports['dusa_vehiclekeys']:AddKey(v.plate)
                                SetVehicleEngineOn(veh, true, true)
                                driver = CreatePedInsideVehicle(veh, 26, driverhash, -1, true, false) 
                                CurrentCarBlip = AddBlipForEntity(veh)
                                SetBlipSprite(CurrentCarBlip, 225)
                                SetBlipFlashes(CurrentCarBlip, true) 
                                SetBlipColour(CurrentCarBlip, 0) 
                                Citizen.Wait(5000)
                                SetBlipFlashes(CurrentCarBlip, false)  
                                ClearAreaOfVehicles(GetEntityCoords(veh), 5000, false, false, false, false, false);  
                                SetVehicleOnGroundProperly(veh)
                                TrackingCar = true
                                VehcileTask(veh, v.vehicle)
                            end, v.plate)

                            doCarDamage(veh, v)
                            onTheWay = false
                            TriggerServerEvent('qb-phone:server:GiveInvoice')

                            ValetTime = true
                            InVehicleCheck = true
                            while InVehicleCheck do
                                Citizen.Wait(500)
                                if IsPedInVehicle(PlayerPedId(), CurrentVehcile, true) then
                                    RemoveBlip(CurrentCarBlip)
                                    InVehicleCheck = false
                                end
                            end
                            Citizen.Wait(32000)
                            ValetTime = false
                        end
                    elseif v.state == 0 then
                        TriggerEvent('qb-phone:client:GarageNotify', "De locatie van het voertuig dat zich al buiten bevindt, is gemarkeerd", 2000)
                        findVehFromPlateAndLocate(v.plate)
                        onTheWay = false
                        ValetTime = false
                    else
                        TriggerEvent('qb-phone:client:GarageNotify', "Uw voertuig is weggesleept..", 2000)
                        onTheWay = false
                        ValetTime = false
                    end
                end
            end, plate)  
        else
            TriggerEvent('qb-phone:client:GarageNotify', "U heeft meer dan €1000 aan onbetaalde rekeningen, betaal ze eerst..", 3000)
        end
    end)
end)

function VehcileTask(vehicle, vehhash)
	while TrackingCar do
		Citizen.Wait(750)
		local pedcoords = GetEntityCoords(PlayerPedId())
		local plycoords = GetEntityCoords(driver)
		local dist = GetDistanceBetweenCoords(plycoords, pedcoords.x,pedcoords.y,pedcoords.z, false)
		
		if dist <= 25.0 then
			TaskVehicleDriveToCoord(driver, vehicle, pedcoords.x, pedcoords.y, pedcoords.z, 10.0, 1, vehhash, 395, 5.0, 1)
			SetVehicleFixed(vehicle)
			if dist <= 6.5 then
				DropCar(vehicle)
			else
				Citizen.Wait(500)
			end
		else
			TaskVehicleDriveToCoord(driver, vehicle, pedcoords.x, pedcoords.y, pedcoords.z, 15.0, 1, vehhash, 395, 5.0, 1)
			Citizen.Wait(500)
		end
	end
end

function DropCar(vehicle)
	TaskLeaveVehicle(driver, vehicle, 14)
	TrackingCar = false
	while IsPedInAnyVehicle(driver, false) do
		Citizen.Wait(0)
	end 
	
	Citizen.Wait(500)
	TaskWanderStandard(driver, 10.0, 10)
end

function findVehFromPlateAndLocate(plate)

    local gameVehicles = QBCore.Functions.GetVehicles()
  
    for i = 1, #gameVehicles do
        local vehicle = gameVehicles[i]

        if DoesEntityExist(vehicle) then
            if GetVehicleNumberPlateText(vehicle) == plate then
                local vehCoords = GetEntityCoords(vehicle)
                SetNewWaypoint(vehCoords.x, vehCoords.y)
                return true
            end
        end
    end
end

RegisterNetEvent('qb-phone:client:GarageNotify', function(text, timeoutt)
    SendNUIMessage({
        action = "PhoneNotification",
        PhoneNotify = {
            title = "Garage",
            text = text,
            icon = "fas fa-warehouse",
            color = "#ff002f",
            timeout = timeoutt,
        },
    })
end)

function doCarDamage(currentVehicle, veh)
	smash = false
	damageOutside = false
	damageOutside2 = false
	local engine = veh.engine + 0.0
	local body = veh.body + 0.0
	if engine < 200.0 then
		engine = 200.0
    end

    if engine > 1000.0 then
        engine = 1000.0
    end

	if body < 150.0 then
		body = 150.0
	end
	if body < 900.0 then
		smash = true
	end

	if body < 800.0 then
		damageOutside = true
	end

	if body < 500.0 then
		damageOutside2 = true
	end

    Wait(100)
    SetVehicleEngineHealth(currentVehicle, engine)
	if smash then
		SmashVehicleWindow(currentVehicle, 0)
		SmashVehicleWindow(currentVehicle, 1)
		SmashVehicleWindow(currentVehicle, 2)
		SmashVehicleWindow(currentVehicle, 3)
		SmashVehicleWindow(currentVehicle, 4)
	end
	if damageOutside then
		SetVehicleDoorBroken(currentVehicle, 1, true)
		SetVehicleDoorBroken(currentVehicle, 6, true)
		SetVehicleDoorBroken(currentVehicle, 4, true)
	end
	if damageOutside2 then
		SetVehicleTyreBurst(currentVehicle, 1, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 2, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 3, false, 990.0)
		SetVehicleTyreBurst(currentVehicle, 4, false, 990.0)
	end
	if body < 1000 then
		SetVehicleBodyHealth(currentVehicle, 985.1)
	end
end

-- Threads

CreateThread(function()
    Wait(500)
    LoadPhone()
end)

CreateThread(function()
    while true do
        if PhoneData.isOpen then
            SendNUIMessage({
                action = 'UpdateTime',
                InGameTime = CalculateTimeToDisplay(),
            })
        end
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        Wait(60000)
        if LocalPlayer.state.isLoggedIn then
            QBCore.Functions.TriggerCallback('qb-phone:server:GetPhoneData', function(pData)
                if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then
                    PhoneData.Contacts = pData.PlayerContacts
                end
                SendNUIMessage({
                    action = 'RefreshContacts',
                    Contacts = PhoneData.Contacts
                })
            end)
        end
    end
end)

-- Ringtone
function startRingtone(link)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local serverId = GetPlayerServerId(PlayerId())
    local ringToneId = tostring(serverId)

    if ringtoneOn then
        TriggerServerEvent("qb-phone:server:stopRingtone", ringToneId)
        ringtoneOn = false
    end

    if #ringToneList <= 99 then

        TriggerServerEvent("qb-phone:server:playRingtone", pos, ringToneId, link, serverId, true)
        ringtoneOn = true
    else
        print('error 404.')
    end
end
exports('startRingtone', startRingtone)

RegisterNetEvent('qb-phone:client:playRingtone')
AddEventHandler('qb-phone:client:playRingtone', function(pos, ringToneId, link, serverId, mp3)
    if tostring(GetPlayerServerId(PlayerId())) ~= musicName then
        ringToneList[ringToneId] = {}
        ringToneList[ringToneId]["stop"] = false
        ringToneList[ringToneId]["serverId"] = serverId
        ringToneList[ringToneId]["mp3"] = mp3

        if mp3 then
            xSound:PlayUrlPos(ringToneId, link, 0.2, pos)
            xSound:setVolumeMax(ringToneId, 0.2)
            xSound:Distance(ringToneId, 10)
        else
            xSound:PlayUrlPos(ringToneId, link, 0.3, pos)
            xSound:setVolumeMax(ringToneId, 0.3)
            xSound:Distance(ringToneId, 3)
        end
    end
end)

function pauseRingtone(link)
    if ringtoneOn then
        ringtoneOn = false
        TriggerServerEvent("qb-phone:server:pauseRingtone", tostring(GetPlayerServerId(PlayerId())))
    end
end
exports('pauseRingtone', pauseRingtone)

RegisterNetEvent('qb-phone:client:pauseRingtone')
AddEventHandler('qb-phone:client:pauseRingtone', function(ringToneId)
    if GetPlayerServerId(PlayerId()) ~= ringToneId then
        ringToneList[ringToneId] = nil
        xSound:Destroy(ringToneId)
    end
end)

function stopRingtone()
    local myId = tostring(GetPlayerServerId(PlayerId()))
    TriggerServerEvent("stopmusic", myId)
end
exports('stopRingtone', stopRingtone)

RegisterNetEvent('qb-phone:client:stopRingtone')
AddEventHandler('qb-phone:client:stopRingtone', function(ringToneId)
    if tostring(GetPlayerServerId(PlayerId())) ~= ringToneId then
        if ringToneList[ringToneId] == nil then return end
        if ringToneList[ringToneId]["stop"] == nil then return end
        if ringToneList[ringToneId]["stop"] == false then
            ringToneList[ringToneId]["stop"] = true
            -- xSound:Pause(ringToneId)
            xSound:Destroy(ringToneId)
        end
    end
end)

function continueRingtone(link)
    local myId = tostring(GetPlayerServerId(PlayerId()))
    TriggerServerEvent("musiccontinue", myId)
end
exports('continueRingtone', continueRingtone)

RegisterNetEvent('qb-phone:client:continueRingtone')
AddEventHandler('qb-phone:client:continueRingtone', function(ringToneId)
    if tostring(GetPlayerServerId(PlayerId())) ~= ringToneId then
        if ringToneList[ringToneId]["continue"] == true then
            ringToneList[ringToneId]["continue"] = false
            xSound:Resume(ringToneId)
        end
    end
end)

local time = 100
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(time)

        for x, y in pairs(ringToneList) do
            local player = GetPlayerFromServerId(ringToneList[x]["serverId"])
            if player ~= -1 then
                local ped = GetPlayerPed(player)
                local coords = GetEntityCoords(ped)
                local playercoords = GetEntityCoords(PlayerPedId())
                if ped == nil or coords == nil or playercoords == nil then return end
                local mesafe = #(playercoords - coords)
                if mesafe < 200 then
                    time = 100
                    if x then
                        if not xSound:soundExists(x) then
                            xSound:Position(x, coords)
                        end
                    end
                    if ringToneList[x]["mp3"] then
                        if IsPedInAnyVehicle(ped, true) == 1 then
                            local vehicle = GetVehiclePedIsIn(ped, false)
                            if GetEntitySpeed(vehicle) * 3.6 > 200.0 then
                                xSound:Distance(x, 140)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 150.0 then
                                xSound:Distance(x, 125)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 110.0 then
                                xSound:Distance(x, 100)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 90.0 then
                                xSound:Distance(x, 80)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 60.0 then
                                xSound:Distance(x, 65)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 30.0 then
                                xSound:Distance(x, 40)
                            else
                                xSound:Distance(x, 25)
                            end
                        else
                            xSound:Distance(x, 10)
                        end
                    else
                        if IsPedInAnyVehicle(ped, true) == 1 then
                            local vehicle = GetVehiclePedIsIn(ped, false)
                            if GetEntitySpeed(vehicle) * 3.6 > 200.0 then
                                xSound:Distance(x, 140)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 150.0 then
                                xSound:Distance(x, 125)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 110.0 then
                                xSound:Distance(x, 100)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 90.0 then
                                xSound:Distance(x, 80)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 60.0 then
                                xSound:Distance(x, 65)
                            elseif GetEntitySpeed(vehicle) * 3.6 > 30.0 then
                                xSound:Distance(x, 40)
                            else
                                xSound:Distance(x, 25)
                            end
                        else
                            xSound:Distance(x, 15)
                        end
                    end

                else
                    time = 2000
                    if x ~= nil and coords ~= nil then
                        if not xSound:soundExists(x) then
                            xSound:Position(x, coords)
                        end
                    end
                end
            else
                local ringToneId = tostring(ringToneList[x]["serverId"])
                ringToneList[ringToneId] = nil
                xSound:Destroy(ringToneId)
            end
        end
    end
end)


------ Phone adversts

RegisterNUICallback('GetAdverts', function(_, cb)
    cb(PhoneData.Adverts)
end)

RegisterNUICallback('PostNewAdvert', function(data, cb)
    local AdvertMessage = {
        firstName = PhoneData.PlayerData.charinfo.firstname,
        lastName = PhoneData.PlayerData.charinfo.lastname,
        citizenid = PhoneData.PlayerData.citizenid,
        message = escape_str(data.Message),
        time = data.Date,
        AdsId = GenerateAdsId(),
        picture = data.Picture,
        url = data.url
    }

    table.insert(PhoneData.Adverts, AdvertMessage)
    Wait(100)
    cb(PhoneData.Adverts)

    TriggerServerEvent('qb-phone:server:UpdateAdverts', PhoneData.Adverts, AdvertMessage)
end)

RegisterNUICallback('DeleteAds', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-phone:server:CanDeleteAdvert', function(status)
        if status then
            TriggerServerEvent('qb-phone:server:DeleteAdvert', data.id)
        end
        cb(status)
    end, data.id)
end)

RegisterNetEvent('qb-phone:client:UpdateAdverts', function(player, Adverts, NewAdvertData, delete)
    PhoneData.Adverts = Adverts
    local MyPlayerId = PhoneData.PlayerData.source
    if delete then -- New Advert
        if player == MyPlayerId then
            SendNUIMessage({
                action = 'PhoneNotification',
                PhoneNotify = {
                    title = 'Advertenties',
                    text = 'The Advert has been deleted!',
                    icon = 'fas fa-file',
                    color = '#f99a1a',
                    timeout = 1000,
                },
            })
        end
    else
        if NewAdvertData then
            if player ~= MyPlayerId then
                SendNUIMessage({
                    action = 'PhoneNotification',
                    PhoneNotify = {
                        title = 'New Advert (@' .. NewAdvertData.firstName .. ' ' .. NewAdvertData.lastName .. ')',
                        text = 'A new Advert as been posted.',
                        icon = 'fas fa-file',
                        color = '#f99a1a',
                    },
                })
            else
                SendNUIMessage({
                    action = 'PhoneNotification',
                    PhoneNotify = {
                        title = 'Advertenties',
                        text = 'The Advert has been posted!',
                        icon = 'fas fa-file',
                        color = '#f99a1a',
                        timeout = 1000,
                    },
                })
            end
        end
    end
    SendNUIMessage({
        action = 'RefreshAdverts',
        Adverts = Adverts
    })
end)