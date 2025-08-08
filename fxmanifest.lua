fx_version 'cerulean'
game 'gta5'
name 'tc.f-hud.core'
description 'Main player HUD (health, cash) using BDUK primitives.'
author 'TeamConceptKR'
version '0.1.0'

lua54 'yes'

dependency 'tc.d-core.interfacebuilder'
dependency 'tc.d-core.systemframework'

dependencies {
  'tc.d-core.developmentkits'
}

shared_scripts { 'shared/**.lua' }
client_scripts { 'client/**.lua' }
server_scripts { 'server/**.lua' }
