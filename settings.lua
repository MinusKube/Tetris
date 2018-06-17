local file = "settings.dat"
local default = {}

default.width = "1280"
default.height = "720"
default.fullscreen = true
default.borderless = false
default.musicVolume = 5
default.sfxVolume = 5
default.tutorial = true
default.ghost = true
default.selectedPlayers = 1
default.selectedGameMode = 1
default.selectedMultiMode = 1

local settings = {}
settings.current = {}

settings.get = function(key)
  return settings.current[key]
end

settings.set = function(key, value)
  settings.current[key] = tostring(value)
end

settings.save = function()
  local text = ""
  
  for key, value in pairs(settings.current) do
    text = text .. key .. "=" .. tostring(value) .. "\n"
  end
  
  love.filesystem.write(file, text)
end

settings.define = function(conf, key, value)
  if key == "width" then
    conf.window.width = tonumber(value)
  elseif key == "height" then
    conf.window.height = tonumber(value)
  elseif key == "fullscreen" then
    conf.window.fullscreen = (value == "true")
  elseif key == "borderless" then
    conf.window.borderless = (value == "true")
  end
  
  settings.set(key, value)
end

settings.loadDefault = function(conf)
  for key, value in pairs(default) do
    settings.define(conf, key, value)
  end
end

return settings