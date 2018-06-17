local class = {}

local sounds = require("sounds")
local backgroundImage = love.graphics.newImage("resources/textures/gridBackground.png")

local fonts = {
  medium = love.graphics.newFont(30),
  big = love.graphics.newFont(120)
}

for _, font in pairs(fonts) do
  font:setFilter("linear", "linear")
end

function class.new(level, mode, rows, columns, tileSize, keys)
  rows = rows + 5

  local self = {}

  local grid = {}

  local currentPiece
  local currentPieceRow
  local currentPieceColumn

  local nextPiece

  local rowsFalling = false
  local clearedRows = {}
  local insertedRows = {}

  local speed = 1
  local currentLevel = 1
  local clearedRowsAmt = 0

  local time = 0
  local score = 0

  local gameOver = false
  local gameOverTimer = 0
  local gameOverOffsetsState = 0
  local gameOverOffsets = {
    { x = 0, y = 0 },
    { x = 0, y = 0 },
    { x = 0, y = 0 }
  }

  local bonusRow = 0

  local tutorial

  local specials = {}

  function self.init()
    local tutorialClass = require("level/tutorial")
    local pieces = require("level/tile/pieces")

    for row = 1, rows do
      grid[row] = {}
    end

    currentPiece = pieces.random(self)
    nextPiece = pieces.random(self)

    currentPieceRow = 4
    currentPieceColumn = math.floor((columns - currentPiece.getColumns()) / 2)

    if #level.getGrids() == 1 then
      tutorial = tutorialClass.new(self)
    end

    if mode == "timeTrial" then
      time = 2 * 60
    end
  end

  function self.insertRow(rowIndex, columns)
    table.insert(insertedRows, {
      index = rowIndex,
      columns = columns
    })
  end

  function self.placePiece()
    sounds.play(level.getGame(), "pieceLockdown")

    local pieces = require("level/tile/pieces")

    for row = 1, currentPiece.getRows() do
      for column = 1, currentPiece.getColumns() do
        local tile = currentPiece.getGrid()[row][column]

        if tile ~= 0 then
          local gridRow = row + currentPieceRow
          local gridColumn = column + currentPieceColumn

          grid[gridRow][gridColumn] = tile

          if gridRow <= 5 then
            sounds.play(level.getGame(), "gameOver")

            gameOver = true
            return
          end
        end
      end
    end

    local oldPieceRow = currentPieceRow
    local oldPieceColumn = currentPieceColumn

    local newPiece = nextPiece

    currentPieceRow = 4
    currentPieceColumn = math.floor((columns - newPiece.getColumns()) / 2)

    if self.checkPieceCollision(0, 0, newPiece.getGrid()) then
      sounds.play(level.getGame(), "gameOver")

      gameOver = true

      currentPieceRow = oldPieceRow
      currentPieceColumn = oldPieceColumn
    else
      currentPiece = newPiece

      nextPiece = pieces.random(self)
    end
  end

  function self.checkPieceCollision(rowOffset, columnOffset, pieceGrid)
    pieceGrid = pieceGrid or currentPiece.getGrid()

    for row = 1, #pieceGrid do
      for column = 1, #pieceGrid[row] do
        local tile = pieceGrid[row][column]

        if tile ~= 0 then
          local gridRow = row + currentPieceRow
          local gridColumn = column + currentPieceColumn

          if gridRow + rowOffset < 1 or gridRow + rowOffset > rows
                  or gridColumn + columnOffset < 1 or gridColumn + columnOffset > columns then

            return true
          end

          local gridTile = grid[gridRow + rowOffset][gridColumn + columnOffset]

          if gridTile ~= nil and gridTile ~= 0 then
            return true
          end
        end
      end
    end

    return false
  end

  function self.checkRowFull(row)
    for column = 1, columns do
      if grid[row][column] == nil or grid[row][column] == 0 then
        return false
      end
    end

    return true
  end

  function self.checkRowsCompletion()
    for row = 1, rows do
      if self.checkRowFull(row) then
        -- Clear Row
        for column = 1, columns do
          grid[row][column] = 0
        end

        if row == bonusRow then
          for _, grid in ipairs(level.getGrids()) do
            if grid ~= self then
              local specialClass = require("level/special/special")
              grid.addSpecial(specialClass.randomMalus(grid))
            end
          end

          bonusRow = 0
        end

        table.insert(clearedRows, row)
        rowsFalling = true
      end
    end

    for i = 1, #clearedRows - 1 do
      local tiles = require("level/tile/tiles")

      for _, grid in ipairs(level.getGrids()) do
        if grid ~= self then
          local columns = {}
          local gap = math.random(grid.getColumns())

          for column = 1, grid.getColumns() do
            if column == gap then
              columns[column] = 0
            else
              columns[column] = tiles.gray
            end
          end

          grid.insertRow(grid.getRows(), columns)
        end
      end
    end

    if #clearedRows == 1 then
      sounds.play(level.getGame(), "lineClearSingle")
      score = score + 40
    elseif #clearedRows == 2 then
      sounds.play(level.getGame(), "lineClearDouble")
      score = score + 100
    elseif #clearedRows == 3 then
      sounds.play(level.getGame(), "lineClearTriple")
      score = score + 300
    elseif #clearedRows == 4 then
      sounds.play(level.getGame(), "lineClearTetris")
      score = score + 1200
    end
  end

  function self.rowsFall()
    if #clearedRows == 0 then
      return
    end

    for row = clearedRows[1], 1, -1 do
      if row > 1 then
        for column = 1, columns do
          grid[row][column] = grid[row - 1][column]
          grid[row - 1][column] = 0
        end
      end
    end

    clearedRowsAmt = clearedRowsAmt + 1

    if clearedRowsAmt % 10 == 0 then
      sounds.play(level.getGame(), "levelUp")

      currentLevel = currentLevel + 1
    end

    table.remove(clearedRows, 1)

    if #clearedRows == 0 then
      rowsFalling = false
    end
  end

  local wasUpDown = false
  local wasLeftDown = false
  local wasRightDown = false
  local wasSpaceDown = false

  local fallCooldown = 0

  function self.update(dt)
    if gameOver then
      gameOverTimer = gameOverTimer + dt
      gameOverOffsetsState = gameOverOffsetsState + dt

      if gameOverTimer < 3 and gameOverOffsetsState > 0.05 then
        gameOverOffsetsState = 0

        gameOverOffsets[1] = {
          x = (math.random(16) - 8) / (gameOverTimer + 1),
          y = (math.random(16) - 8) / (gameOverTimer + 1)
        }

        gameOverOffsets[2] = {
          x = (math.random(8) - 4) / (gameOverTimer + 1),
          y = (math.random(8) - 4) / (gameOverTimer + 1)
        }

        gameOverOffsets[3] = {
          x = (math.random(8) - 4) / (gameOverTimer + 1),
          y = (math.random(8) - 4) / (gameOverTimer + 1)
        }
      end

      return
    end

    if #level.getGrids() == 1 then
      if level.hasTutorial() then
        tutorial.update(dt)
      end

      if tutorial.isPausing() then
        return
      end
    end

    if mode ~= "timeTrial" then
      time = time + dt
    else
      time = time - dt
    end

    fallCooldown = fallCooldown + dt

    for index, special in ipairs(specials) do
      special.update(dt)

      if special.isEnded() then
        table.remove(specials, index)
      end
    end

    if not wasSpaceDown and love.keyboard.isDown(keys.place) then
      sounds.play(level.getGame(), "pieceHardDrop")

      while not self.checkPieceCollision(1, 0) do
        currentPieceRow = currentPieceRow + 1
      end

      self.placePiece()
      self.checkRowsCompletion()
    else
      local maxCooldown

      if love.keyboard.isDown(keys.down) then
        maxCooldown = (0.1 / math.sqrt(currentLevel * 2)) / speed
      else
        maxCooldown = (0.5 / math.sqrt(currentLevel * 2)) / speed
      end

      if fallCooldown >= maxCooldown then
        self.rowsFall()

        if not rowsFalling then
          for _, inserted in ipairs(insertedRows) do
            currentPieceRow = currentPieceRow - 1

            for row = 2, inserted.index do
              for column = 1, #inserted.columns do
                grid[row - 1][column] = grid[row][column]

                if row == inserted.index then
                  grid[row][column] = inserted.columns[column]
                else
                  grid[row][column] = 0
                end
              end
            end
          end

          insertedRows = {}

          if not self.checkPieceCollision(1, 0) then
            currentPieceRow = currentPieceRow + 1
          else
            self.placePiece()
            self.checkRowsCompletion()
          end
        end

        fallCooldown = 0
      end
    end

    if not rowsFalling then
      if not wasLeftDown and love.keyboard.isDown(keys.left) then
        if not self.checkPieceCollision(0, -1) then
          sounds.play(level.getGame(), "pieceMove")

          currentPieceColumn = currentPieceColumn - 1
        else
          sounds.play(level.getGame(), "pieceMoveFail")
        end
      end

      if not wasRightDown and love.keyboard.isDown(keys.right) then
        if not self.checkPieceCollision(0, 1) then
          sounds.play(level.getGame(), "pieceMove")

          currentPieceColumn = currentPieceColumn + 1
        else
          sounds.play(level.getGame(), "pieceMoveFail")
        end
      end

      if not wasUpDown and love.keyboard.isDown(keys.rotate) then
        currentPiece.rotate()
      end
    end

    if mode == "time" and clearedRowsAmt >= 40 then
      gameOver = true
    elseif mode == "timeTrial" and time <= 0 then
      time = 0
      gameOver = true
    end

    wasUpDown = love.keyboard.isDown(keys.rotate)
    wasLeftDown = love.keyboard.isDown(keys.left)
    wasRightDown = love.keyboard.isDown(keys.right)
    wasSpaceDown = love.keyboard.isDown(keys.place)
  end

  local function renderTile(type, row, column, tile)
    love.graphics.push()
      love.graphics.translate((column - 1) * tileSize, (row - 1) * tileSize)

      if tile ~= nil and tile ~= 0 and type == "normal" then
        tile.render()
      elseif tile ~= nil and tile ~= 0 and type == "ghost" then
        tile.renderGhost()
      elseif type == "bonus" then
        love.graphics.setColor(255, 0, 255, 50)
        love.graphics.rectangle("fill", 0, 0, tileSize, tileSize)
      end
    love.graphics.pop()
  end

  function self.render()
    love.graphics.setColor(255, 255, 255, 100)
    love.graphics.draw(backgroundImage, 0, 0)

    love.graphics.push()
      love.graphics.translate(60, 60)

      for row = rows, 1, -1 do
        for column = 1, columns do
          local tile = grid[row][column]

          if row > 5 then
            renderTile("normal", row - 5, column, tile)

            if row == bonusRow then
              renderTile("bonus", row - 5, column, tile)
            end
          end
        end
      end

      -- Current Piece
      for row = currentPiece.getRows(), 1, -1 do
        for column = 1, currentPiece.getColumns() do
          local tile = currentPiece.getGrid()[row][column]

          local gridRow = row + currentPieceRow
          local gridColumn = column + currentPieceColumn

          if gridRow > 5 then
            renderTile("normal", gridRow - 5, gridColumn, tile)
          end
        end
      end

      -- Next Piece
      for row = nextPiece.getRows(), 1, -1 do
        for column = 1, nextPiece.getColumns() do
          local tile = nextPiece.getGrid()[row][column]

          local gridRow = row + 2
          local gridColumn = column + columns + 1

          renderTile("normal", gridRow, gridColumn, tile)
        end
      end

      -- Ghost Piece
      if level.getGame().getSettings().get("ghost") == "true"
              and not self.checkPieceCollision(1, 0) then

        local ghostRow = 0

        repeat
          ghostRow = ghostRow + 1
        until(self.checkPieceCollision(ghostRow + 1, 0))

        for row = currentPiece.getRows(), 1, -1 do
          for column = 1, currentPiece.getColumns() do
            local tile = currentPiece.getGrid()[row][column]

            local gridRow = row + currentPieceRow + ghostRow
            local gridColumn = column + currentPieceColumn

            if gridRow > 5 then
              renderTile("ghost", gridRow - 5, gridColumn, tile)
            end
          end
        end
      end
    love.graphics.pop()

    love.graphics.setFont(fonts.medium)

    local text = "Level: " .. currentLevel .. "  Lines: " .. clearedRowsAmt

    local minutes = math.floor(time / 60)
    local seconds = math.floor(time % 60)

    if minutes < 10 then
      minutes = "0" .. minutes
    end

    if seconds < 10 then
      seconds = "0" .. seconds
    end

    local timeStr = minutes .. ":" .. seconds .. "." .. math.floor((time % 1) * 10)

    if mode == "score" then
      text = text .. "  Score: " .. score
    elseif mode == "time" then
      text = text .. "  Time: " .. timeStr
    elseif mode == "timeTrial" then
      text = text .. "  Time: " .. timeStr .. "  Score: " .. score
    end

    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(text, 0, 10, backgroundImage:getWidth(), "center")

    if gameOver then
      love.graphics.setFont(fonts.big)

      love.graphics.setColor(0, 0, 0)

      love.graphics.push()
        love.graphics.translate(gameOverOffsets[1].x, gameOverOffsets[1].y)
        love.graphics.printf("GAME OVER!", 0, backgroundImage:getHeight() / 2 - 90,
          backgroundImage:getWidth(), "center")
      love.graphics.pop()

      love.graphics.push()
        love.graphics.translate(gameOverOffsets[2].x, gameOverOffsets[2].y)
        love.graphics.printf("GAME OVER!", 0, backgroundImage:getHeight() / 2 - 90,
          backgroundImage:getWidth(), "center")
      love.graphics.pop()

      love.graphics.setColor(255, 255, 255)

      love.graphics.push()
        love.graphics.translate(gameOverOffsets[3].x, gameOverOffsets[3].y)
        love.graphics.printf("GAME OVER!", 0, backgroundImage:getHeight() / 2 - 90,
          backgroundImage:getWidth(), "center")
      love.graphics.pop()
    end

    if level.hasTutorial() and #level.getGrids() == 1 then
      tutorial.render()
    end
  end

  function self.getSpeed() return speed end
  function self.setSpeed(_speed)
    speed = _speed
    return self
  end

  function self.getScore() return score end
  function self.getTime() return time end

  function self.getCurrentPiece() return currentPiece end

  function self.getCurrentPieceRow() return currentPieceRow end
  function self.setCurrentPieceRow(row) currentPieceRow = row end

  function self.getCurrentPieceColumn() return currentPieceColumn end
  function self.setCurrentPieceColumn(column) currentPieceColumn = column end

  function self.getClearedRows() return clearedRowsAmt end

  function self.getRows() return rows end
  function self.getColumns() return columns end
  function self.getTileSize() return tileSize end

  function self.getBonusRow() return bonusRow end
  function self.setBonusRow(_bonusRow)
    bonusRow = _bonusRow
    return self
  end

  function self.getSpecials() return specials end
  function self.addSpecial(special)
    for _, spec in ipairs(specials) do
      if spec.getName() == special.getName() then
        return
      end
    end

    table.insert(specials, special)
    special.start()
  end

  function self.isEnded() return gameOver end
  function self.getLevel() return level end

  function self.isCoop() return false end

  return self
end

return class