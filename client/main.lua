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

  -- Interfacebuilder는 pages 기반 content 구조를 우선 사용하므로 간단한 단일 page로 구성
  local ui = {
    id = 'core_hud',
    content = {
      -- pages 대신 단일 html 사용: Content 모듈이 pages 없는 경우 set_content 경로로 raw html 주입
      html = ([[<div id="hud_wrapper" style="position:fixed;top:2%%;left:1.2%%;display:flex;flex-direction:column;gap:4px;font-family:Arial;z-index:10;min-width:180px;">
          <div data-comp-id="health_bar" class="hud_row" style="background:rgba(0,0,0,.45);padding:4px 8px;border-radius:4px;color:#fff;font-size:12px;">
            <span style="display:inline-block;width:40px;">HP</span>
            <span class="text_value">%d</span>
          </div>
          <div data-comp-id="armor_bar" class="hud_row" style="background:rgba(0,0,0,.45);padding:4px 8px;border-radius:4px;color:#fff;font-size:12px;">
            <span style="display:inline-block;width:40px;">AR</span>
            <span class="text_value">%d</span>
          </div>
          <div data-comp-id="stamina_bar" class="hud_row" style="background:rgba(0,0,0,.45);padding:4px 8px;border-radius:4px;color:#fff;font-size:12px;">
            <span style="display:inline-block;width:40px;">ST</span>
            <span class="text_value">%d</span>
          </div>
            <div data-comp-id="cash_text" class="hud_row" style="background:rgba(0,0,0,.6);padding:6px 10px;border-radius:4px;color:#7CFC92;font-weight:600;font-size:14px;text-shadow:0 0 4px #000;">
              <span class="text_value">$%s</span>
            </div>
        </div>]]):format(health, armor, stamina, hud_cfg.money_format(cash))
    }
  }

  d('building hud ui (no_focus)')
  ib:build(ui, { no_focus = true })
  -- 포커스 제거 (no_focus true 시 이미 처리되지만 확실하게)
  SetNuiFocus(false,false)
  ui_open = true
  last_payload = {
    health = health,
    armor = armor,
    stamina = stamina,
    cash = ('$' .. hud_cfg.money_format(cash)) -- 업데이트 로직과 동일 포맷으로 저장
  }
end

local function update_hud()
  if not ui_open then return end
  local ped = PlayerPedId()
  local health = GetEntityHealth(ped)
  local armor = GetPedArmour(ped)
  local stamina = (100 - GetPlayerSprintStaminaRemaining(PlayerId()))
  local cash = get_cash()
  local updates = {
    { id = 'health_bar', key = 'health', value = health },
    { id = 'armor_bar', key = 'armor', value = armor },
    { id = 'stamina_bar', key = 'stamina', value = stamina },
    { id = 'cash_text', key = 'cash', value = ('$' .. hud_cfg.money_format(cash)) }
  }
  for _, u in ipairs(updates) do
    if not last_payload or last_payload[u.key] ~= u.value then
      ib:send({ func = 'update_component', payload = { id = u.id, value = u.value } })
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

