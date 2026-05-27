require("import")
import("li_std_optional")

local env = _ENV
if not env then env = getfenv() end
setmetatable(env, {__index=function(t,i) error("undefined global variable `"..i.."'",2) end})

-- Test make_optional with value
v = li_std_optional.make_optional(42)

-- Test make_empty_optional
e = li_std_optional.make_empty_optional()

-- Test optional_value_or with value
r1 = li_std_optional.optional_value_or(li_std_optional.make_optional(10), 99)
if not (r1 == 10) then
  error("optional_value_or with value test failed: " .. r1)
end

-- Test optional_value_or with empty
r2 = li_std_optional.optional_value_or(li_std_optional.make_empty_optional(), 99)
if not (r2 == 99) then
  error("optional_value_or with empty test failed: " .. r2)
end
