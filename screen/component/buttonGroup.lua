local class = {}

local settings = require("settings")

function class.new(settingName)
  local self = {}

  local buttons = {}
  local selected = tonumber(settings.get(settingName))

  function self.forEach(func)
    for _, button in ipairs(buttons) do
      func(button)
    end
  end

  function self.add(button)
    return table.insert(buttons, button)
  end

  function self.remove(index)
    table.remove(buttons, index)
  end

  function self.getButtons() return buttons end

  function self.getSelectedButton() return buttons[selected] end
  function self.setSelectedButton(button)
    for index, btn in ipairs(buttons) do
      if button == btn then
        self.setSelected(index)
        break
      end
    end

    return self
  end

  function self.getSelected() return selected end
  function self.setSelected(_selected)
    selected = _selected

    settings.set(settingName, selected)
    settings.save()

    return self
  end

  return self
end

return class