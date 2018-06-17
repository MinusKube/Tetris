local class = {}

function class.new(game)
  local self = {}

  local components = {}

  function self.init() end

  function self.add(...)
    local args = { ... }

    for i = 1, #args do
      table.insert(components, args[i])
    end
  end

  function self.update(dt)
    for i = 1, #components do
      components[i].update(dt)
    end
  end

  function self.render()
    for i = 1, #components do
      love.graphics.push()
        local component = components[i]

        love.graphics.translate(component.getPosition().x, component.getPosition().y)
        component.render()
      love.graphics.pop()
    end
  end

  function self.textInput(text)
    for i = 1, #components do
      components[i].textInput(text)
    end
  end

  function self.keyPressed(key, code, isRepeat)
    for i = 1, #components do
      components[i].keyPressed(key, code, isRepeat)
    end
  end

  function self.dropFile(directory, path) end
  function self.focus(focus) end
  function self.visible(visible) end
  function self.keyPressed(key, scanCode, isRepeat) end
  function self.keyReleased(key, scanCode) end
  function self.mouseFocus(focus) end
  function self.mouseMoved(x, y, dx, dy, touch) end
  function self.mousePressed(x, y, button, touch) end
  function self.mouseReleased(x, y, button, touch) end
  function self.wheelMoved(x, y) end
  function self.textEdited(text, start, length) end
  function self.textInput(text) end
  function self.touchMoved(id, x, y, dx, dy, pressure) end
  function self.touchPressed(id, x, y, dx, dy, pressure) end
  function self.touchReleased(id, x, y, dx, dy, pressure) end

  function self.getComponents() return components end
  function self.getGame() return game end

  return self
end

return class