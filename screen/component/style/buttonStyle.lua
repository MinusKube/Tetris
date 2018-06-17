local self = {}

function self.new()
  local self = require("screen/component/style/style").new()
  
  self.default = {
    background = { 200, 200, 200 },
    label = {
      style = require("screen/component/style/labelStyle").new(),
      offset = { x = 0, y = 0 }
    }
  }
  
  self.hovered = {
    background = { 150, 150, 150 },
    label = {
      style = require("screen/component/style/labelStyle").new(),
      offset = { x = 0, y = 0 }
    }
  }
  
  self.pressed = {
    background = { 100, 100, 100 },
    label = {
      style = require("screen/component/style/labelStyle").new(),
      offset = { x = 0, y = 0 }
    }
  }
  
  self.disabled = {
    background = { 50, 50, 50 },
    label = {
      style = require("screen/component/style/labelStyle").new(),
      offset = { x = 0, y = 0 }
    }
  }

  self.default.label.offset.x = 0
  self.hovered.label.offset.x = 0
  self.pressed.label.offset.x = 0
  self.disabled.label.offset.x = 0

  self.default.label.style.color = { 50, 50, 50 }
  self.hovered.label.style.color = { 50, 50, 50 }
  self.pressed.label.style.color = { 50, 50, 50 }
  self.disabled.label.style.color = { 120, 120, 120 }
  
  return self
end

return self