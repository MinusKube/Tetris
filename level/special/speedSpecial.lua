local class = {}

function class.new(grid)
  local specialClass = require("level/special/special")
  local self = specialClass.new(grid, 5)

  local super = {
    start = self.start,
    stop = self.stop
  }

  function self.start()
    super.start()

    grid.setSpeed(2.5)
  end

  function self.stop()
    super.stop()

    grid.setSpeed(1)
  end

  function self.getName() return "speed" end

  return self
end

return class