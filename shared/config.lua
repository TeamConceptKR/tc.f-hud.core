hud_cfg = {
  debug = true,
  update_interval = 1000,
  money_format = function(amount)
    local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
  end
}
