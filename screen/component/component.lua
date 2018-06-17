local self = {}

function self.new(screen)
  local self = {}
  
  local style = require("screen/component/style/style").new()
  
  local position = {
    x = 0,
    y = 0
  }
  
  function self.update(dt) end
  function self.render() end
  function self.textInput(text) end
  function self.keyPressed(key, code, isRepeat) end
  
  function self.drawObject(obj, x, y, width, height, color)
    if color == nil then color = { 255, 255, 255 } end
    
    if obj ~= nil then
      if type(obj) == "table" then
        love.graphics.setColor(obj)
        love.graphics.rectangle("fill", x, y, width, height)
      else
        love.graphics.setColor(color)
        love.graphics.draw(obj, x, y, 0, width / obj:getWidth(), height / obj:getHeight())
      end
    end
  end
  
  function self.getStyle() return style end
  function self.setStyle(_style)
    style = _style
    self.update(0)
    
    return self
  end
  
  function self.getX() return position.x end
  function self.getY() return position.y end
  
  function self.getPosition() return position end
  
  function self.setPosition(x, y)
    position = { x = x, y = y }
    self.update(0)
    
    return self
  end
  
  return self 
end

return self