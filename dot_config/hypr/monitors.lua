hl.monitor {
  output = 'eDP-1',
  mode = '1920x1200@144',
  position = '0x0',
  scale = '1.25',
}
hl.workspace_rule { workspace = '1', monitor = 'eDP-1' }
hl.monitor {
  output = 'HDMI-A-1',
  mode = 'highrr',
  position = 'auto',
  scale = 'auto',
}
hl.monitor {
  output = 'DP-1',
  mode = 'highrr',
  position = 'auto',
  scale = 'auto',
}
