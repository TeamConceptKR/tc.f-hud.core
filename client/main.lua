local ui_open=false
local last_payload=nil
local function d(msg) if hud_cfg.debug then print('[HUD] '..msg) end end

-- placeholder player money fetch (future economy integration)
local function get_cash()
  -- integrate with future money system export; fallback temporary random stable
  return LocalPlayer and LocalPlayer.state.cash or 5000
end

local ib = exports['tc.d-core.interfacebuilder']

local function build_hud()
  local ped = PlayerPedId()
  local health = GetEntityHealth(ped)
  local armor = GetPedArmour(ped)
  local stamina = (100 - GetPlayerSprintStaminaRemaining(PlayerId()))
  local cash = get_cash()
  local ui = {
    id = 'core_hud', type='frame', position='topleft', width=280, height=140, theme='dark', draggable=false,
    children = {
      { id='health_bar', type='progress_bar', label='HP', value=health, max=200, color='#d9534f'},
      { id='armor_bar', type='progress_bar', label='AR', value=armor, max=100, color='#337ab7'},
      { id='stamina_bar', type='progress_bar', label='ST', value=stamina, max=100, color='#5cb85c'},
      { id='cash_text', type='text', value='$'..hud_cfg.money_format(cash), size=18, weight=600 }
    }
  }
  ib:build(ui, { no_focus = true })
  ui_open=true
  last_payload = { health=health, cash=cash }
end

local function update_hud()
  if not ui_open then return end
  local ped = PlayerPedId()
  local health = GetEntityHealth(ped)
  local armor = GetPedArmour(ped)
  local stamina = (100 - GetPlayerSprintStaminaRemaining(PlayerId()))
  local cash = get_cash()
  local updates = {
    {id='health_bar', key='health', value=health},
    {id='armor_bar', key='armor', value=armor},
    {id='stamina_bar', key='stamina', value=stamina},
    {id='cash_text', key='cash', value='$'..hud_cfg.money_format(cash)}
  }
  for _,u in ipairs(updates) do
    if not last_payload or last_payload[u.key] ~= u.value then
  ib:send({ func='update_component', payload={ id=u.id, value=u.value } })
      if last_payload then last_payload[u.key] = u.value end
    end
  end
end

CreateThread(function()
  Wait(2500) -- allow player object load
  build_hud()
  while true do
    Wait(hud_cfg.update_interval or 1000)
    update_hud()
  end
end)
