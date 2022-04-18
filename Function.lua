-- class that defines & calls functions
-- Rollins Baird

local Env = require 'Env'

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