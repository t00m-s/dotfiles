local laptopMonitor = {
  output = 'eDP-1',
  mode = '1920x1200@144',
  position = '0x0',
  scale = '1.25',
}

local asusMonitor = {
  output = 'HDMI-A-1',
  mode = '1920x1080@240',
  position = 'auto',
  scale = 'auto',
}

local aocMonitor = {
  output = 'DP-1',
  mode = 'highrr',
  position = 'auto-right',
  scale = 'auto',
}

hl.monitor(laptopMonitor)
hl.monitor(asusMonitor)
hl.monitor(aocMonitor)
-- Plugging in random monitors (e.g. university)
hl.monitor { output = '', mode = 'preferred', position = 'auto', scale = 1 }

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
