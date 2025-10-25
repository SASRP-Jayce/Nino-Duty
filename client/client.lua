local onDuty = false
local currentDept = nil
local playerName = nil
local playerCallsign = nil
local playerBlip = nil
local dutyStartTime = 0

CreateThread(function()
    local ped = PlayerPedId()
    local blip = GetBlipFromEntity(ped)
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end)

local function formatTime(ms)
    local total = math.floor(ms / 1000)
    local h = math.floor(total / 3600)
    local m = math.floor((total % 3600) / 60)
    local s = total % 60
    return string.format('%d:%02d:%02d', h, m, s)
end

local function dutyNotify(title, desc, typ)
    lib.notify({
        title = title,
        description = desc,
        type = typ or 'inform',
        position = 'top',
        duration = 5000,
        icon = 'fa-solid fa-shield-halved',
        iconColor = '#1E90FF',
        style = {
            backgroundColor = 'rgba(0, 0, 0, 0.7)'
        }
    })
end

local function giveDutyWeapons()
    local ped = PlayerPedId()
    for _, weapon in ipairs(Config.DutyWeapons) do
        local hash = GetHashKey(weapon)
        if not HasPedGotWeapon(ped, hash, false) then
            GiveWeaponToPed(ped, hash, 250, false, true)
        end
    end
    for weapon, components in pairs(Config.WeaponAttachments) do
        local hash = GetHashKey(weapon)
        if HasPedGotWeapon(ped, hash, false) then
            for _, component in ipairs(components) do
                local compHash = GetHashKey(component)
                if not HasPedGotWeaponComponent(ped, hash, compHash) then
                    GiveWeaponComponentToPed(ped, hash, compHash)
                end
            end
        end
    end
end

local function removeDutyWeapons()
    local ped = PlayerPedId()
    for _, weapon in ipairs(Config.DutyWeapons) do
        local hash = GetHashKey(weapon)
        if HasPedGotWeapon(ped, hash, false) then
            RemoveWeaponFromPed(ped, hash)
        end
    end
end

RegisterCommand('duty', function()
    TriggerServerEvent('nino-duty:requestDepts')
end, false)

RegisterNetEvent('nino-duty:receiveDepts')
AddEventHandler('nino-duty:receiveDepts', function(depts)
    if #depts == 0 then
        dutyNotify('Nino-Duty', 'No department access', 'error')
        return
    end

    if onDuty then
        TriggerServerEvent('nino-duty:offDuty')
        return
    end

    local input = lib.inputDialog('Duty Selection', {
        { type = 'input', label = 'Name (e.g. D. Brown)', required = true },
        { type = 'input', label = 'Callsign (e.g. ! 201)', required = true },
        { type = 'select', label = 'Department', options = depts, required = true }
    }, { allowCancel = true })

    if not input then
        dutyNotify('Nino-Duty', 'Shift cancelled', 'error')
        return
    end

    local name, callsign, deptShort = input[1], input[2], input[3]
    if name == '' or callsign == '' or deptShort == '' then
        dutyNotify('Nino-Duty', 'All fields required', 'error')
        return
    end

    TriggerServerEvent('nino-duty:onDuty', name, callsign, deptShort)
end)

local function updatePlayerBlip()
    local ped = PlayerPedId()
    local color = Config.Departments[currentDept] and Config.Departments[currentDept].color or 1
    print('Blip color set to: ' .. color)

    local existingBlip = GetBlipFromEntity(ped)
    while existingBlip and DoesBlipExist(existingBlip) do
        RemoveBlip(existingBlip)
        existingBlip = GetBlipFromEntity(ped)
    end

    playerBlip = AddBlipForEntity(ped)
    SetBlipSprite(playerBlip, 1) -- Circle blip
    SetBlipScale(playerBlip, 0.8)
    SetBlipAsShortRange(playerBlip, false)
    ShowHeadingIndicatorOnBlip(playerBlip, true)
    SetBlipColour(playerBlip, color)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(playerCallsign .. ' | ' .. playerName)
    EndTextCommandSetBlipName(playerBlip)
end

local function removePlayerBlip()
    local ped = PlayerPedId()
    local blip = GetBlipFromEntity(ped)
    while blip and DoesBlipExist(blip) do
        RemoveBlip(blip)
        blip = GetBlipFromEntity(ped)
    end
    playerBlip = nil
end

RegisterNetEvent('nino-duty:onDutySuccess')
AddEventHandler('nino-duty:onDutySuccess', function(deptLong, name, callsign, deptShort)
    onDuty = true
    currentDept = deptShort
    playerName = name
    playerCallsign = callsign
    dutyStartTime = GetGameTimer()

    giveDutyWeapons()
    dutyNotify('Nino-Duty', 'On duty as ' .. deptLong, 'success')
    updatePlayerBlip()

    SendNUIMessage({
        type = 'showBodycam',
        name = name,
        callsign = callsign,
        department = deptShort,
        timestamp = math.floor(GetGameTimer() / 1000)
    })
end)

RegisterNetEvent('nino-duty:offDutySuccess')
AddEventHandler('nino-duty:offDutySuccess', function(timeStr)
    onDuty = false
    currentDept = nil
    playerName = nil
    playerCallsign = nil
    dutyStartTime = 0

    removeDutyWeapons()
    dutyNotify('Nino-Duty', 'Off duty – ' .. timeStr, 'error')
    removePlayerBlip()

    SendNUIMessage({
        type = 'removeBodycam'
    })
end)

CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local blip = GetBlipFromEntity(ped)
        if onDuty then
            if not playerBlip or not DoesBlipExist(playerBlip) then
                updatePlayerBlip()
            else
                SetBlipColour(playerBlip, Config.Departments[currentDept] and Config.Departments[currentDept].color or 1)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString(playerCallsign .. ' | ' .. playerName)
                EndTextCommandSetBlipName(playerBlip)
            end
        else
            if blip and DoesBlipExist(blip) then
                removePlayerBlip()
            end
        end
    end
end)