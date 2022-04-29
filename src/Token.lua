-- Scanning Token class
-- Thomas Hampton
-- similar implentation to https://github.com/ryanplusplus/llox/

return function(type, lexeme, literal, line)
  -- create metatable for token types
  return setmetatable(
  -- table
  {
    type = type,
    lexeme = lexeme,
    literal = literal,
    line = line
  },
  -- metatable
  {
    __tostring = function()
      return type .. ' ' .. lexeme .. ' ' .. (literal or '')
    end
  })
end
