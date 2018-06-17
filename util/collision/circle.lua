local class = {}

function class.new(center, radius)
  local collisionClass = require("util/collision/collision")
  local self = collisionClass.new("circle")

  function self.collides(other)
    if self.getType() ~= other.getType() then
      return false
    end

    local dist = math.sqrt(
      (center.x - other.getCenter().x) * (center.x - other.getCenter().x) +
              (center.y - other.getCenter().y) * (center.y - other.getCenter().y)
    )

    return dist <= radius + other.getRadius()
  end

  function self.shift(pos)
    return class.new({
      x = center.x + pos.x,
      y = center.y + pos.y
    }, radius)
  end

  function self.grow(amount)
    return class.new(center, radius + amount)
  end

  function self.shrink(amount)
    return class.new(center, radius - amount)
  end

  function self.renderDebug()
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("line", center.x, center.y, radius)
  end

  function self.isHovered()
    local game = require("game")
    local mousePos = game.getMousePos()

    return self.collides(class.new(mousePos, 1))
  end

  function self.getCenter() return center end
  function self.getRadius() return radius end

  return self
end

return class