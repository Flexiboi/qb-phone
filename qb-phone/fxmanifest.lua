fx_version 'bodacious'
game 'gta5'

description 'QB-Phone'
version '1.3.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua',
    -- '@qb-apartments/config.lua'
}

client_scripts {
    'client/ping.lua',
    'client/main.lua',
    'client/animation.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/ping.lua',
    'server/main.lua'
}

files {
    'html/*.html',
    'html/js/*.js',
    'html/img/*.png',
    'html/css/*.css',
    'html/img/backgrounds/*.png',
    'html/img/backgrounds/*.jpg',
    'html/img/apps/*.png',
}

lua54 'yes'
