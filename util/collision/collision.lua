local class = {}

function class.new(type)
  local self = {}

  function self.collides(other) return false end
  function self.shift(pos) return self end
  function self.grow(amount) return self end
  function self.shrink(amount) return self end
  function self.isHovered() return false end

  function self.renderDebug() end
  function self.isHovered() end

  function self.getType() return type end

  return self
end

return class