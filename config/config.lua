Config = {}

Config.GlobalAce = 'duty.all'

Config.Departments = {
    {
        name = 'BCSO',
        longname = 'Blaine County Sheriff\'s Office',
        ace = 'duty.BCSO',
        color = 47, -- Orange
        webhook = 'YOUR_BCSO_WEBHOOK_URL_HERE'
    },
    {
        name = 'SAST',
        longname = 'San Andreas State Troopers',
        ace = 'duty.SAST',
        color = 5, -- Yellow
        webhook = 'YOUR_SAHP_WEBHOOK_URL_HERE'
    },
    {
        name = 'LSPD',
        longname = 'Los Santos Police Department',
        ace = 'duty.LSPD',
        color = 4, -- Blue
        webhook = 'YOUR_LSPD_WEBHOOK_URL_HERE'
    },
    {
        name = 'DOHS',
        longname = 'Department Of Homefront Security',
        ace = 'duty.DOHS',
        color = 40, -- Black
        webhook = 'YOUR_LSPD_WEBHOOK_URL_HERE'
    },
    {
        name = 'SAFR',
        longname = 'San Andreas Fire & Rescue',
        ace = 'duty.SAFR',
        color = 66 , -- Red 
        webhook = 'YOUR_LSAFD_WEBHOOK_URL_HERE'
    }
}

Config.DutyWeapons = {
    'WEAPON_STUNGUN',
    'WEAPON_COMBATPISTOL',
    'WEAPON_CARBINERIFLE',
    'WEAPON_PUMPSHOTGUN',
    'WEAPON_NIGHTSTICK',
    'WEAPON_FLASHLIGHT'
}

Config.WeaponAttachments = {
    ['WEAPON_COMBATPISTOL'] = { 'COMPONENT_AT_PI_FLSH' },
    ['WEAPON_CARBINERIFLE'] = { 'COMPONENT_AT_AR_FLSH', 'COMPONENT_AT_SCOPE_MEDIUM', 'COMPONENT_AT_AR_AFGRIP' },
    ['WEAPON_PUMPSHOTGUN'] = { 'COMPONENT_AT_AR_FLSH' }
}