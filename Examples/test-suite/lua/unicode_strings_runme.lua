require("unicode_strings")

-- Lua do not support any characters coding
-- For any non-ASCII character we use the '\<decimal>' escape sequance notation per byte!

-- E9(233) is passed as is
-- ISO 8859-1/Latin-1 small letter o with diaeresis U+00F6 tranlate to C3(195) B6(182)
local test_string = "h\233llo w\195\182rld"
assert(unicode_strings.non_utf8_c_str() == test_string)
assert(unicode_strings.non_utf8_std_string() == test_string)
local test2 = "\212\182\t\172"
assert(unicode_strings.charstring(test2) == test2)
-- zero value is regard as null termination on C
-- C++ std::string and C string with explicit length do support zero values!
local test3 = "\212\182\t\172\0afterNull"
assert(unicode_strings.charstring(test3) ~= test3)
