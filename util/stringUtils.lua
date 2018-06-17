function string.split(self, delimiter)
  local array = {}

  for str in self:gmatch("[^" .. delimiter .. "]+") do
    table.insert(array, str)
  end

  return array
end