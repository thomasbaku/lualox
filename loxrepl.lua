-- Rollins Baird
-- read, evaluate, print loop for Lox
-- can also run from a file

-- based on: https://craftinginterpreters.com/
-- great resource for learning Lua (or almost any other language): https://learnxinyminutes.com/docs/lua/
-- it was helpful to look at the books Java implementation of this feature: https://github.com/munificent/craftinginterpreters/blob/master/java/com/craftinginterpreters/lox/Lox.java
-- also found this implementation helpful and used it to test Lox code: https://github.com/1Hibiki1/locks-py
-- also a solid implementation that was helpful when figuring out trickier bits: https://github.com/ryanplusplus/llox

package.path = package.path .. ';src/?.lua'

local scanner = require 'scanner'
local parser = require 'parser'
local Interpreter = require 'interpret.interpreter'
local Resolver = require 'resolver'

local interpreter
local resolver

local has_error, has_runtime_error

-- functions for different types of errors
local function report_err(line, where, message)
  io.stderr:write('line: '..line..' Error'..where..': '..message..'\n')
  has_error = true
end

local function gen_err(line, message)
  report_err(line, '', message)
end

local function parser_err(token, message)
  if token.type == 'EOF' then
    report_err(token.line, ' at end', message)
  else
    report_err(token.line, " at '"..token.lexeme.."'", message)
  end
end

local function resolve_err(err)
  report_err(err.token.line, " at '"..err.token.lexeme.."'", err.message)
end

local function run_err(err)
  print(err)
  io.stderr.write(err.message..'\nline: '..err.token.line..'\n')
end

-- takes in code as text and passes it to the scanner, parser, and interpreter
local function run(code)
  local tokens = scanner(code, gen_err)
  if has_error then return end
  local statements = parser(tokens, parser_err)
  if has_error then return end
  resolver.resolve(statements)
  if has_error then return end
  interpreter.interpret(statements)
  if has_runtime_error then return end
end

-- given a file path runs the Lox code inside it
local function eval_file(path)
  local file = io.open(path, 'r')
  assert(file, 'file: '..path..' not found')
  local code = file:read('*all')
  file:close()
  run(code)
  if has_error then os.exit(65) end
  if has_runtime_error then os.exit(70) end
end

-- continually prompts user for input and evaluates it
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

interpreter = Interpreter(run_err)
resolver = Resolver(interpreter, resolve_err)

-- reads from file, user, or prints instructions
if #arg > 1 then
  print('Use with: lox [optional file path]')
elseif #arg == 1 then
  eval_file(arg[1])
else
  repl()
end