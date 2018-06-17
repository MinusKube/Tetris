local self = {}
local utf8 = require "utf8"

function self.new(screen, _font)
  local self = require("screen/component/component").new(screen)
  self.setStyle(require("screen/component/style/textInputStyle").new())
  
  local focused = false
  local enabled = true
  
  local label = require("screen/component/labelComponent").new(screen, "", _font)
    .setAlign("center-x center-y")
    .setShadowed(false)
  
  local width, height = 300, 60
  
  local currentStyle = self.getStyle().default
  
  local superUpdate = self.update
  local superRender = self.render
  local superTextInput = self.textInput
  local superKeyPressed = self.keyPressed
  
  local function updateLabel()
    label.setStyle(currentStyle.label.style)
  end
  
  local wasDown = false
  function self.update(dt)
    superUpdate(dt)
    
    if enabled then
      local mx = screen.getGame().getMouseX()
      local my = screen.getGame().getMouseY()
      
      if not wasDown and love.mouse.isDown(1) then
        if  mx >= self.getX() - width / 2 and
            mx <= self.getX() + width / 2 and
            my >= self.getY() - height / 2 and
            my <= self.getY() + height / 2 then
              
          focused = true
        else
          focused = false
        end
      end
      
      wasDown = love.mouse.isDown(1)
    end
    
    if not enabled then
      currentStyle = self.getStyle().disabled
    elseif focused then
      currentStyle = self.getStyle().focused
    else
      currentStyle = self.getStyle().default
    end
    
    updateLabel()
    label.update()
  end
  
  function self.textInput(text)
    superTextInput(text)
    
    if enabled and focused then
      label.setText(label.getText() .. text)
    end
  end
  
  function self.keyPressed(key, code, isRepeat)
    superKeyPressed(key, code, isRepeat)
    
    if key ~= "backspace" then return end
    
    if enabled and focused then
      local offset = utf8.offset(label.getText(), -1)
      
      if offset then
        label.setText(label.getText():sub(1, offset - 1))
      end
    end
  end
  
  function self.render()
    superRender()
    
    local offset = currentStyle.label.offset
    
    self.drawObject(currentStyle.background, -width / 2, -height / 2, width, height, currentStyle.backgroundColor)
        
    love.graphics.push()
      
      love.graphics.translate(label.getPosition().x + offset.x, label.getPosition().y + offset.y)
      label.render()
      
    love.graphics.pop()
  end
  
  function self.getLabel() return label end
  
  function self.isFocused() return focused end
  function self.setFocused(_focused)
    focused = _focused
    return self
  end
  
  function self.isEnabled() return enabled end
  function self.setEnabled(_enabled)
    enabled = _enabled
    return self
  end
  
  function self.getWidth() return width end
  function self.setWidth(_width)
    width = _width
    return self
  end
  
  function self.getHeight() return height end
  function self.setHeight(_height)
    height = _height
    return self
  end
  
  return self
end

return self