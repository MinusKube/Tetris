local class = {}

function class.new(sprite, width, height, _duration, _loop, _offsetX, _offsetY)
  local self = {}

  local offsetX = _offsetX or 0
  local offsetY = _offsetY or 0

  local duration = _duration
  local loop = _loop

  local started = false
  local paused = false
  local ended = false

  local currentTime = 0
  local currentFrame = 1

  local actions = {}

  local quads = {}

  local repeatFrames = {}

  for y = 0, sprite:getHeight() - height, height do
    for x = 0, sprite:getWidth() - width, width do
      local quad = love.graphics.newQuad(x, y, width, height, sprite:getDimensions())
      table.insert(quads, quad)
    end
  end

  local function launchAction(type)
    for _, action in ipairs(actions) do
      if type == action.type then

        if type == "then" then
          action.action()
        elseif type == "on" then
          if currentFrame == action.frameIndex then
            action.action()
          end
        elseif type == "while" then
          if action.condition() then
            action.action()
          end
        elseif type == "when" then
          local isTrue = action.condition()

          if not action.wasTrue and isTrue then
            action.action()
          end

          action.wasTrue = isTrue
        end

      end
    end
  end

  function self.update(dt)
    currentTime = currentTime + dt

    if currentTime >= duration then
      currentTime = 0
      currentFrame = currentFrame + 1

      for _, repeatFrame in ipairs(repeatFrames) do
        if repeatFrame.times > repeatFrame.current then
          if currentFrame > repeatFrame.max then
            currentFrame = repeatFrame.min

            repeatFrame.current = repeatFrame.current + 1
          end
        end
      end

      launchAction("on")

      if currentFrame > #quads then
        if loop then
          for _, repeatFrame in ipairs(repeatFrames) do
            repeatFrame.current = 0
          end

          currentFrame = 1
        else
          currentFrame = #quads
          ended = true

          launchAction("then")
        end
      end
    end

    launchAction("while")
    launchAction("when")
  end

  function self.render(x, y, rotation, sx, sy, ox, oy)
    love.graphics.draw(sprite, quads[currentFrame], x + offsetX, y + offsetY,
      rotation, sx, sy, ox, oy)
  end

  function self.start()
    for _, repeatFrame in ipairs(repeatFrames) do
      repeatFrame.current = 0
    end

    currentTime = 0
    currentFrame = 1

    started = true
    paused = false
    ended = false
  end

  function self.pause()
    if not started or ended or paused then return end

    paused = true
  end

  function self.resume()
    if not started or ended or not paused then return end

    paused = false
  end

  function self.stop()
    if not started or ended then return end

    started = false
    paused = false
    ended = false
  end

  function self.thenDo(func)
    table.insert(actions, {
      type = "then",
      action = func
    })

    return self
  end

  function self.doOn(frameIndex, func)
    table.insert(actions, {
      type = "on",
      action = func,
      frameIndex = frameIndex
    })

    return self
  end

  function self.doWhile(boolFunc, func)
    table.insert(actions, {
      type = "while",
      action = func,
      condition = boolFunc
    })

    return self
  end

  function self.doWhen(boolFunc, func)
    table.insert(actions, {
      type = "when",
      action = func,
      condition = boolFunc,
      wasTrue = false
    })

    return self
  end

  function self.getSprite() return sprite end
  function self.getWidth() return width end
  function self.getHeight() return height end

  function self.getDuration() return duration end
  function self.setDuration(_duration)
    duration = _duration
    return self
  end

  function self.isLooping() return loop end
  function self.setLooping(_loop)
    loop = _loop
    return self
  end

  function self.isPlaying() return started and not paused and not ended end
  function self.isStarted() return started end
  function self.isPaused() return paused end
  function self.isEnded() return ended end

  function self.getCurrentTime() return currentTime end
  function self.setCurrentTime(_currentTime)
    currentTime = _currentTime
    return self
  end

  function self.getCurrentFrame() return currentFrame end
  function self.setCurrentFrame(_currentFrame)
    currentFrame = _currentFrame
    return self
  end

  function self.getCurrentQuad() return quads[currentFrame] end

  function self.addRepeatFrames(min, max, times)
    table.insert(repeatFrames, {
      min = min,
      max = max,
      times = times,
      current = 0
    })

    return self
  end

  return self
end

return class