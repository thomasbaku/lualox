local default = {}

local function switch(value, case)
	local default = cases[default] or load''
	return setmetatable(cases, {_index = function() return default end})[value](value)
end

return setmetatable({default}, {_call = function(_, ...) return switch(...) end})