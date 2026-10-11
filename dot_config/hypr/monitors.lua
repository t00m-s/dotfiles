local laptopMonitor = {
  output = 'eDP-1',
  mode = '1920x1200@144.0',
  position = '0x0',
  scale = 1.25,
  vrr = 0,
}
local aocMonitor = {
  output = 'DP-1',
  mode = '1920x1080@144.0',
  position = '3456x0',
  scale = 1,
  vrr = 0,
}
-- local asusTop = {
--   output = 'HDMI-A-1',
--   mode = '1920x1080@240.0',
--   position = '-192x-1080',
--   scale = 1.0,
--   vrr = 0,
-- }
local asusMonitor = {
  output = 'HDMI-A-1',
  mode = '1920x1080@240.0',
  position = '1536x0',
  scale = 1.0,
  vrr = 0,
}
hl.monitor { output = '', mode = 'preferred', position = 'auto', scale = 1 }
hl.monitor(laptopMonitor)
hl.monitor(asusMonitor)
-- hl.monitor(asusTop)
-- hl.monitor(aocMonitor)
-- close lid
hl.bind(
  'switch:on:Lid Switch',
  hl.dsp.exec_cmd '/home/tommaso/.config/hypr/scripts/clamshell.sh close',
  { locked = true }
)
-- open lid
hl.bind(
  'switch:off:Lid Switch',
  hl.dsp.exec_cmd '/home/tommaso/.config/hypr/scripts/clamshell.sh open',
  { locked = true }
)

hl.exec_cmd '/home/tommaso/.config/hypr/scripts/clamshell.sh check'
