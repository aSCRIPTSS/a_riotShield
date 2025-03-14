fx_version 'cerulean'
game 'gta5'

version '1.0.0'

lua54 'yes'

shared_script '@ox_lib/init.lua'


client_script {
    'client/*.lua',
    "client/*.meta"
}

server_script {
    '@oxmysql/lib/MySQL.lua'
}

files {
    'stream/balshields_props.ytyp',
}

data_file 'DLC_ITYP_REQUEST' 'stream/balshields_props.ytyp'
data_file "WEAPON_ANIMATIONS_FILE" "client/weaponanimations.meta"