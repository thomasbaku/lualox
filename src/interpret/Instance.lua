return function(obj)
  local vals = {}

  local fun = setmetatable({}, {
    __tostring=function ()
      return obj.name
    end
  })

  fun.is_object = true

  fun.get = function(name)
    if vals[name.lexeme] then return vals[name.lexeme] end

    local method = obj.find_method(fun, name.lexeme)
    if method then return method end

    error({
      token = name,
      message = name.lexeme .. " is undefined"
    })
  end

  fun.set = function (name, value)
    vals[name.lexeme] = value
  end

  return fun
end
