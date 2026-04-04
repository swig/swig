require("string_simple")

-- Test unicode string
local str = "olé"
local copy = string_simple.copy_str(str)
assert (str == copy)
