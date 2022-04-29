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
    local instance = Instance(obj)
    if methods.init then 
      methods.init.bind(instance).call(interpret, arguments)
    end
    return Instance(obj)
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