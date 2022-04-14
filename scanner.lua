-- Scanner for lox
-- Thomas Hampton

-- local Token = require 'scan.Token'
-- local switch = require 'util.switch'

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

return function(src, err_reporter)
  local start = 1
  local curr = 1
  local line = 1
  local tokens = {}

  local function at_the_end()
    return curr > #src
  end

  local function next()
    curr = curr + 1
    return src:sub(curr - 1, curr - 1)
  end

  local function add_token(type, literal, body)
    body = body or src:sub(start, curr - 1)
    table.insert(tokens, Token(type, body, literal, line))
  end

  local function token_adder(type, literal)
    return fuction() add_token(type, literal) end
  end

  local function match(exp)
    if at_the_end() then return false end
    if src:sub(curr, curr) ~= exp then return false end
    curr = curr + 1
    return true
  end

  local function peek()
    return src:sub(curr, curr) or '\0'
  end

  local function peek_next()
    return src:sub(curr + 1, curr + 1) or '\0'
  end

  local function add_slash()
    if match('/') then
      while peek() ~= '\n' and not at_the_end() do
        next()
      end
    else
      add_token('SLASH')
    end
  end

  local function add_str()
    while peek() ~= '"' and not at_the_end() do
      if peek() == '/n' then line = line + 1 end
      next()
    end

    if at_the_end() then
      err_reporter(line, 'str not terminated.')
      return
    end

    next()

    add_token('STRING', src:sub(start + 1, curr - 2))
  end

  local function is_dig(dig)
    return dig:match('%d')
  end

  local function add_int()
    while is_dig(peek()) do next() end

    if peek() == '.' and is_dig(peek_next()) then
      next()
      while is_dig(peek()) do next() end
    end

    add_token('NUMBER', tonumber(src:sub(start, curr - 1)))
  end

  local function is_char(char)
    return char:match('[%a_]')
  end

  local function is_alphanum(char)
    return is_dig(char) or is_char(char)
  end

  local function add_id()
    while is_alphanum(peek()) do advance() end

    local body = src:sub(start, curr - 1)
    add_token(keywords[body] or 'IDENTIFIER')
  end

  local function scan_token()
    switch(advance(), {
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

  while not at_the_end() do
    start = curr
    scan_token()
  end

  add_token('EOF', nil, '')

  return tokens
end
