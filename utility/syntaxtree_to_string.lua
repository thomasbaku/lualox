local switch = require 'utility.switch'

local function parenthesize(...)
  return '('..table.concat({...}, ' ')..')'
end

local function visit(node)
  return switch(node.class, {
    unary = function ()
      return parenthesize(node.operator.lexeme, visit(node.left))
    end,
    binary = function()
      return parenthesize(node.operator.lexeme, visit(node.left), visit(node.right))
    end,
    grouping = function ()
      return parenthesize('group', visit(node.expression))
    end,
    literal = function()
      return tostring(node.value)
    end
  })
end

return visit