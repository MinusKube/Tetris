local self = {}

local width, height
local min
local scale

local screen

local settings
local currentMusic

function self.load()
  width = 1920
  height = 1080

  self.updateScale()

  settings = require("settings")

  local mainScreenClass = require("screen/mainScreen")
  self.setScreen(mainScreenClass.new(self))
end

function self.update(dt)
  screen.update(dt)
end

function self.render()
  love.graphics.push()
    love.graphics.translate(min.x, min.y)
    love.graphics.scale(scale, scale)

    screen.render()
  love.graphics.pop()

  -- Draw some rectangles to hide screen overflow
  love.graphics.setColor(0, 0, 0)

  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), min.y)
  love.graphics.rectangle("fill", 0, 0, min.x, love.graphics.getHeight())

  love.graphics.rectangle("fill", 0, min.y + height * scale, love.graphics.getWidth(), min.y)
  love.graphics.rectangle("fill", min.x + width * scale, 0, min.x, love.graphics.getHeight())
end

function self.startLevel(mode, gameMode)
  local levelScreenClass = require("screen/levelScreen")
  local levelScreen = levelScreenClass.new(self, mode, gameMode)

  self.setScreen(levelScreen)
end

function self.resize()
  self.updateScale()
end

function self.updateScale()
  min = { x = 0, y = 0 }

  local scaleX = love.graphics.getWidth() / width
  local scaleY = love.graphics.getHeight() / height

  if scaleX > scaleY then
    scale = scaleY
    min.x = (love.graphics.getWidth() - width * scale) / 2
  else
    scale = scaleX
    min.y = (love.graphics.getHeight() - height * scale) / 2
  end
end

function self.getWidth() return width end
function self.getHeight() return height end

function self.getMousePos()
  return self.toGamePos({
    x = love.mouse.getX(),
    y = love.mouse.getY()
  })
end

function self.toGamePos(screenPos)
  local newPos = {
    x = (screenPos.x - min.x) / scale,
    y = (screenPos.y - min.y) / scale
  }

  return newPos
end

function self.getScreen() return screen end
function self.setScreen(_screen)
  screen = _screen
  screen.init()

  return self
end

function self.getCurrentMusic() return currentMusic end
function self.setCurrentMusic(_currentMusic)
  if currentMusic ~= nil then
    currentMusic:stop()
  end

  currentMusic = _currentMusic
  currentMusic:setLooping(true)
  currentMusic:setVolume(self.getMusicVolume() / 10)
  currentMusic:play()
end

function self.getMusicVolume() return settings.get("musicVolume") end
function self.setMusicVolume(musicVolume)
  if currentMusic ~= nil then
    currentMusic:setVolume(musicVolume / 10)
  end
end

function self.getSFXVolume() return settings.get("sfxVolume") end

function self.getSettings() return settings end

return self