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

local function disableLaptopMonitor()
  hl.monitor {
    output = laptopMonitor.output,
    disabled = true,
  }
end

local function enableLaptopMonitor()
  hl.monitor(laptopMonitor)
  os.execute 'hyprctl reload'
end

-- close lid
hl.bind('switch:on:Lid Switch', disableLaptopMonitor, { locked = true })
-- open lid
hl.bind('switch:off:Lid Switch', enableLaptopMonitor, { locked = true })
