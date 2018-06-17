local class = {}

local keyboardArrowLeftImage = love.graphics.newImage("resources/textures/keyboardArrowLeft.png")
local keyboardArrowRightImage = love.graphics.newImage("resources/textures/keyboardArrowRight.png")
local keyboardArrowUpImage = love.graphics.newImage("resources/textures/keyboardArrowUp.png")
local keyboardArrowDownImage = love.graphics.newImage("resources/textures/keyboardArrowDown.png")

local fonts = {
  medium = love.graphics.newFont(20)
}

function class.new(grid)
  local self = {}

  --[[
  --
  -- States:
  --   0 -> Pause
  --   1 -> Move left
  --   2 -> Move right
  --   3 -> Rotate
  --   4 -> Push down (allow player to rotate and move?)
  --   5 -> Full line (no demo, just explanation)
  --
   ]]

  local state = 0
  local stateTimer = 0

  local pausing = false
  local ended = false

  local skipTimer = 0

  function self.init()
  end

  function self.update(dt)
    if ended then
      return
    end

    stateTimer = stateTimer + dt

    if state == 0 then
      if stateTimer > 1 then
        state = 1
        stateTimer = 0

        pausing = true
      end
    elseif state == 1 then
      if stateTimer > 0.5 then
        if love.keyboard.isDown("left") or love.keyboard.isDown("right") then
          pausing = false

          state = 2
          stateTimer = 0
        end
      end
    elseif state == 2 then
      if stateTimer > 1.5 then
        pausing = true

        if love.keyboard.isDown("up") then
          pausing = false

          state = 3
          stateTimer = 0
        end
      end
    elseif state == 3 then
      if stateTimer > 1.5 then
        pausing = true

        if love.keyboard.isDown("down") then
          grid.getLevel().setTutorial(false)
          pausing = false

          state = 4
          stateTimer = 0
        end
      end
    end

    if love.keyboard.isDown("space") then
      skipTimer = skipTimer + dt

      if skipTimer > 1 then
        grid.getLevel().setTutorial(false)

        pausing = false
        ended = true
      end
    else
      skipTimer = 0
    end
  end

  function self.render()
    if ended then
      return
    end

      local game = grid.getLevel().getGame()

      love.graphics.setFont(fonts.medium)
      love.graphics.setColor(255, 255, 255)

      if love.keyboard.isDown("space") then
        love.graphics.print("Skipping tutorial...", 20, game.getHeight() - 40)
      else
        love.graphics.print("Hold Space to skip", 20, game.getHeight() - 40)
      end

    if state == 1 and stateTimer > 0.5 then
      local scale = 1 + ((stateTimer % 1) - 0.5) ^ 2

      love.graphics.draw(keyboardArrowLeftImage, 200, 100, math.rad(-15), scale, scale,
        keyboardArrowLeftImage:getWidth() / 2, keyboardArrowLeftImage:getHeight() / 2)

      love.graphics.draw(keyboardArrowRightImage, 400, 100, math.rad(15), scale, scale,
        keyboardArrowRightImage:getWidth() / 2, keyboardArrowRightImage:getHeight() / 2)
    elseif state == 2 and stateTimer > 1.5 then
      local scale = 1 + ((stateTimer % 1) - 0.5) ^ 2

      love.graphics.draw(keyboardArrowUpImage, 100, 100, math.rad(-15), scale, scale,
        keyboardArrowUpImage:getWidth() / 2, keyboardArrowUpImage:getHeight() / 2)
    elseif state == 3 and stateTimer > 1.5 then
      local scale = 1 + ((stateTimer % 1) - 0.5) ^ 2

      love.graphics.draw(keyboardArrowDownImage, 100, 100, math.rad(-15), scale, scale,
        keyboardArrowDownImage:getWidth() / 2, keyboardArrowDownImage:getHeight() / 2)
    end
  end

  function self.isPausing() return pausing end
  function self.isEnded() return ended end

  return self
end

return class