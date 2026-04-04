local v=require("overload_bool")

-- Overloading bool, int, string
assert(v.overloaded(true) == "bool")
assert(v.overloaded(false) == "bool")
assert(v.overloaded(0) == "int")
assert(v.overloaded(1) == "int")
assert(v.overloaded(2) == "int")
-- Lua translate strings containing numbers to number
assert(v.overloaded("1234") == "int")
assert(v.overloaded("c1234") == "string")
assert(v.boolfunction(false) == "false")
assert(v.boolfunction(true) == "true")
assert(v.intfunction(12) == "int")

-- Overloading bool, int, string
assert(v.overloaded_ref(true) == "bool")
assert(v.overloaded_ref(false) == "bool")
assert(v.overloaded_ref(0) == "int")
assert(v.overloaded_ref(1) == "int")
assert(v.overloaded_ref(2) == "int")
-- Lua translate strings containing numbers to number
assert(v.overloaded_ref("1234") == "int")
assert(v.overloaded_ref("c1234") == "string")
assert(v.boolfunction_ref(false) == "false")
assert(v.boolfunction_ref(true) == "true")
assert(v.intfunction_ref(17) == "int")
