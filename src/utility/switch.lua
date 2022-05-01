-- Rollins Baird
-- function to switch out values for eachother
-- could not find a better way so used the same implementation as: https://github.com/ryanplusplus/llox/blob/master/src/util/switch.lua

local default_case = {}

local function switch(val, cases)
  local default = cases[default_case] or load''
  return setmetatable(cases, {
    __index = function()
      return default
    end
  })[val](val)
end

return setmetatable({
  default = default_case
}, {
  __call = function(_, ...) return switch(...) end
})
