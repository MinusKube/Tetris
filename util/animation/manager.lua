local class = {}

function class.new(animations)
  local self = {}

  local currentAnimation
  local alignment = "top left"

  local maxWidth = 0
  local maxHeight = 0

  for _, animation in ipairs(animations) do
    maxWidth = math.max(maxWidth, animation.getWidth())
    maxHeight = math.max(maxHeight, animation.getHeight())
  end

  function self.update(dt)
    if currentAnimation ~= nil then
      animations[currentAnimation].update(dt)
    end
  end

  function self.render(x, y, rotation, sx, sy, ox, oy)
    if currentAnimation ~= nil then
      -- TODO: Update x and y according to the alignment

      animations[currentAnimation].render(x, y, rotation, sx, sy, ox, oy)
    end
  end

  function self.getAlignment() return alignment end
  function self.setAlignment(_alignment)
    alignment = _alignment
    return self
  end

  function self.getCurrentAnimationName() return currentAnimation end
  function self.getCurrentAnimation() return animations[currentAnimation] end

  function self.setCurrentAnimation(currentAnimationName)
    if currentAnimation == currentAnimationName then
      return
    end

    currentAnimation = currentAnimationName
    animations[currentAnimation].start()

    return self
  end

  return self
end

return class