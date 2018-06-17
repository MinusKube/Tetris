local class = {}

function class.new(manager)
  local self = {}

  local selectors = {}

  function self.update(dt)
    local bestPriority = 0
    local bestSelected

    for _, selector in ipairs(selectors) do
      local result = selector.select()

      if bestPriority < selector.priority and result ~= nil then
        bestPriority = selector.priority
        bestSelected = result
      end
    end

    manager.setCurrentAnimation(bestSelected)
  end

  function self.clear()
    selectors = {}
  end

  function self.select(priority, func)
    table.insert(selectors, {
      priority = priority,
      select = func
    })

    return self
  end

  function self.getManager() return manager end

  return self
end

return class