-- read, evaluate, print loop for Lox
-- Rollins Baird

package.path = package.path .. '?.lua'

-- local scanner = require 'scanner'
-- local parse = require 'parse'
-- local Interpreter = require 'Interpreter'
-- local Resolver = require 'Resolver'

local interpreter
local resolver

local has_error, has_runtime_error

local function run(code)
  -- local tokens = scan(code, gen_error)
  if has_error then return end
  -- local statements = parse(tokens, parse_error)
  if has_error then return end
  -- interpreter.interpret(statements)
  if has_runtime_error then return end
end

local function repl()
  while true do
    io.write('> ')
    local code = io.read()
    if not code then
      print()
      return
    end
    run(code)
    error = false
  end
end

-- interpreter = Interpreter(runtime_error)
-- resolver = Resolver(interpreter, resolution_error)

repl()