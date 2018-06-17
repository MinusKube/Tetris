local class = {}

local sounds = require("sounds")

local backgroundImage = love.graphics.newImage("resources/textures/gameBackground.png")
local backgroundMusic = love.audio.newSource("resources/sounds/backgroundMusic.mp3")

local highScores = require("highScores")
local highScoresImage = love.graphics.newImage("resources/textures/highScores.png")

local fonts = {
  medium = love.graphics.newFont(30)
}

function class.new(game, mode, gameMode)
  local self = {}

  local grids = {}
  local highScoresLoaded = false

  local username = ""
  local highScoreSent = false

  local bonusRowState = 0
  local bonusRowTimer

  function self.init()
    sounds.play(game, "gameStart")

    game.setCurrentMusic(backgroundMusic)

    local coopGridClass = require("level/coopGrid")
    local gridClass = require("level/grid")

    if mode == "1v1" then
      table.insert(grids, gridClass.new(self, gameMode, 20, 10, 48, {
        left = "q",
        right = "d",
        down = "s",
        rotate = "z",
        place = "space"
      }))

      table.insert(grids, gridClass.new(self, gameMode, 20, 10, 48, {
        left = "left",
        right = "right",
        down = "down",
        rotate = "up",
        place = "kp0"
      }))
    elseif mode == "1v1v1" then
      table.insert(grids, gridClass.new(self, gameMode, 20, 10, 48, {
        left = "q",
        right = "d",
        down = "s",
        rotate = "z",
        place = "space"
      }))

      table.insert(grids, gridClass.new(self, gameMode, 20, 10, 48, {
        left = "j",
        right = "l",
        down = "k",
        rotate = "i",
        place = "o"
      }))

      table.insert(grids, gridClass.new(self, gameMode, 20, 10, 48, {
        left = "left",
        right = "right",
        down = "down",
        rotate = "up",
        place = "kp0"
      }))
    elseif mode == "coop2" then
      table.insert(grids, coopGridClass.new(self, gameMode, 20, 30, 48, {
        {
          left = "q",
          right = "d",
          down = "s",
          rotate = "z",
          place = "space"
        },

        {
          left = "left",
          right = "right",
          down = "down",
          rotate = "up",
          place = "kp0"
        }
      }))
    elseif mode == "coop3" then
      table.insert(grids, coopGridClass.new(self, gameMode, 20, 45, 48, {
        {
          left = "q",
          right = "d",
          down = "s",
          rotate = "z",
          place = "space"
        },

        {
          left = "j",
          right = "l",
          down = "k",
          rotate = "i",
          place = "o"
        },

        {
          left = "left",
          right = "right",
          down = "down",
          rotate = "up",
          place = "kp0"
        }
      }))
    else
      table.insert(grids, gridClass.new(self, gameMode, 20, 10, 48, {
        left = "left",
        right = "right",
        down = "down",
        rotate = "up",
        place = "space"
      }))
    end

    bonusRowTimer = math.random(60) + 30

    for _, grid in ipairs(grids) do
      grid.init()
    end
  end

  function self.update(dt)
    if #grids > 1 then
      bonusRowState = bonusRowState + dt

      if bonusRowState >= bonusRowTimer then
        for _, grid in ipairs(grids) do
          local minRow = 5 + 3
          local maxRow = grid.getRows() - 3

          local row = math.random(maxRow - minRow) + minRow
          grid.setBonusRow(row)
        end

        bonusRowState = 0
        bonusRowTimer = math.random(60) + 60
      end
    end

    for _, grid in ipairs(grids) do
      grid.update(dt)
    end

    if mode == "solo" and grids[1].isEnded() and not highScoresLoaded then
      highScores.load(gameMode)
      highScoresLoaded = true
    end
  end

  function self.render()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(backgroundImage, 0, 0)

    if #grids == 2 then
      love.graphics.push()
        love.graphics.translate(100, 0)

        grids[1].render()
      love.graphics.pop()

      love.graphics.push()
        love.graphics.translate(1000, 0)

        grids[2].render()
      love.graphics.pop()
    elseif #grids == 3 then
      love.graphics.push()
        love.graphics.translate(50, 0.25 * game.getHeight() / 2)
        love.graphics.scale(0.75, 0.75)

        grids[1].render()
      love.graphics.pop()

      love.graphics.push()
        love.graphics.translate(650, 0.25 * game.getHeight() / 2)
      love.graphics.scale(0.75, 0.75)

        grids[2].render()
      love.graphics.pop()

      love.graphics.push()
        love.graphics.translate(1250, 0.25 * game.getHeight() / 2)
        love.graphics.scale(0.75, 0.75)

        grids[3].render()
      love.graphics.pop()
    else
      if mode == "solo" then
        love.graphics.push()
          love.graphics.translate(550, 0)

          grids[1].render()
        love.graphics.pop()
      elseif mode == "coop2" then
        love.graphics.push()
          love.graphics.translate(180, 0)

          grids[1].render()
        love.graphics.pop()
      elseif mode == "coop3" then
        love.graphics.push()
        love.graphics.translate(50, 0.25 * game.getHeight() / 2)
        love.graphics.scale(0.75, 0.75)

        grids[1].render()
        love.graphics.pop()
      end
    end

    if mode == "solo" and grids[1].isEnded() then
      love.graphics.setColor(255, 255, 255)
      love.graphics.draw(highScoresImage, 50, 50)

      love.graphics.setFont(fonts.medium)

      for index, highScore in ipairs(highScores.getHighScores(gameMode)) do
        local scoreText

        if gameMode == "score" or gameMode == "timeTrial" then
          scoreText = highScore.score
        elseif gameMode == "time" then
          local time = highScore.score

          local minutes = math.floor(time % 60)
          local seconds = math.floor(time / 60)

          if minutes < 10 then
            minutes = "0" .. minutes
          end

          if seconds < 10 then
            seconds = "0" .. seconds
          end

          scoreText = minutes .. ":" .. seconds .. "." .. math.floor((time % 1) * 10)
        end

        local text = index .. " • " .. highScore.name .. ": " .. scoreText
        love.graphics.print(text, 80, 160 + 50 * (index - 1))
      end

      if ((gameMode == "time" and grids[1].getClearedRows() >= 40) or
              (gameMode == "timeTrial" and grids[1].getTime() <= 0) or
              gameMode == "score")
              and not highScoreSent then

        love.graphics.print("Enter your name:", 80, 750)
        love.graphics.print(username, 80, 800)
      end
    end
  end

  function self.textInput(text)
    if highScoreSent or mode ~= "solo" or not grids[1].isEnded() then
      return
    end

    if gameMode == "time" and grids[1].getClearedRows() < 40 then
      return
    end

    if gameMode == "timeTrial" and grids[1].getTime() > 0 then
      return
    end

    if #username >= 15 then
      return
    end

    if not text:match("[a-zA-Z0-9_-]") then
      return
    end

    username = username .. text
  end

  function self.keyPressed(key, code, isRepeat)
    if highScoreSent or mode ~= "solo" or not grids[1].isEnded() then
      return
    end

    if gameMode == "time" and grids[1].getClearedRows() < 40 then
      return
    end

    if gameMode == "timeTrial" and grids[1].getTime() > 0 then
      return
    end

    local utf8 = require("utf8")

    if key == "backspace" then
      local offset = utf8.offset(username, -1)

      if offset then
        username = username:sub(1, offset - 1)
      end
    elseif key == "return" then
      highScores.addHighScore(gameMode, username, grids[1].getScore(), grids[1].getTime())
      highScoreSent = true
    end
  end

  function self.hasTutorial() return game.getSettings().get("tutorial") == "true" end
  function self.setTutorial(tutorial)
    game.getSettings().set("tutorial", tutorial)
    game.getSettings().save()
  end

  function self.getGrids() return grids end

  function self.getGame() return game end

  return self
end

return class