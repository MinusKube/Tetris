local self = {}

function self.new()
  local self = require("screen/component/style/buttonStyle").new()
  
  self.default.background = nil
  self.hovered.background = nil
  self.pressed.background = nil
  self.disabled.background = nil
  
  self.default.label.style.color = { 0, 0, 0 }
  self.hovered.label.style.color = { 0, 0, 0 }
  self.pressed.label.style.color = { 0, 0, 0 }
  
  return self
end

return self