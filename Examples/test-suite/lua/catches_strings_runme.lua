require("catches_strings")
catch_undef_globs() -- catch "undefined" global variables

s, msg = pcall(function() catches_strings.StringsThrower.charstring() end)
assert(not s and msg:find("charstring message", 1, true))

s, msg = pcall(function() catches_strings.StringsThrower.stdstring() end)
assert(not s and msg:find("stdstring message", 1, true))
