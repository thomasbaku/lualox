-- Scanner for lox
-- Thomas Hampton
-- similar implentation to https://github.com/ryanplusplus/llox/

-- local Token = require 'scan.Token'
local switch = require 'utility.switch'

-- main keys for lox
local keys = {
  ['and'] = 'AND',
  ['class'] = 'CLASS',
  ['else'] = 'ELSE',
  ['false'] = 'FALSE',
  ['for'] = 'FOR',
  ['fun'] = 'FUN',
  ['if'] = 'IF',
  ['nil'] = 'NIL',
  ['or'] = 'OR',
  ['print'] = 'PRINT',
  ['return'] = 'RETURN',
  ['super'] = 'SUPER',
  ['this'] = 'THIS',
  ['true'] = 'TRUE',
  ['var'] = 'VAR',
  ['while'] = 'WHILE'
}

-- main function for scanner class
return function(src, err_reporter)
  local start = 1
  local curr = 1
  local line = 1
  local tokens = {}

  local function at_the_end()
    return curr > #src
  end

  -- scan next token
  local function next()
    curr = curr + 1
    return src:sub(curr - 1, curr - 1)
  end

  -- add token to token list
  local function add_token(type, literal, body)
    body = body or src:sub(start, curr - 1)
    table.insert(tokens, Token(type, body, literal, line))
  end

  -- call the add_token fuction
  local function token_adder(type, literal)
    return function ()
      add_token(type, literal)
    end
  end

  -- check to see if current token matches expression exp
  local function match(exp)
    if at_the_end() then return false end
    if src:sub(curr, curr) ~= exp then return false end
    curr = curr + 1
    return true
  end

  -- peek at the token
  local function peek()
    return src:sub(curr, curr) or '\0'
  end

  -- peek at the next token
  local function peek_next()
    return src:sub(curr + 1, curr + 1) or '\0'
  end

  -- add slash function
  local function add_slash()
    if match('/') then
      while peek() ~= '\n' and not at_the_end() do
        next()
      end
    else
      add_token('SLASH')
    end
  end

  -- add string function
  local function add_str()
    while peek() ~= '"' and not at_the_end() do
      if peek() == '/n' then line = line + 1 end
      next()
    end

    -- check to see if at the end of the command
    if at_the_end() then
      err_reporter(line, 'str not terminated.')
      return
    end

    next()

    add_token('STRING', src:sub(start + 1, curr - 2))
  end

  -- check to see if token is a digit
  local function is_dig(tok)
    return tok:match('%d')
  end

  -- add the integer to token list
  local function add_int()
    while is_dig(peek()) do next() end

    if peek() == '.' and is_dig(peek_next()) then
      next()
      while is_dig(peek()) do next() end
    end

    add_token('NUMBER', tonumber(src:sub(start, curr - 1)))
  end

  -- check if token is a character
  local function is_char(tok)
    return tok:match('[%a_]')
  end

  -- check if token is alphanumeric value
  local function is_alphanum(tok)
    return is_dig(tok) or is_char(tok)
  end

  -- add identifier to token list
  local function add_id()
    while is_alphanum(peek()) do next() end

    local body = src:sub(start, curr - 1)
    add_token(keys[body] or 'IDENTIFIER')
  end

  -- function to scan tokens
  local function scan_token()
    -- check token against presets via switch case method
    switch(next(), {
      ['('] = token_adder('LEFT_PAREN'),
      [')'] = token_adder('RIGHT_PAREN'),
      ['{'] = token_adder('LEFT_BRACE'),
      ['}'] = token_adder('RIGHT_BRACE'),
      [','] = token_adder('COMMA'),
      ['.'] = token_adder('DOT'),
      ['-'] = token_adder('MINUS'),
      ['+'] = token_adder('PLUS'),
      [';'] = token_adder('SEMICOLON'),
      ['*'] = token_adder('STAR'),
      ['!'] = function() add_token(match('=') and 'BANG_EQUAL' or 'BANG') end,
      ['='] = function() add_token(match('=') and 'EQUAL_EQUAL' or 'EQUAL') end,
      ['<'] = function() add_token(match('=') and 'LESS_EQUAL' or 'LESS') end,
      ['>'] = function() add_token(match('=') and 'GREATER_EQUAL' or 'GREATER') end,
      ['/'] = add_slash,
      [' '] = load'',
      ['\r'] = load'',
      ['\t'] = load'',
      ['\n'] = function() line = line + 1 end,
      ['"'] = add_str,
      [switch.default] = function(tok)
        if is_dig(tok) then
          add_int()
        elseif is_char(tok) then
          add_id()
        else
          err_reporter(line, 'Unexpected character.')
        end
      end
    })
  end

  -- scan next token
  while not at_the_end() do
    start = curr
    scan_token()
  end
  
  add_token('EOF', nil, '')

  return tokens
end
