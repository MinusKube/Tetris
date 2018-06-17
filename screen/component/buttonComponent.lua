local self = {}

local sounds = require("sounds")

function self.new(screen, _label, _font)
  local self = require("screen/component/component").new(screen)
  self.setStyle(require("screen/component/style/buttonStyle").new())
  
  local label = require("screen/component/labelComponent").new(screen, _label, _font)
    .setShadowed(false)
    
  local labelAlign = "center-x center-y"
  
  local superUpdate = self.update
  local superRender = self.render
  
  local width, height = 300, 60
  local onClick
  
  local enabled = true
  local hovered = false
  local pressed = false

  local buttonAlign = "center"

  local currentStyle = self.getStyle().default
  local aabb
  
  local function updateLabel()
    label.setPosition(-width / 2, -height / 2)
      .setAlign(labelAlign)
      .setStyle(currentStyle.label.style)
  end
    
  local wasDown = false
  function self.update(dt)
    superUpdate(dt)
    
    if enabled then
      local wasHovered = hovered

      hovered = aabb.isHovered(screen.getGame())
      
      if hovered then
        if not wasHovered then
          sounds.play(screen.getGame(), "buttonHover")
        end

        if (pressed or not wasDown) and love.mouse.isDown(1) then
          if not pressed then
            sounds.play(screen.getGame(), "buttonDown")
          end

          pressed = true
        else
          if pressed then self.click() end
          
          pressed = false
        end
      else
        pressed = false
      end
      
      wasDown = love.mouse.isDown(1)
    end
    
    if not enabled then
      currentStyle = self.getStyle().disabled
    elseif pressed then
      currentStyle = self.getStyle().pressed
    elseif hovered then
      currentStyle = self.getStyle().hovered
    else
      currentStyle = self.getStyle().default
    end
    
    updateLabel()
    label.update(dt)
  end
  
  function self.render()
    superRender()
    
    local aligned = self.getLabelAlignedPos()
    local x, y = aligned.x, aligned.y
    local offset = currentStyle.label.offset

    local btnX, btnY

    if buttonAlign == "center" then
      btnX = -width / 2
      btnY = -height / 2
    elseif buttonAlign == "left" then
      btnX = 0
      btnY = 0
    elseif buttonAlign == "right" then
      btnX = -width
      btnY = 0
    end

    self.drawObject(currentStyle.background, btnX, btnY, width, height, currentStyle.backgroundColor)
    
    love.graphics.push()
      love.graphics.translate(btnX + width / 2 + label.getPosition().x + x + offset.x,
        btnY + height / 2 + label.getPosition().y + y + offset.y)

      label.render()
    love.graphics.pop()
  end
  
  function self.getLabelAlignedPos()
    local x, y = 0, 0
    local w, h = width, height
    
    if labelAlign:match("left")      ~= nil then x = 0     end
    if labelAlign:match("top")       ~= nil then y = 0     end
    if labelAlign:match("center%-x") ~= nil then x = w / 2 end
    if labelAlign:match("center%-y") ~= nil then y = h / 2 end
    if labelAlign:match("right")     ~= nil then x = w     end
    if labelAlign:match("bottom")    ~= nil then y = h     end
    
    return { x = x, y = y }
  end
  
  function self.getLabel() return label end
  function self.setLabel(_label)
    label = _label
    self.update(0)
    
    return self
  end
  
  function self.getWidth() return width end
  function self.setWidth(_width)
    width = _width
    self.updateAABB()
    
    return self
  end
  
  function self.getHeight() return height end
  function self.setHeight(_height)
    height = _height
    self.updateAABB()
    
    return self
  end
  
  function self.getAlign() return labelAlign end
  function self.setAlign(_labelAlign)
    labelAlign = _labelAlign
    self.updateAABB()
    self.update(0)
    
    return self
  end
  
  function self.isEnabled() return enabled end
  function self.setEnabled(_enabled)
    enabled = _enabled
    self.updateAABB()
    self.update(0)
    
    return self
  end
  
  local superSetPosition = self.setPosition
  function self.setPosition(x, y)
    local value = superSetPosition(x, y)
    
    self.updateAABB()
    
    return value
  end
  
  function self.updateAABB()
    if buttonAlign == "center" then
      aabb = require("util/collision/aabb").new({
        x = self.getPosition().x - width / 2,
        y = self.getPosition().y - height / 2 }, {
        x = self.getPosition().x + width / 2,
        y = self.getPosition().y + height / 2
      })
    elseif buttonAlign == "left" then
      aabb = require("util/collision/aabb").new({
        x = self.getPosition().x,
        y = self.getPosition().y }, {
        x = self.getPosition().x + width,
        y = self.getPosition().y + height
      })
    elseif buttonAlign == "right" then
      aabb = require("util/collision/aabb").new({
        x = self.getPosition().x - width,
        y = self.getPosition().y }, {
        x = self.getPosition().x,
        y = self.getPosition().y + height
      })
    end
  end
  
  function self.isHovered() return hovered end
  function self.isPressed() return pressed end
  
  function self.click()
    if onClick ~= nil then
      onClick()
    end
  end
  
  function self.onClick(_onClick)
    onClick = _onClick
    return self
  end

  function self.getButtonAlign() return buttonAlign end
  function self.setButtonAlign(_buttonAlign)
    buttonAlign = _buttonAlign
    self.updateAABB()
    self.update(0)

    return self
  end
  
  self.updateAABB()
  self.update(0)
  return self
end

return self