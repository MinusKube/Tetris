local class = {}

local bonus = {}
local malus = {}

function class.new(grid, time)
  local self = {}

  local state = 0
  local ended = false

  function self.start()
    ended = false
  end

  function self.update(dt)
    state = state + dt

    if state >= time then
      state = 0
      self.stop()
    end
  end

  function self.stop()
    ended = true
  end

  function self.isEnded() return ended end

  return self
end

function class.randomBonus(grid)
  local random = math.random(#bonus)
  return bonus[random].new(grid)
end

function class.randomMalus(grid)
  local random = math.random(#malus)
  return malus[random].new(grid)
end

table.insert(malus, require("level/special/speedSpecial"))

return class