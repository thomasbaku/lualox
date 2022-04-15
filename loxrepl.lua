-- read, evaluate, print loop for Lox
-- Rollins Baird

package.path = package.path .. '?.lua'

-- local scanner = require 'scanner'
-- local parse = require 'parse'
local Interpreter = require 'Interpreter'
-- local Resolver = require 'Resolver'

local interpreter
local resolver

local has_error, has_runtime_error

local function report_err(line, where, message)
  io.stderr:write('line: '..line..' Error'..where..': '..message..'\n')
  has_error = true
end

local function gen_error(line, message)
  report_err(line, '', message)
end

local function parse_error(token, message)
  if token.type == 'EOF' then
    report_err(token.line, ' at end', message)
  else
    report_err(token.line, " at '" .. token.lexeme .. "'", message)
  end
end

local function resolve_err(err)
  report_err(err.token.line, " at '"..err.token.lexeme.."'", err.message)
end

local function run_err(err)
  print(err)
  io.stderr.write(err.message..'\nline: '..err.token.line..'\n')
end

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

interpreter = Interpreter(run_err)
-- resolver = Resolver(interpreter, resolve_err)

repl()