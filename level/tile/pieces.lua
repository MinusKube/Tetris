local pieces = {}

local tiles = require("level/tile/tiles")
local pieceClass = require("level/tile/piece")

local function add(tileName, shape)
  table.insert(pieces, function(levelGrid)
    return pieceClass.new(levelGrid, tiles[tileName], shape)
  end)
end

add("cyan", "OOOO-XXXX-OOOO")
add("yellow", "XX-XX")
add("pink", "OXO-XXX-OOO")
add("blue", "XOO-XXX-OOO")
add("orange", "OOX-XXX-OOO")
add("green", "OXX-XXO")
add("red", "XXO-OXX")

function pieces.random(levelGrid)
  local random = math.random(#pieces)
  return pieces[random](levelGrid)
end

return pieces