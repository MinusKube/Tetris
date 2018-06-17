local self = {}

function self.new()
  local self = require("screen/component/style/style").new()
  
  self.default = {
    background = { 100, 100, 100 },
    label = {
      style = require("screen/component/style/labelStyle").new(),
      offset = { x = 0, y = 0 }
    }
  }
  
  self.focused = {
    background = { 120, 120, 120 },
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
  
  self.disabled.label.style.color = { 100, 100, 100 }
  
  return self
end