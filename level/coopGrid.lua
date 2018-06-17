local class = {}

local sounds = require("sounds")
local background2Image = love.graphics.newImage("resources/textures/coop2GridBackground.png")
local background3Image = love.graphics.newImage("resources/textures/coop3GridBackground.png")

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

  local backgroundImage
  local grid = {}

  local currentPieces = {}
  local nextPieces = {}

  local rowsFalling = false
  local clearedRows = {}

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

  function self.init()
    if #keys == 2 then
      backgroundImage = background2Image
    else
      backgroundImage = background3Image
    end

    local pieces = require("level/tile/pieces")

    for row = 1, rows do
      grid[row] = {}
    end

    for player = 1, #keys do
      local piece = pieces.random(self)
      piece.setPlayer(player)

      table.insert(currentPieces, {
        piece = piece,
        row = 4,
        column = 15 * player - 8
      })
    end

    nextPieces = {
      pieces.random(self),
      pieces.random(self),
      pieces.random(self),
      pieces.random(self)
    }

    if mode == "timeTrial" then
      time = 2 * 60
    end
  end

  function self.placePiece(player)
    sounds.play(level.getGame(), "pieceLockdown")

    local piece = currentPieces[player].piece
    local currentRow = currentPieces[player].row
    local currentColumn = currentPieces[player].column

    local pieces = require("level/tile/pieces")

    for row = 1, piece.getRows() do
      for column = 1, piece.getColumns() do
        local tile = piece.getGrid()[row][column]

        if tile ~= 0 then
          local gridRow = row + currentRow
          local gridColumn = column + currentColumn

          grid[gridRow][gridColumn] = tile

          if gridRow <= 5 then
            sounds.play(level.getGame(), "gameOver")

            gameOver = true
            return
          end
        end
      end
    end

    local newPiece = nextPieces[1]

    currentPieces[player].row = 4
    currentPieces[player].column = 15 * player - 8

    if self.checkPieceCollision(player, 0, 0, newPiece.getGrid()) then
      sounds.play(level.getGame(), "gameOver")

      gameOver = true

      currentPieces[player].row = currentRow
      currentPieces[player].column = currentColumn
    else
      currentPieces[player].piece = newPiece
      currentPieces[player].piece.setPlayer(player)

      table.remove(nextPieces, 1)
      table.insert(nextPieces, pieces.random(self))
    end
  end

  function self.checkPieceCollision(player, rowOffset, columnOffset, pieceGrid)
    pieceGrid = pieceGrid or currentPieces[player].piece.getGrid()

    for row = 1, #pieceGrid do
      for column = 1, #pieceGrid[row] do
        local tile = pieceGrid[row][column]

        if tile ~= 0 then
          local gridRow = row + currentPieces[player].row
          local gridColumn = column + currentPieces[player].column

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

        table.insert(clearedRows, row)
        rowsFalling = true
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

  local wasUpDown = {}
  local wasLeftDown = {}
  local wasRightDown = {}
  local wasSpaceDown = {}

  local fallCooldowns = {}

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

    if mode ~= "timeTrial" then
      time = time + dt
    else
      time = time - dt
    end

    for player = 1, #keys do
      fallCooldowns[player] = (fallCooldowns[player] or 0) + dt

      if not wasSpaceDown[player] and love.keyboard.isDown(keys[player].place) then
        sounds.play(level.getGame(), "pieceHardDrop")

        while not self.checkPieceCollision(player, 1, 0) do
          currentPieces[player].row = currentPieces[player].row + 1
        end

        self.placePiece(player)
        self.checkRowsCompletion()
      else
        local maxCooldown

        if love.keyboard.isDown(keys[player].down) then
          maxCooldown = (0.1 / math.sqrt(currentLevel * 2)) / speed
        else
          maxCooldown = (0.5 / math.sqrt(currentLevel * 2)) / speed
        end

        if fallCooldowns[player] >= maxCooldown then
          self.rowsFall()

          if not rowsFalling then
            if not self.checkPieceCollision(player, 1, 0) then
              currentPieces[player].row = currentPieces[player].row + 1
            else
              self.placePiece(player)
              self.checkRowsCompletion()
            end
          end

          fallCooldowns[player] = 0
        end
      end

      if not rowsFalling then
        if not wasLeftDown[player] and love.keyboard.isDown(keys[player].left) then
          if not self.checkPieceCollision(player, 0, -1) then
            sounds.play(level.getGame(), "pieceMove")

            currentPieces[player].column = currentPieces[player].column - 1
          else
            sounds.play(level.getGame(), "pieceMoveFail")
          end
        end

        if not wasRightDown[player] and love.keyboard.isDown(keys[player].right) then
          if not self.checkPieceCollision(player, 0, 1) then
            sounds.play(level.getGame(), "pieceMove")

            currentPieces[player].column = currentPieces[player].column + 1
          else
            sounds.play(level.getGame(), "pieceMoveFail")
          end
        end

        if not wasUpDown[player] and love.keyboard.isDown(keys[player].rotate) then
          currentPieces[player].piece.rotate()
        end
      end

      if mode == "time" and clearedRowsAmt >= 40 then
        gameOver = true
      elseif mode == "timeTrial" and time <= 0 then
        time = 0
        gameOver = true
      end

      wasUpDown[player] = love.keyboard.isDown(keys[player].rotate)
      wasLeftDown[player] = love.keyboard.isDown(keys[player].left)
      wasRightDown[player] = love.keyboard.isDown(keys[player].right)
      wasSpaceDown[player] = love.keyboard.isDown(keys[player].place)
    end
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
          end
        end
      end

      for player = 1, #keys do
        -- Current Piece
        for row = currentPieces[player].piece.getRows(), 1, -1 do
          for column = 1, currentPieces[player].piece.getColumns() do
            local tile = currentPieces[player].piece.getGrid()[row][column]

            local gridRow = row + currentPieces[player].row
            local gridColumn = column + currentPieces[player].column

            if gridRow > 5 then
              renderTile("normal", gridRow - 5, gridColumn, tile)
            end
          end
        end

        -- Ghost Piece
        if level.getGame().getSettings().get("ghost") == "true"
                and not self.checkPieceCollision(player, 1, 0) then

          local ghostRow = 0

          repeat
            ghostRow = ghostRow + 1
          until(self.checkPieceCollision(player, ghostRow + 1, 0))

          for row = currentPieces[player].piece.getRows(), 1, -1 do
            for column = 1, currentPieces[player].piece.getColumns() do
              local tile = currentPieces[player].piece.getGrid()[row][column]

              local gridRow = row + currentPieces[player].row + ghostRow
              local gridColumn = column + currentPieces[player].column

              if gridRow > 5 then
                renderTile("ghost", gridRow - 5, gridColumn, tile)
              end
            end
          end
        end
      end

      -- Next Piece
      for index, nextPiece in ipairs(nextPieces) do
        for row = nextPiece.getRows(), 1, -1 do
          for column = 1, nextPiece.getColumns() do
            local tile = nextPiece.getGrid()[row][column]

            local gridRow = row + 2 + 4 * (index - 1)
            local gridColumn = column + columns + 1

            renderTile("normal", gridRow, gridColumn, tile)
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
  end

  function self.getSpeed() return speed end
  function self.setSpeed(_speed)
    speed = _speed
    return self
  end

  function self.getScore() return score end
  function self.getTime() return time end

  function self.getCurrentPiece(player) return currentPieces[player] end

  function self.getCurrentPieceRow(player) return currentPieces[player].row end
  function self.setCurrentPieceRow(player, row) currentPieces[player].row = row end

  function self.getCurrentPieceColumn(player) return currentPieces[player].column end
  function self.setCurrentPieceColumn(player, column) currentPieces[player].column = column end

  function self.getRows() return rows end
  function self.getColumns() return columns end
  function self.getTileSize() return tileSize end

  function self.isEnded() return gameOver end
  function self.getLevel() return level end

  function self.isCoop() return true end

  return self
end

return class