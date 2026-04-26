require("import")
require("catches_strings")
catch_undef_globs() -- catch "undefined" global variables

s, msg = pcall(function() catches_strings.StringsThrower.charstring() end)
assert(s == false and msg:find("charstring message", 1, true))

s, msg = pcall(function() catches_strings.StringsThrower.stdstring() end)
assert(s == false and msg:find("stdstring message", 1, true))
