local self = {}

function self.new()
  local self = require("screen/component/style/buttonStyle").new()
  
  self.default.background = love.graphics.newImage("resources/textures/gui/components/button.png")
  self.hovered.background = love.graphics.newImage("resources/textures/gui/components/buttonHovered.png")
  self.pressed.background = love.graphics.newImage("resources/textures/gui/components/buttonPressed.png")
  self.disabled.background = love.graphics.newImage("resources/textures/gui/components/buttonDisabled.png")

  self.default.label.style.color = { 255, 255, 255 }
  self.hovered.label.style.color = { 255, 255, 255 }
  self.pressed.label.style.color = { 255, 255, 255 }
  self.disabled.label.style.color = { 100, 100, 100 }

  self.default.label.offset.y = -2
  self.hovered.label.offset.y = -2
  self.pressed.label.offset.y = 2
  self.disabled.label.offset.y = -2
  
  return self
end

return self