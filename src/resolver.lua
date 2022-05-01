-- Rollins Baird

-- based on: https://craftinginterpreters.com/
-- great resource for learning Lua (or almost any other language): https://learnxinyminutes.com/docs/lua/
-- it was helpful to look at the books Java implementation of this feature: https://github.com/munificent/craftinginterpreters/blob/master/java/com/craftinginterpreters/lox/Resolver.java
-- also found this implementation helpful and used it to test Lox code: https://github.com/1Hibiki1/locks-py
-- also a solid implementation that was helpful when figuring out trickier bits: https://github.com/ryanplusplus/llox

local switch = require 'utility.switch'

return function(interpreter, error_reporter)
  local scopes = {}
  local current_function = 'none'
  local current_class = 'none'

  local function begin_scope()
    table.insert(scopes, {})
  end

  local function end_scope()
    table.remove(scopes)
  end

  local function declare(name)
    if #scopes == 0 then return end
    local scope = scopes[#scopes]
    if scope[name.lexeme] ~= nil then
      error({
        token = name,
        message = 'Variable with this name already declared in this scope.'
      })
    end
    scope[name.lexeme] = false
  end

  local function define(name)
    if #scopes == 0 then return end
    scopes[#scopes][name.lexeme] = true
  end

  local function resolve_local(node, name)
    for i = #scopes, 1, -1 do
      if scopes[i][name.lexeme] ~= nil then
        interpreter.resolve(node, #scopes - i)
        return
      end
    end
  end

  local visit

  local function resolve_function(node, type)
    local enclosing_function = current_function
    current_function = type

    begin_scope()
    for _, parameter in ipairs(node.parameters) do
      declare(parameter)
      define(parameter)
    end
    visit(node.body)
    end_scope()

    current_function = enclosing_function
  end

  visit = function(node)
    return switch(node.class, {
      block = function()
        begin_scope()
        for _, statement in ipairs(node.statements) do
          visit(statement)
        end
        end_scope()
      end,

      class = function()
        declare(node.name)
        define(node.name)

        local enclosing_class = current_class
        current_class = 'class'

        if node.parentclass then
          current_class = 'subclass'
          visit(node.parentclass)
          begin_scope()
          scopes[#scopes].parent = true
        end

        begin_scope();
        scopes[#scopes].this = true
        for _, method in ipairs(node.methods) do
          resolve_function(method, method.name.lexeme == 'init' and 'initializer' or 'method')
        end
        end_scope()

        if node.parentclass then
          end_scope()
        end

        current_class = enclosing_class
      end,

      this = function()
        if current_class == 'none' then
          error({
            token = node.keyword,
            message = "Invalid"
          })
        else
          resolve_local(node, node.keyword)
        end
      end,

      var = function()
        declare(node.name)
        if node.initializer ~= nil then
          visit(node.initializer)
        end
        define(node.name)
      end,

      variable = function()
        if #scopes > 0 and scopes[#scopes][node.name.lexeme] == false then
          error({
            token = node.name,
            message = 'Cannot read local variable in its own initializer.'
          })
        end
        resolve_local(node, node.name)
      end,

      assign = function()
        visit(node.value)
        resolve_local(node, node.name)
      end,

      ['function'] = function()
        declare(node.name)
        define(node.name)
        resolve_function(node, 'function')
      end,

      expression = function()
        visit(node.expression)
      end,

      ['if'] = function()
        visit(node.condition)
        visit(node.then_branch)
        if node.else_branch then
          visit(node.else_branch)
        end
      end,

      print = function()
        visit(node.value)
      end,

      ['return'] = function()
        if current_function == 'none' then
          error_reporter({
            token = node.keyword,
            message = 'Must be used in a function'
          })
        end

        if current_function == 'initializer' then
          error_reporter({
            token = node.keyword,
            message = 'Cannot return a value from an initializer.'
          })
        end

        visit(node.value)
      end,

      ['while'] = function()
        visit(node.condition)
        visit(node.body)
      end,

      binary = function()
        visit(node.left)
        visit(node.right)
      end,

      call = function()
        visit(node.callee)
        for _, argument in ipairs(node.arguments) do
          visit(argument)
        end
      end,

      grouping = function()
        visit(node.expression)
      end,

      literal = function()
      end,

      logical = function()
        visit(node.left)
        visit(node.right)
      end,

      unary = function()
        visit(node.left)
      end,

      get = function()
        visit(node.object)
      end,

      set = function()
        visit(node.value)
        visit(node.object)
      end,

      parent = function()
        if current_class == 'none' then
          error({
            token = node.keyword,
            message = "Invalid"
          })
        elseif current_class ~= 'subclass' then
          error({
            token = node.keyword,
            message = "Invalid"
          })
        end

        resolve_local(node, node.keyword)
      end
    })
  end

  return {
    resolve = function(statements)
      for _, statement in ipairs(statements) do
        ok, result = pcall(function()
          return visit(statement, globals)
        end)

        if not ok then error_reporter(result) end
      end
    end
  }
end
