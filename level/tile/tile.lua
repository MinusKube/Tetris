local class = {}

function class.new(imageName, color)
  local self = {}

  local image = love.graphics.newImage("resources/textures/tiles/" .. imageName .. ".png")

  function self.render(color)
    love.graphics.setColor(color or { 255, 255, 255 })
    love.graphics.draw(image, 0, -7, 0, 0.75, 0.75)
  end

  function self.renderGhost()
    love.graphics.setColor(color[1], color[2], color[3], 20)
    love.graphics.rectangle("fill", 0, 0, 48, 48)

    love.graphics.setColor(color)
    love.graphics.rectangle("line", 0, 0, 48, 48)
  end

  function self.getImage() return image end

  return self
end

return class