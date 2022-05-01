-- Rollins Baird
-- creates and returns a Lox enviroment

-- based on: https://craftinginterpreters.com/
-- great resource for learning Lua (or almost any other language): https://learnxinyminutes.com/docs/lua/
-- it was helpful to look at the books Java implementation of this feature: https://github.com/munificent/craftinginterpreters/blob/master/java/com/craftinginterpreters/lox/Environment.java
-- also found this implementation helpful and used it to test Lox code: https://github.com/1Hibiki1/locks-py
-- also a solid implementation that was helpful when figuring out trickier bits: https://github.com/ryanplusplus/llox

return function (parent)
  local defined = {}
  local values = {}

  local self

  self = {
    define = function (name, value)
      defined[name] = true
      values[name] = value
    end,
    
    get = function (name)
      if defined[name.lexeme] then
        return values[name.lexeme]
      elseif parent then
        return parent.get(name.lexeme)
      else
        error({token = name, message = "Undefined variable '"..name.lexeme.."'."})
      end
    end,

    get_at = function (distance, name)
      if type(name) == 'string' then
        name = {lexeme = name}
      end

      local env = self
      for i = 1, distance do
        env = env.parent
      end
      return env.values[name.lexeme]
    end,

    set = function (name, value)
      if defined[name.lexeme] then
        values[name.lexeme] = value
      elseif parent then
        parent.set(name.lexeme, value)
      else
        error({token = name, message = "Undefined variable '"..name.lexeme.."'."})
      end
    end,
    
    set_at = function (distance, name, value)
      local env = self
      for i = 1, distance do
        env = env.parent
      end
      env.values[name] = value
    end,

    has = function (name)
      if defined[name] then
        return true
      elseif parent then
        return parent.has(name)
      else
        return false
      end
    end,

    parent = parent,
    values = values
  }

  return self
end