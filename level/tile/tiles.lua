local tiles = {}

local tileClass = require("level/tile/tile")

tiles.cyan = tileClass.new("cyan", { 30, 167, 225 })
tiles.blue = tileClass.new("blue", { 39, 30, 225 })
tiles.green = tileClass.new("green", { 115, 205, 75 })
tiles.orange = tileClass.new("orange", { 232, 106, 23 })
tiles.yellow = tileClass.new("yellow", { 199, 198, 56 })
tiles.pink = tileClass.new("pink", { 225, 30, 121 })
tiles.red = tileClass.new("red", { 225, 30, 30 })
tiles.gray = tileClass.new("gray", { 123, 123, 123 })

return tiles