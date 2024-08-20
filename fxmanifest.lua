-- FX Information
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'
author 'mjkv'
description 'mk-saloontender'
version '1.0.2'


shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locale.lua',
    'languages/*.lua'
}

client_script {
    'client/client.lua',
    'client/client_shop.lua',
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/server_shop.lua'
}

dependencies {
    'vorp_core',
    'vorp_animations',
    'ox_lib',
}
