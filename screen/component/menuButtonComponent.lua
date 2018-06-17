local class = {}

function class.new(group, screen, label, font)
  local buttonComponentClass = require("screen/component/buttonComponent")
  local self = buttonComponentClass.new(screen, label, font)
    .setAlign("left center-y")

  local style = require("screen/component/style/menuButtonStyle").new()
  self.setStyle(style)

  group.add(self)

  local super = {
    update = self.update,
    render = self.render,
    click = self.click
  }

  function self.update(dt)
    super.update(dt)

    if self.getWidth() ~= 400 and group.getSelectedButton() == self then
      self.setWidth(400)
      super.update(0)
    elseif self.getWidth() ~= 250 and group.getSelectedButton() ~= self then
      self.setWidth(250)
      super.update(0)
    end
  end

  function self.render()
    super.render()
  end

  function self.click()
    super.click()

    group.setSelectedButton(self)
  end

  return self
end

return class