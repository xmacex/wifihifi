-- Make vibes out of Wifi
-- connections.
--
-- enc 2 = manual scan
-- enc 3 = LFO freq
--
-- key 2 = update
-- key 3 = autoscan

engine.name = "WifiHifi"

DEBUG = true
ssids = {}
data = {}
selected = 0
param = 0
scanner = nul

function init()
  update()
  scanner = metro.init(scan, 0.5)
end

function update()
  ssids = wifi.ssids()
  print("📡 Number of SSIDs: " .. #ssids)

  data = {}
  for k, ssid in pairs(ssids) do
    table.insert(data, ssid_to_sequence_data(ssid))
  end

  print("📊 Data")
  -- tab.print(data)

  redraw()
end

function redraw()
  if DEBUG then print("Selected " .. selected) end
  screen.clear()
  for k, wifi in pairs(data) do
    if k == selected then
      draw_wifi_name(ssids[k])
      draw_selected_bar(k)
    end
    for kk, datum in pairs(wifi) do
      screen.move((128/#ssids)*k - 4, 64 - (datum * 3.7))
      if k == selected then
        screen.level(1 + datum)
      else
        screen.level(1)
      end
      screen.text_center(datum) -- ♪
    end
  end
  screen.update()
end

function draw_wifi_name(name)
  screen.move(0, 5)
  screen.level(15)
  screen.text(name)
  screen.update()
end

function draw_selected_bar(x)
  print(x)
  screen.level(1)
  screen.rect((128/#ssids)*x - 7, 8, 6, 64)
  screen.fill()
  screen.update()
end


function draw_selected_bar_scan()
  -- for i=0,math.floor(168/10) do
  --   draw_selected_bar(i*168/10)
  -- end
  -- scan_metro = metro.init(function() draw_selected_bar(scan_metro.event) end, 0.1, math.floor(168/10))
  -- scan_metro = metro.init(print_event, 0.1, math.floor(168/10))
  scan_metro = metro.init(draw_selected_bar, 0.02, math.floor(192/10))
  scan_metro:start()
  -- metro.start(draw_selected_bar, 0.1, math.floor(168/10))
  -- scan_metro = metro.start(function(l) draw_selected_bar(scan_metro.tick) end, 0.1, math.floor(168/10))
  redraw()
end

------------------- interactions

function key(n, z)
  if DEBUG then print("Key " .. n .. " (" .. z .. ")") end
  if n == 2 and z == 1 then
    update()
    -- draw_selected_bar_scan()
  elseif n == 3 and z == 1 then
    toggle_scanner()
  end

  redraw()
end

function enc(n, z)
  if DEBUG then print("Enc " .. z) end
  if n == 2 then
    -- select ssid for signal
    selected = util.clamp(selected + z, 1, #ssids)
    if DEBUG then print("-> " .. sum(data[selected]) .. ", " .. average(data[selected])) end
    engine.freq(sum(data[selected]) * 50)
    engine.mod_depth(1/average(data[selected]))
  elseif n == 3 then
    -- change mod LFO speedsw
    param = util.clamp(param + z/10, 0, 1)
    if DEBUG then print("param: " .. param) end
    engine.mod(param)
  end

  redraw()
end

---------------------- fun-ctions
function scan(tick)
  if DEBUG then print("Scanning from " .. tick) end
  selected = tick % #ssids + 1
  engine.freq(sum(data[selected]) * 50)
  engine.mod_depth(1/average(data[selected]))
  redraw()
end

function toggle_scanner()
  if DEBUG then print("Toggling scanner") end
  if not scanner.is_running then
    if DEBUG then print("Enabling scanner") end
    scanner.props.init_stage = selected
    scanner:start()
  elseif scanner.is_running then
    if DEBUG then print("Disabling scanner") end
    scanner:stop()
  end
end

function ssid_to_data(ssid)
  local data = #trim(ssid)

  if DEBUG then
    print(ssid .. ": " .. #ssid .. " 🗜 " .. trim(ssid) .. ": " .. #trim(ssid))
  end

  return {data}
end

function ssid_to_sequence_data(ssid)
  local data = {}

  for token in split_by_space(trim(ssid)) do
    table.insert(data, #token)
  end

  return(data)
end

function sum(data)
  local result = 0
  for k, v in pairs(data) do
    result = result + v
  end
  return result
end

function average(data)
  local result = 0

  for k, v in pairs(data) do
    result = result + v
  end
  result = result / #data

  return result
end

-- From http://lua-users.org/wiki/StringTrim
function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function split_by_space(s)
  return string.gmatch(s, "%S+")
end

function int_to_bool(i)
  return i ~= 0
end