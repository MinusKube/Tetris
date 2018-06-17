local self = {}

function self.new()
  local self = require("screen/component/style/style").new()
  
  self.color = { 255, 255, 255 }
  self.shadow = {
    color = { 30, 30, 30 },
    offset = { x = 2, y = 2 }
  }
  
  return self
end

return self