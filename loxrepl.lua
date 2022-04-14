package.path = package.path .. ';src/?.lua'

local error, runtime_error

local function run(code)
    -- local tokens = scan(code, gen_error)
    if error then return end
    -- local statements = parse(tokens, parse_error)
end

local function repl()
    while true do
        io.write('> ')
        local code = io.read()
        if not code then
            print()
            return
        end
        -- run(code)
        error = false
    end
end

repl()