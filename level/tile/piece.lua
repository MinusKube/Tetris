local class = {}

local sounds = require("sounds")

function class.new(levelGrid, tile, shape)
  local self = {}

  local grid = {}
  local player

  for row, line in pairs(shape:split("-")) do
    local column = 1

    grid[row] = {}

    for char in line:gmatch(".") do
      if char == "X" then
        grid[row][column] = tile
      else
        grid[row][column] = 0
      end

      column = column + 1
    end
  end

  function self.rotate()
    local newGrid = {}

    for row = 1, #grid do
      for column = 1, #grid[row] do
        local newRow = column
        local newColumn = #grid - row + 1

        if newGrid[newRow] == nil then
          newGrid[newRow] = {}
        end

        newGrid[newRow][newColumn] = grid[row][column]
      end
    end

    local oldColumns = #grid[1]
    local newColumns = #newGrid[1]

    local offsets = { 0, -1, 1 }

    for _, offset in ipairs(offsets) do
      local rowOffset = newColumns - oldColumns
      local columnOffset = offset + (oldColumns - newColumns)

      if not levelGrid.isCoop() then
        if not levelGrid.checkPieceCollision(rowOffset, columnOffset, newGrid) then
          sounds.play(levelGrid.getLevel().getGame(), "pieceRotate")

          grid = newGrid

          levelGrid.setCurrentPieceRow(levelGrid.getCurrentPieceRow() + rowOffset)
          levelGrid.setCurrentPieceColumn(levelGrid.getCurrentPieceColumn() + columnOffset)

          return
        end
      else
        if not levelGrid.checkPieceCollision(player, rowOffset, columnOffset, newGrid) then
          sounds.play(levelGrid.getLevel().getGame(), "pieceRotate")

          grid = newGrid

          levelGrid.setCurrentPieceRow(player, levelGrid.getCurrentPieceRow(player) + rowOffset)
          levelGrid.setCurrentPieceColumn(player, levelGrid.getCurrentPieceColumn(player) + columnOffset)

          return
        end
      end

      sounds.play(levelGrid.getLevel().getGame(), "pieceRotateFail")
    end
  end

  function self.getPlayer() return player end
  function self.setPlayer(_player)
    player = _player
    return self
  end

  function self.getGrid() return grid end

  function self.getRows() return #grid end
  function self.getColumns() return #grid[1] end

  return self
end

return class