local Env = require 'Env'

local function Function(node, env, is_init)
  return setmetatable({
    arity = function ()
      return #node.parameters
    end,

    call = function (interpret, arguments)
      local env = Env(env)
      for i = 1, #node.parameters do
        env.define(node.parameters[i].lexeme, arguments[i])
      end
      interpret(node.body, env)
      if is_initalizer then return env.get_at(0, 'this') end
    end,

    bind = function (instance)
      local env = Env(env)
      env.define('this', instance)
      return Function(node, env, is_initalizer)
    end
  }, {
    __tostring = function ()
      return '<fn '..node.name.lexeme..'>'
    end
  })
end