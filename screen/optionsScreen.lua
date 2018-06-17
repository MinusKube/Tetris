local class = {}
local settings = require("settings")

function class.new(game)
  local buttonComponentClass = require("screen/component/buttonComponent")
  local self = require("screen/screen").new(game)

  local fonts = {
    bebas = { medium = love.graphics.newFont("resources/fonts/bebas.otf", 30) },
    sourceSansPro = { medium = love.graphics.newFont("resources/fonts/sourceSansPro.ttf", 30) }
  }

  for _, font in pairs(fonts.bebas) do
    font:setFilter("linear", "linear")
  end
  for _, font in pairs(fonts.sourceSansPro) do
    font:setFilter("linear", "linear")
  end
  
  local midX = game.getWidth() / 2
  local midY = game.getHeight() / 2
  
  local buttonStyle = require("screen/component/style/imageButtonStyle").new()
  local width, height, flags = love.window.getMode()
  
  local function createToggleButtons(key, flag, editWindow, y)
    local function clickAction()
      local currentFlag = settings.get(flag) == "true"

      if editWindow then
        flags[flag] = not currentFlag

        flags.x = nil
        flags.y = nil

        love.window.setMode(1280, 720, flags)
      end

      settings.set(flag, not currentFlag)

      game.updateScale()
      game.setScreen(class.new(game))
    end
    
    local leftButton = buttonComponentClass.new(self, "\226\151\128", fonts.sourceSansPro.medium)
      .setStyle(buttonStyle)
      .setWidth(50)
      .setPosition(midX - 200, y)
      .onClick(clickAction)
        
    local textStr, unformattedTextStr

    if settings.get(flag) == "true" then
      textStr = { { 255, 255, 255 }, key .. ": ", { 0, 255, 0 }, "Enabled" }
      unformattedTextStr = key .. ": " .. "Enabled"
    else
      textStr = { { 255, 255, 255 }, key .. ": ", { 255, 0, 0}, "Disabled" }
      unformattedTextStr = key .. ": " .. "Disabled"
    end
    
    local midButton = buttonComponentClass.new(self, unformattedTextStr, fonts.bebas.medium)
      .setStyle(buttonStyle)
      .setEnabled(false)
      .setPosition(midX, y)
        
    midButton.getLabel().getLabel():set(textStr)
      
    local rightButton = buttonComponentClass.new(self, "\226\150\182", fonts.sourceSansPro.medium)
      .setStyle(buttonStyle)
      .setWidth(50)
      .setPosition(midX + 200, y)
      .onClick(clickAction)
      
    return leftButton, midButton, rightButton
  end
  
  local function createVolumeButton(key, flag, y, min, max)
    local volume
    
    if flag == "musicVolume" then
      volume = game.getMusicVolume()
    elseif flag == "sfxVolume" then
      volume = game.getSFXVolume()
    end
    
    local function clickAction(left)
      if left then
        volume = math.max(min, volume - 1)
      else
        volume = math.min(max, volume + 1)
      end
      
      if flag == "musicVolume" then
        game.setMusicVolume(volume)
      end
      
      settings.set(flag, volume)
      game.setScreen(class.new(game))
    end
    
    local leftButton = buttonComponentClass.new(self, "\226\151\128", fonts.sourceSansPro.medium)
      .setStyle(buttonStyle)
      .setWidth(50)
      .setPosition(midX - 200, y)
      .onClick(function() clickAction(true) end)
        
    local textStr = { { 255, 255, 255 }, key .. ": ", { 100, 130, 255 }, tostring(volume) }
    local unformattedTextStr = key .. ": " .. tostring(volume)
  
    local midButton = buttonComponentClass.new(self, unformattedTextStr, fonts.bebas.medium)
      .setStyle(buttonStyle)
      .setEnabled(false)
      .setPosition(midX, y)
        
    midButton.getLabel().getLabel():set(textStr)
      
    local rightButton = buttonComponentClass.new(self, "\226\150\182", fonts.sourceSansPro.medium)
      .setStyle(buttonStyle)
      .setWidth(50)
      .setPosition(midX + 200, y)
      .onClick(function() clickAction(false) end)
      
    return leftButton, midButton, rightButton
  end
      
  local backButton = buttonComponentClass.new(self, "Back", fonts.bebas.medium)
      .setStyle(buttonStyle)
      .setPosition(midX, midY + 250)
      .onClick(function()
        game.setScreen(require("screen/mainScreen").new(game))
        settings.save()
      end)

  if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
    self.add(createVolumeButton("Music Volume", "musicVolume", midY - 150, 0, 10))
    self.add(createVolumeButton("SFX Volume", "sfxVolume", midY - 75, 0, 10))
    self.add(createToggleButtons("V-Sync", "vsync", true, midY))
    self.add(createToggleButtons("Show Ghost Piece", "ghost", false, midY + 75))
    self.add(createToggleButtons("Enable Tutorial", "tutorial", false, midY + 150))
  else
    self.add(createVolumeButton("Music Volume", "musicVolume", midY - 225, 0, 10))
    self.add(createVolumeButton("SFX Volume", "sfxVolume", midY - 150, 0, 10))
    self.add(createToggleButtons("Fullscreen", "fullscreen", true, midY - 75))
    self.add(createToggleButtons("Borderless", "borderless", true, midY))
    self.add(createToggleButtons("Show Ghost Piece", "ghost", false, midY + 75))
    self.add(createToggleButtons("Enable Tutorial", "tutorial", false, midY + 150))
  end
  
  self.add(backButton)

  local super = {
    render = self.render
  }

  function self.render()
    super.render()
  end
  
  return self
end

return class