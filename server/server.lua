local onDutyPlayers = {}

local function formatTime(ms)
    local total = math.floor(ms / 1000)
    local h = math.floor(total / 3600)
    local m = math.floor((total % 3600) / 60)
    local s = total % 60
    return string.format('%d:%02d:%02d', h, m, s)
end

local function sendWebhook(url, color, title, desc, fields)
    PerformHttpRequest(url, function() end, 'POST',
        json.encode({
            embeds = {{
                title = title,
                description = desc,
                color = color,
                thumbnail = { url = 'https://i.imgur.com/8zL9K7N.png' }, -- Example badge URL, replace with your own
                fields = fields,
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
            }}
        }),
        { ['Content-Type'] = 'application/json' })
end

local function getDiscordId(id)
    return string.match(id, "discord:(%d+)")
end

local function getDeptLong(short)
    for _, d in ipairs(Config.Departments) do
        if d.name == short then return d.longname end
    end
    return short
end

local function getWebhook(short)
    for _, d in ipairs(Config.Departments) do
        if d.name == short then return d.webhook end
    end
    return nil
end

local function getDeptColor(short)
    for _, d in ipairs(Config.Departments) do
        if d.name == short then return d.color end
    end
    return 1 -- Default to white if not found
end

RegisterNetEvent('nino-duty:requestDepts')
AddEventHandler('nino-duty:requestDepts', function()
    local src = source
    local depts = {}

    for _, dept in ipairs(Config.Departments) do
        local perm
        for _, p in pairs({[dept.name:lower()] = dept.ace}) do
            if p then
                perm = p
                break
            end
        end
        if (perm and IsPlayerAceAllowed(src, perm)) or IsPlayerAceAllowed(src, Config.GlobalAce) then
            table.insert(depts, { label = dept.longname, value = dept.name })
        end
    end

    TriggerClientEvent('nino-duty:receiveDepts', src, depts)
end)

RegisterNetEvent('nino-duty:onDuty')
AddEventHandler('nino-duty:onDuty', function(name, callsign, dept)
    local src = source
    if onDutyPlayers[src] then return end

    local license = GetPlayerIdentifierByType(src, 'license')
    local discord = getDiscordId(license)

    MySQL.insert('INSERT INTO nino_duty_logs (player_name, identifier, department, duty_start) VALUES (?, ?, ?, NOW())',
        { name, license, dept })

    onDutyPlayers[src] = { name = name, callsign = callsign, dept = dept, start = GetGameTimer() }
    TriggerClientEvent('nino-duty:onDutySuccess', src, getDeptLong(dept), name, callsign, dept)

    local wh = getWebhook(dept)
    if wh and wh ~= '' then
        local color = getDeptColor(dept)
        sendWebhook(wh, color, 'Duty Log', 'SpongeBob Duty System - ' .. os.date('%I:%M %p %Z - Today at %H:%M', os.time()),
            {
                { name = 'Name', value = name, inline = true },
                { name = 'Callsign', value = callsign, inline = true },
                { name = 'Department', value = getDeptLong(dept), inline = true },
                { name = 'Time On Duty', value = os.date('%I:%M %p - %d %b %Y', os.time()), inline = true },
                { name = 'Time Off Duty', value = 'N/A', inline = true },
                { name = 'Discord Check', value = discord and '<@'..discord..'>' or 'N/A', inline = true },
                { name = 'Role Verified', value = '✅', inline = true }
            })
    end
end)

RegisterNetEvent('nino-duty:offDuty')
AddEventHandler('nino-duty:offDuty', function()
    local src = source
    if not onDutyPlayers[src] then return end

    local data = onDutyPlayers[src]
    local elapsed = GetGameTimer() - data.start
    local timeStr = formatTime(elapsed)

    MySQL.update('UPDATE nino_duty_logs SET duty_end = NOW(), duty_time_secs = ? WHERE identifier = ? AND duty_end IS NULL',
        { elapsed / 1000, GetPlayerIdentifierByType(src, 'license') })

    onDutyPlayers[src] = nil
    TriggerClientEvent('nino-duty:offDutySuccess', src, timeStr)

    local wh = getWebhook(data.dept)
    if wh and wh ~= '' then
        local color = getDeptColor(data.dept)
        sendWebhook(wh, color, 'Duty Log', 'SpongeBob Duty System - ' .. os.date('%I:%M %p %Z - Today at %H:%M', os.time()),
            {
                { name = 'Name', value = data.name, inline = true },
                { name = 'Callsign', value = data.callsign, inline = true },
                { name = 'Department', value = getDeptLong(data.dept), inline = true },
                { name = 'Time On Duty', value = os.date('%I:%M %p - %d %b %Y', data.start / 1000), inline = true },
                { name = 'Time Off Duty', value = os.date('%I:%M %p - %d %b %Y', os.time()), inline = true },
                { name = 'Duty Duration', value = timeStr, inline = true },
                { name = 'Discord Check', value = getDiscordId(GetPlayerIdentifierByType(src, 'license')) and '<@'..getDiscordId(GetPlayerIdentifierByType(src, 'license'))..'>' or 'N/A', inline = true },
                { name = 'Role Verified', value = '✅', inline = true }
            })
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if onDutyPlayers[src] then
        TriggerEvent('nino-duty:offDuty')
    end
end)