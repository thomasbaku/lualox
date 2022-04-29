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

return Function

-- local function Instance(obj)
--   local vals = {}

--   local fun = setmetatable({}, {
--     __tostring=function ()
--       return obj.name
--     end
--   })

--   fun.is_object = true

--   fun.get = function(name)
--     if vals[name.lexeme] then return vals[name.lexeme] end

--     local method = obj.find_method(fun, name.lexeme)
--     if method then return method end

--     error({
--       token = name,
--       message = name.lexeme .. " is undefined"
--     })
--   end

--   fun.set = function (name, value)
--     vals[name.lexeme] = value
--   end

--   return fun
-- end

-- local function Class(name, scope, methods)
--   local obj = setmetatable({},{
--     __tostring = function () return name end
--   })

--   obj.is_class = true

--   obj.name = name

--   obj.arity = function()
--     return methods.init and methods.init.arity() or 0
--   end

--   obj.call = function(interpret, arguments)
--     local instance = Instance(obj)
--     if methods.init then 
--       methods.init.bind(instance).call(interpret, arguments)
--     end
--     return Instance(obj)
--   end

--   obj.find_method = function (instance, name)
--     if methods[name] then 
--       return methods[name].bind(instance)
--     end
--     if scope then
--       return scope.find_method(instance, name)
--     end
--   end

--   return obj
-- end