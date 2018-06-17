local class = {}

local sounds = {
  buttonHover = love.audio.newSource("resources/sounds/SFX_ButtonHover.ogg"),
  buttonDown = love.audio.newSource("resources/sounds/SFX_ButtonUp.ogg"),
  gameOver = love.audio.newSource("resources/sounds/SFX_GameOver.ogg"),
  gameStart = love.audio.newSource("resources/sounds/SFX_GameStart.ogg"),
  levelUp = love.audio.newSource("resources/sounds/SFX_LevelUp.ogg"),
  pieceFall = love.audio.newSource("resources/sounds/SFX_PieceFall.ogg"),
  pieceHardDrop = love.audio.newSource("resources/sounds/SFX_PieceHardDrop.ogg"),
  pieceLockdown = love.audio.newSource("resources/sounds/SFX_PieceLockdown.ogg"),
  pieceMoveFail = love.audio.newSource("resources/sounds/SFX_PieceTouchLR.ogg"),
  pieceMove = love.audio.newSource("resources/sounds/SFX_PieceMoveLR.ogg"),
  pieceRotateFail = love.audio.newSource("resources/sounds/SFX_PieceRotateFail.ogg"),
  pieceRotate = love.audio.newSource("resources/sounds/SFX_PieceRotateLR.ogg"),
  pieceSoftDrop = love.audio.newSource("resources/sounds/SFX_PieceSoftDrop.ogg"),
  pieceTouchDown = love.audio.newSource("resources/sounds/SFX_PieceTouchDown.ogg"),
  lineClearSingle = love.audio.newSource("resources/sounds/SFX_SpecialLineClearSingle.ogg"),
  lineClearDouble = love.audio.newSource("resources/sounds/SFX_SpecialLineClearDouble.ogg"),
  lineClearTriple = love.audio.newSource("resources/sounds/SFX_SpecialLineClearTriple.ogg"),
  lineClearTetris = love.audio.newSource("resources/sounds/SFX_SpecialTetris.ogg")
}

function class.play(game, name)
  sounds[name]:setVolume(game.getSFXVolume())

  sounds[name]:stop()
  sounds[name]:play()
end

return class