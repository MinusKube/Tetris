local self = {}

function self.new()
  local self = require("screen/component/style/buttonStyle").new()

  self.default.background = { 100, 100, 100 }
  self.default.label.style.color = { 255, 255, 255 }

  self.pressed.background = { 80, 80, 80 }
  self.pressed.label.style.color = { 150, 150, 150 }

  self.default.label.offset.x = 10
  self.hovered.label.offset.x = 10
  self.pressed.label.offset.x = 10
  self.disabled.label.offset.x = 10
  
  return self
end

return self