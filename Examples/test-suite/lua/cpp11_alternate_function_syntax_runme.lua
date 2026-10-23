require("cpp11_alternate_function_syntax")

local a = cpp11_alternate_function_syntax.SomeStruct()

local res = a:addNormal(4, 5)
assert(res == 9, "SomeStruct::addNormal(4,5) returns " .. res .. " should be 9.")

res = a:addAlternate(4, 5)
assert(res == 9, "SomeStruct::addAlternate(4,5) returns " .. res .. " should be 9.")

res = a:addAlternateConst(4, 5)
assert(res == 9, "SomeStruct::addAlternateConst(4,5) returns " .. res .. " should be 9.")

res = a:addAlternateNoExcept(4, 5)
assert(res == 9, "SomeStruct::addAlternateNoExcept(4,5) returns " .. res .. " should be 9.")

res = a:addAlternateConstNoExcept(4, 5)
assert(res == 9, "SomeStruct::addAlternateConstNoExcept(4,5) returns " .. res .. " should be 9.")
