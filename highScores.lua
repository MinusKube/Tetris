local class = {}
local http = require("socket.http")

local baseUrl = "http://minuskube.fr/projects/tetris.php"
local scores

function class.load(mode)
  scores = {}

  local response = http.request(baseUrl .. "?mode=" .. mode)

  for mode, name, score, time in string.gmatch(response, "(%w+)/(%w+)/(%d+)/(%d+)") do
    if scores[mode] == nil then
      scores[mode] = {}
    end

    table.insert(scores[mode], {
      name = name,
      score = score,
      time = time
    })
  end
end

function class.isLoaded(mode)
  return scores[mode] ~= nil
end

function class.getHighScores(mode)
  return scores[mode] or {}
end

function class.addHighScore(mode, name, score, time)
  scores = {}

  local response = http.request(baseUrl .. "?name=" .. name
          .. "&score=" .. score
          .. "&time=" .. time
          .. "&mode=" .. mode)

  for mode, name, score, time in string.gmatch(response, "(%w+)/(%w+)/(%d+)/(%d+)") do
    if scores[mode] == nil then
      scores[mode] = {}
    end

    table.insert(scores[mode], {
      name = name,
      score = score,
      time = time
    })
  end
end

return class