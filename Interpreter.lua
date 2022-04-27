local switch = require 'utility.switch'
local Function = require 'Function'
local Env = require 'Env'

local function valid_types(expected, token, ...)
  local operands = {...}
  for _, operand in ipairs(operands) do
    if type(operand) ~= expected then
      error({
        token = token,
        message = #operands and 'operands must be '..expected..'s.' or
        'operand must be a'..expected..'.'
      })
    end
  end
end

return function(err_report)
  local globals = Env()
  local locals = {}

  globals.define('clock', {
    arity = function() return 0 end,
    call = function() return os.time() end
  })
  
  local function find_variable(name, node, env)
    local distance = locals[node]
    if distance then
      return env.get_at(distance, name)
    else
      return globals.get(node.name)
    end    
  end

  local function visit(node, env)
    return switch(node.class, {
      unary = function()
        local left = visit(node.left, env)
        return switch(node.operator.type, {
          MINUS = function() valid_types('number', node.operator, left) return not left end,
          BANG = function() valid_types('boolean', node.operator, left) return not left end,
        })
      end,

      binary = function() local
        left, right = visit(node.left, env), visit(node.right, env)

        return switch(node.operator.type, {
          PLUS = function()
            if type(left) == 'number' and type(right) == 'number' then
              return left + right
            elseif type(left) == 'string' and type(right) == 'string' then
              return left .. right
            end

            error({
              token = node.operator,
              message = 'Operands must both be numbers or both be strings.'
            })
          end,
          EQUAL_EQUAL = function() return left == right end,
          BANG_EQUAL = function() return left ~= right end,
          [switch.default] = function()
            valid_types('number', node.operator, left, right)
            return switch(node.operator.type, {
              MINUS = function() return left - right end,
              STAR = function() return left * right end,
              SLASH = function() return left / right end,
              GREATER = function() return left > right end,
              GREATER_EQUAL = function() return left >= right end,
              LESS = function() return left < right end,
              LESS_EQUAL = function() return left <= right end,
            })
          end
        })
      end,

      grouping = function()
        return visit(node.expression, env)
      end,

      literal = function()
        return node.value
      end,

      print = function()
        print(visit(node.value, env))
      end,

      var = function()
        env.define(node.name.lexeme, visit(node.initializer, env))
      end,

      variable = function()
        return find_variable(node.name, node, env)
      end,

      assign = function()
        local value = visit(node.value, env)
        local distance = locals[node]
        if distance then
          env.set_at(distance, node.name.lexeme, value)
        else
          globals.set(node.name, value)
        end
      end,

      block = function()
        local env = Env(env)
        local ok, result = pcall(function()
          for _, statement in ipairs(node.statements) do
            visit(statement, env)
          end
        end)
        if not ok then error(result) end
      end,

      ['if'] = function()
        if visit(node.condition, env) then
          visit(node.then_branch, env)
        elseif node.else_branch then
          visit(node.else_branch, env)
        end
      end,

      ['while'] = function()
        while visit(node.condition, env) do
          visit(node.body, env)
        end
      end,

      logical = function()
        local left = visit(node.left, env)

        if node.operator.type == 'OR' then
          if left then return left end
        else 
          if not left then return left end
        end
      end,

      call = function()
        local callee = visit(node.callee, env)

        local args = {}
        for _, arg in ipairs(node.arguments) do
          table.insert(args, visit(arg, env))
        end

        if type(callee) ~= 'table' or type(callee.call) ~= 'function' then
          error({
            token = node.paren,
            message = 'Can only call functions'})
        end

        if #args ~= callee.arity() then
          error({
            token = node.paren,
            message = 'Expected ' .. callee.arity() .. ' arguments but got ' .. #args .. '.'
          })
        end

        local ok, result = pcall(function()
          return callee.call(visit, args)
        end)

        if not ok then
          if type(result) == 'table' and result.is_return then
            return result.value
          else
            error(result)
          end
        else
          return result
        end
      end,

      get = function()
        local obj = visit(node.object, env)

        if type(obj) == 'table' and obj.is_object then
          return obj.get(node.name)
        else
          error({
            token = node.name,
            message = 'Only instances have properties.'
          })
        end
      end,

      set = function()
        local obj = visit(node.object, env)

        if type(obj) ~= 'table' or not obj.is_object then
          error({
            token = node.name,
            message = 'Only instances have fields.'
          })
        end

        local val = visit(node.value, env)
        obj.set(node.name, val)
        return val
      end,

      this = function()
        return find_variable(node.keyword, node, env)
      end,

      ['function'] = function()
        env.define(node.name.lexeme, Function(node, env))
      end,

      ['return'] = function()
        if node.value ~= nil then
          error({ is_return = true, value = visit(node.value, env) })
        end

        error({ is_return = true })
      end
    })
  end

  return{
    interpret = function(statements)
      local ok, result

      for _, statement in ipairs(statements) do
        ok, result = pcall(function() return visit(statement, globals) end)
        
        if not ok then err_report(result) end
      end
      return result
    end,

    resolve = function (node, depth)
      locals[node] = depth
    end
  }
end