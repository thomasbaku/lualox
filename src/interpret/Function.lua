-- Rollins Baird
-- class that defines & calls functions

-- based on: https://craftinginterpreters.com/
-- great resource for learning Lua (or almost any other language): https://learnxinyminutes.com/docs/lua/
-- it was helpful to look at the books Java implementation of this feature: https://github.com/munificent/craftinginterpreters/blob/master/java/com/craftinginterpreters/lox/LoxFunction.java
-- also found this implementation helpful and used it to test Lox code: https://github.com/1Hibiki1/locks-py
-- also a solid implementation that was helpful when figuring out trickier bits: https://github.com/ryanplusplus/llox

local Env = require 'interpret.env'

local function Function(node, env, is_init)
  return setmetatable({
    arity = function ()
      return #node.parameters
    end,

    -- runs function call
    call = function (interpret, arguments)
      local env = Env(env)
      for i = 1, #node.parameters do
        env.define(node.parameters[i].lexeme, arguments[i])
      end
      interpret(node.body, env)
      if is_init then return env.get_at(0, 'this') end
    end,

    -- binds new function to enviroment
    bind = function (instance)
      local env = Env(env)
      env.define('this', instance)
      return Function(node, env, is_init)
    end
  }, {
    __tostring = function ()
      return '<fn '..node.name.lexeme..'>'
    end
  })
end

return Function
