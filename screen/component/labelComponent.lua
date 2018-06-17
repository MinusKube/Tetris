local self = {}

function self.new(screen, _label, _font)
  local self = require("screen/component/component").new(screen)
  self.setStyle(require("screen/component/style/labelStyle").new())

  local defaultFont = love.graphics.newFont(20)

  local label = love.graphics.newText(_font or defaultFont, _label)
  local text = _label
  
  local shadowed = true
  local align = "top left"
  
  local superRender = self.render

  function self.render()
    superRender()
    
    local aligned = self.getAlignedPos()
    local x, y = aligned.x, aligned.y

    if shadowed then
      love.graphics.setColor(self.getStyle().shadow.color)
      love.graphics.draw(label, x + self.getStyle().shadow.offset.x, y + self.getStyle().shadow.offset.y)
    end

    love.graphics.setColor(self.getStyle().color)
    love.graphics.draw(label, x, y)
  end
  
  function self.getTopY() return label:getFont():getHeight() / 2 + label:getFont():getDescent() end
  function self.getBottomY() return label:getFont():getBaseline() end
  
  function self.getWidth() return label:getWidth() end
  function self.getHeight() return self.getBottomY() - self.getTopY() end
  
  function self.getAlignedPos()
    local x, y = 0, -self.getTopY()
    local w, h = label:getWidth(), self.getBottomY() - self.getTopY()
    
    if align:match("left")      ~= nil then x = 0                       end
    if align:match("top")       ~= nil then y = -self.getTopY()         end
    if align:match("center%-x") ~= nil then x = -w / 2                  end
    if align:match("center%-y") ~= nil then y = -self.getTopY() - h / 2 end
    if align:match("right")     ~= nil then x = -w                      end
    if align:match("bottom")    ~= nil then y = -self.getBottomY()      end
    
    return { x = x, y = y }
  end
  
  function self.getText() return text end
  function self.setText(_text)
    text = _text
    label:set(text)
    
    self.update()
    
    return self
  end
  
  function self.getLabel() return label end
  function self.setLabel(_label)
    label = _label
    self.update()
    
    return self
  end
  
  function self.getAlign() return align end
  function self.setAlign(_align)
    align = _align
    self.update()
    
    return self
  end
  
  function self.isShadowed() return shadowed end
  function self.setShadowed(_shadowed)
    shadowed = _shadowed
    self.update()
    
    return self
  end

  return self
end

return self