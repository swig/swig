local v=require("cpp11_raw_string_literals")

-- assert(v.L  == 100) L is used for 'lua_State' in C/C++ wrapper code
assert(v.u8 == 100)
assert(v.u == 100)
assert(v.UStruct.U == 100)
assert(v.R == 100)
assert(v.LR == 100)
assert(v.u8R == 100)
assert(v.uR == 100)
assert(v.URStruct.UR == 100)
-- assert(v.aa == "Wide string") TODO Lua do not support wide string
assert(v.bb == "UTF-8 string")
assert(v.xx == ")I'm an \"ascii\" \\ string.")
assert(v.ee == ")I'm an \"ascii\" \\ string.")
-- assert(v.ff == "I'm a \"raw wide\" \\ string.") TODO Lua do not support wide string
assert(v.gg == "I'm a \"raw UTF-8\" \\ string.")
assert(v.mm == ")I'm an \"ascii\" \\ string constant with multiple\n\nlines.")
