local v=require("global_immutable_vars_cpp")

-- first check if all variables can be read
assert(v.default_mutable_var == 40)
assert(v.global_immutable_var == 41)
assert(v.specific_mutable_var == 42)
assert(v.global_mutable_var == 43)
assert(v.specific_immutable_var == 44)

-- check that all mutable variables can be modified
v.default_mutable_var = 80
assert(v.default_mutable_var == 80)
v.specific_mutable_var = 82
assert(v.specific_mutable_var == 82)
v.global_mutable_var = 83
assert(v.global_mutable_var == 83)

-- now check that immutable variables cannot be modified
assert(not pcall(function() v.global_immutable_var = 81 end), "v.global_immutable_var is writable (expected to be immutable)")
assert(not pcall(function() v.specific_immutable_var = 81 end), "v.specific_immutable_var is writable (expected to be immutable)")

assert(v.check_values(80, 41, 82, 83, 44) ~= 0, "Check values failed")
