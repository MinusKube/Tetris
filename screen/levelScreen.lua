local class = {}

function class.new(game, mode, gameMode)
  local screenClass = require("screen/screen")
  local self = screenClass.new(game)

  local super = {
    init = self.init,
    update = self.update,
    render = self.render
  }

  local level

  function self.init()
    super.init()

    local levelClass = require("level/level")

    level = levelClass.new(game, mode, gameMode)
    level.init()
  end

  function self.update(dt)
    super.update(dt)

    level.update(dt)

    if love.keyboard.isDown("escape") then
      game.setScreen(require("screen/mainScreen").new(game))
    end
  end

  function self.render()
    super.render()

    level.render()
  end

  function self.keyPressed(key, scanCode, isRepeat)
    level.keyPressed(key, scanCode, isRepeat)
  end

  function self.textInput(text)
    level.textInput(text)
  end

  return self
end

return class