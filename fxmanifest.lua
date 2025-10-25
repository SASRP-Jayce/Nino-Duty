fx_version 'cerulean'
game 'gta5'

author 'Nino'
description 'Duty Menu Script'
version '1.0.0'

ui_page 'html/bodycam.html'

files {
    'html/bodycam.html'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua'
}

client_scripts {
    'client/client.lua',
    'html/global.css'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

escrow_ignore {
    'config/config.lua'
}

lua54 'yes'

dependencies {
    'ox_lib',
    'oxmysql',
    'Badger_Discord_API',
    'DiscordAcePerms'
}