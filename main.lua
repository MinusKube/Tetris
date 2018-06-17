local game = require("game")

function love.load()
  require("util/stringUtils")

  math.randomseed(os.time())
  love.graphics.setDefaultFilter("nearest", "nearest")

  love.window.setIcon(love.image.newImageData("resources/icon.png"))

  game.load()
end

function love.update(dt) game.update(dt) end
function love.draw() game.render() end
function love.resize(width, height) game.resize(width, height) end

function love.threadError(thread, error)
  print("Thread error!\n" .. error)
end

function love.directorydropped(path) game.getScreen().dropFile(true, path) end
function love.filedropped(file) game.getScreen().dropFile(false, file) end

function love.focus(focus) game.getScreen().focus(focus) end
function love.visible(visible) game.getScreen().visible(visible) end

function love.keypressed(key, scanCode, isRepeat) game.getScreen().keyPressed(key, scanCode, isRepeat) end
function love.keyreleased(key, scanCode) game.getScreen().keyReleased(key, scanCode) end

function love.mousefocus(focus) game.getScreen().mouseFocus(focus) end
function love.mousemoved(x, y, dx, dy, touch) game.getScreen().mouseMoved(x, y, dx, dy, touch) end
function love.mousepressed(x, y, button, touch) game.getScreen().mousePressed(x, y, button, touch) end
function love.mousereleased(x, y, button, touch) game.getScreen().mouseReleased(x, y, button, touch) end
function love.wheelmoved(x, y) game.getScreen().wheelMoved(x, y) end

function love.textedited(text, start, length) game.getScreen().textEdited(text, start, length) end
function love.textinput(text) game.getScreen().textInput(text) end

function love.touchmoved(id, x, y, dx, dy, pressure) game.getScreen().touchMoved(id, x, y, dx, dy, pressure) end
function love.touchpressed(id, x, y, dx, dy, pressure) game.getScreen().touchPressed(id, x, y, dx, dy, pressure) end
function love.touchreleased(id, x, y, dx, dy, pressure) game.getScreen().touchReleased(id, x, y, dx, dy, pressure) end