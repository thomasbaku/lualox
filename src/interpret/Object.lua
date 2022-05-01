-- Rollins Baird
-- creates and stores objects

-- based on: https://craftinginterpreters.com/
-- great resource for learning Lua (or almost any other language): https://learnxinyminutes.com/docs/lua/
-- it was helpful to look at the books Java implementation of this feature: https://github.com/munificent/craftinginterpreters/blob/master/java/com/craftinginterpreters/lox/LoxInstance.java
-- also found this implementation helpful and used it to test Lox code: https://github.com/1Hibiki1/locks-py
-- also a solid implementation that was helpful when figuring out trickier bits: https://github.com/ryanplusplus/llox

return function(name, scope, methods)
  local obj = setmetatable({},{
    __tostring = function () return name end
  })

  obj.is_class = true

  obj.name = name

  obj.arity = function()
    return methods.init and methods.init.arity() or 0
  end

  obj.call = function(interpret, arguments)
    local instance = instance(obj)
    if methods.init then 
      methods.init.bind(instance).call(interpret, arguments)
    end
    return instance(obj)
  end

  obj.find_method = function (instance, name)
    if methods[name] then 
      return methods[name].bind(instance)
    end
    if scope then
      return scope.find_method(instance, name)
    end
  end

  return obj
end