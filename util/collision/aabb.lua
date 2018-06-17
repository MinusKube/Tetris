local class = {}

function class.new(min, max)
  local collisionClass = require("util/collision/collision")
  local self = collisionClass.new("aabb")

  function self.collides(other)
    if self.getType() ~= other.getType() then
      return false
    end

    return  min.x <= other.getMax().x and
            min.y <= other.getMax().y and
            max.x >= other.getMin().x and
            max.y >= other.getMin().y
  end

  function self.shift(pos)
    return class.new(
      { x = min.x + pos.x, y = min.y + pos.y },
      { x = max.x + pos.x, y = max.y + pos.y }
    )
  end

  function self.grow(pos)
    return class.new(
      { x = min.x - pos.x, y = min.y - pos.y },
      { x = max.x + pos.x, y = min.y + pos.y }
    )
  end

  function self.shrink(pos)
    return class.new(
      { x = min.x + pos.x, y = min.y + pos.y },
      { x = max.x - pos.x, y = min.y - pos.y }
    )
  end

  function self.renderDebug()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", min.x, min.y, max.x, max.y)
  end

  function self.isHovered()
    local game = require("game")
    local mousePos = game.getMousePos()

    return self.collides(class.new(mousePos, mousePos))
  end

  function self.getMin() return min end
  function self.getMax() return max end

  return self
end

return class