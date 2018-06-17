function love.conf(conf)
  love.filesystem.setIdentity("TetrisV2Isaac")

  conf.window.title = "TetrisV2 by Isaac M"
  conf.window.resizable = true

  local file = "settings.dat"

  local settings = require("settings")
  settings.loadDefault(conf)

  if love.filesystem.exists(file) then
    for line in love.filesystem.lines(file) do
      local key, value = line:match("([^=]+)=(.+)")

      settings.define(conf, key, value)
    end
  end

  settings.save()
end