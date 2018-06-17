local self = {}

local buttonGroupComponent = require("screen/component/buttonGroup")
local menuButtonComponent = require("screen/component/menuButtonComponent")
local buttonComponent = require("screen/component/buttonComponent")
local buttonStyle = require("screen/component/style/buttonStyle")
local imageButtonStyle = require("screen/component/style/imageButtonStyle")

local backgroundImage = love.graphics.newImage("resources/textures/menuBackground.png")

function self.new(game)
  local self = require("screen/screen").new(game)

  local super = {
    update = self.update,
    render = self.render
  }

  local midX = game.getWidth() / 2
  local midY = game.getHeight() / 2

  local fonts = {
    medium = love.graphics.newFont("resources/fonts/bebas.otf", 35)
  }

  for _, font in pairs(fonts) do
    font:setFilter("linear", "linear")
  end

  local imageButtonStyle = imageButtonStyle.new()
  local buttonStyle = buttonStyle.new()

  local playersButtonGroup = buttonGroupComponent.new("selectedPlayers")

  local playersOneButton = menuButtonComponent.new(playersButtonGroup, self, "1 Player", fonts.medium)
      .setButtonAlign("left")
      .setPosition(0, midY - 75)

  local playersTwoButton = menuButtonComponent.new(playersButtonGroup, self, "2 Players", fonts.medium)
      .setButtonAlign("left")
      .setPosition(0, midY)

  local playersThreeButton = menuButtonComponent.new(playersButtonGroup, self, "3 Players", fonts.medium)
      .setButtonAlign("left")
      .setPosition(0, midY + 75)

  local gameModeButtonGroup = buttonGroupComponent.new("selectedGameMode")

  local gameModeScoreButton = menuButtonComponent.new(gameModeButtonGroup, self, "Score", fonts.medium)
      .setButtonAlign("right")
      .setPosition(game.getWidth(), midY - 175)

  local gameModeTimeButton = menuButtonComponent.new(gameModeButtonGroup, self, "40 Lines", fonts.medium)
      .setButtonAlign("right")
      .setPosition(game.getWidth(), midY - 100)

  local gameModeTimeTrialButton = menuButtonComponent.new(gameModeButtonGroup, self, "Time Trial", fonts.medium)
      .setButtonAlign("right")
      .setPosition(game.getWidth(), midY - 25)

  local multiModeButtonGroup = buttonGroupComponent.new("selectedMultiMode")

  local multiModeCoopButton = menuButtonComponent.new(multiModeButtonGroup, self, "Coop", fonts.medium)
      .setButtonAlign("right")
      .setPosition(game.getWidth(), midY + 100)

  local multiModeVersusButton = menuButtonComponent.new(multiModeButtonGroup, self, "Versus", fonts.medium)
      .setButtonAlign("right")
      .setPosition(game.getWidth(), midY + 175)

  local playButton = buttonComponent.new(self, "Play", fonts.medium)
      .setStyle(imageButtonStyle)
      .setPosition(midX, midY)
      .onClick(function()
        local selectPlayers = playersButtonGroup.getSelected()
        local selectGameMode = gameModeButtonGroup.getSelected()
        local selectMultiMode = multiModeButtonGroup.getSelected()

        local mode
        local gameMode

        if selectGameMode == 1 then
          gameMode = "score"
        elseif selectGameMode == 2 then
          gameMode = "time"
        else
          gameMode = "timeTrial"
        end

        if selectPlayers == 1 then
          mode = "solo"
        else
          if selectMultiMode == 1 then
            mode = "coop" .. selectPlayers
          else
            if selectPlayers == 2 then
              mode = "1v1"
            else
              mode = "1v1v1"
            end
          end
        end

        game.startLevel(mode, gameMode)
      end)

  local settingsButton = buttonComponent.new(self, "Options", fonts.medium)
      .setStyle(imageButtonStyle)
      .setPosition(midX, midY + 250)
      .onClick(function()
        local optionsScreenClass = require("screen/optionsScreen")
        game.setScreen(optionsScreenClass.new(game))
      end)
    
  local quitButton = buttonComponent.new(self, "Quit", fonts.medium)
      .setStyle(imageButtonStyle)
      .setPosition(midX, midY + 350)
      .onClick(function()
        love.event.quit()
      end)

  self.add(playersOneButton, playersTwoButton, playersThreeButton)
  self.add(gameModeScoreButton, gameModeTimeButton, gameModeTimeTrialButton)
  self.add(multiModeCoopButton, multiModeVersusButton)
  self.add(playButton, settingsButton, quitButton)

  local particles = {}

  for index, component in ipairs(self.getComponents()) do
    local particlesLeft = love.graphics.newParticleSystem(love.graphics.newImage("resources/textures/particle.png"))

    if component == quitButton then
      particlesLeft:setColors(255, 0, 0, 255, 255, 255, 0, 80)
    elseif component == settingsButton then
      particlesLeft:setColors(100, 100, 100, 255, 150, 150, 150, 80)
    else
      particlesLeft:setColors(0, 255, 255, 255, 0, 0, 255, 80)
    end

    particlesLeft:setEmissionRate(200)
    particlesLeft:setLinearAcceleration(-200, 10, -200, 10)
    particlesLeft:setSpeed(40)
    particlesLeft:setSpread(math.pi * 2)
    particlesLeft:setParticleLifetime(2, 3)
    particlesLeft:setLinearDamping(100, 0)
    particlesLeft:setAreaSpread("normal", 0, 5)

    local particlesRight = love.graphics.newParticleSystem(love.graphics.newImage("resources/textures/particle.png"))

    if component == quitButton then
      particlesRight:setColors(255, 0, 0, 255, 255, 255, 0, 80)
    elseif component == settingsButton then
      particlesRight:setColors(100, 100, 100, 255, 150, 150, 150, 80)
    else
      particlesRight:setColors(0, 255, 255, 255, 0, 0, 255, 80)
    end

    particlesRight:setEmissionRate(200)
    particlesRight:setLinearAcceleration(200, 10, 200, 10)
    particlesRight:setSpeed(40)
    particlesRight:setSpread(math.pi * 2)
    particlesRight:setParticleLifetime(2, 3)
    particlesRight:setLinearDamping(100, 0)
    particlesRight:setAreaSpread("normal", 0, 5)

    particles[index] = {
      left = particlesLeft,
      right = particlesRight,
      button = component
    }
  end

  function self.update(dt)
    super.update(dt)

    if love.keyboard.isDown("return") or love.keyboard.isDown("space") then
      playButton.click()
    end

    if playersButtonGroup.getSelected() == 1 then
      multiModeButtonGroup.forEach(function(button)
        button.setEnabled(false)
      end)
    else
      multiModeButtonGroup.forEach(function(button)
        button.setEnabled(true)
      end)
    end

    for _, particle in ipairs(particles) do
      particle.left:update(dt)
      particle.right:update(dt)

      if particle.button.isHovered() then
        particle.left:start()
        particle.right:start()
      else
        particle.left:stop()
        particle.right:stop()
      end
    end
  end

  function self.render()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(backgroundImage, 0, 0)

    love.graphics.setColor(255, 255, 255)

    for _, particle in ipairs(particles) do
      local btnLeftX
      local btnLeftY

      if particle.button.getButtonAlign() == "left" then
        btnLeftX = 0
        btnLeftY = 0
      elseif particle.button.getButtonAlign() == "center" then
        btnLeftX = -particle.button.getWidth() / 2
        btnLeftY = -particle.button.getHeight() / 2
      elseif particle.button.getButtonAlign() == "right" then
        btnLeftX = -particle.button.getWidth()
        btnLeftY = 0
      end

      love.graphics.draw(particle.left,
        particle.button.getPosition().x + btnLeftX + 8,
        particle.button.getPosition().y + btnLeftY + particle.button.getHeight() / 2)

      love.graphics.draw(particle.right,
        particle.button.getPosition().x + btnLeftX + particle.button.getWidth() - 12,
        particle.button.getPosition().y + btnLeftY + particle.button.getHeight() / 2)
    end

    super.render()
  end
  
  return self
end

return self