local class = {}

local lastId = 0

function class.new(level, name, _position)
  local self = {}

  lastId = lastId + 1

  local id = lastId
  local position = _position
  local velocity = { x = 0, y = 0 }
  local collision
  local removed = false

  function self.init() end

  function self.update(dt)
    position.x = position.x + velocity.x * dt
    position.y = position.y + velocity.y * dt
  end

  function self.render() end
  function self.collides(other) end

  function self.getId() return id end
  function self.getName() return name end

  function self.getPosition() return position end
  function self.setPosition(_position)
    position = _position
    return self
  end

  function self.getVelocity() return velocity end
  function self.setVelocity(_velocity)
    velocity = _velocity
    return self
  end

  function self.hasCollision() return collision ~= nil end
  function self.getCollision() return collision end
  function self.setCollision(_collision)
    collision = _collision
    return self
  end

  function self.isRemoved() return removed end
  function self.remove() removed = true end

  function self.getLevel() return level end

  return self
end

return class