require("char_strings")

local CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible."
local OTHERLAND_MSG = "Little message from the safe world."

local count = 5

-- Each set function takes (string, number) and returns true when the string
-- received matches OTHERLAND_MSG concatenated with number.
local function test_set(setter)
  for i = 0, count - 1 do
    assert(setter(OTHERLAND_MSG .. i, i) == true)
  end
end

local function test_pingpong(pp)
  for i = 0, count - 1 do
    local msg = OTHERLAND_MSG .. i
    assert(pp(msg) == msg)
  end
end

-- get functions
for i = 0, count - 1 do
  assert(char_strings.GetCharHeapString() == CPLUSPLUS_MSG)
  char_strings.DeleteCharHeapString()
end
for i = 0, count - 1 do
  assert(char_strings.GetConstCharProgramCodeString() == CPLUSPLUS_MSG)
  char_strings.DeleteCharHeapString()
end
assert(char_strings.GetCharStaticString() == CPLUSPLUS_MSG)
assert(char_strings.GetCharStaticStringFixed() == CPLUSPLUS_MSG)
assert(char_strings.GetConstCharStaticStringFixed() == CPLUSPLUS_MSG)

-- set functions
test_set(char_strings.SetCharHeapString)
test_set(char_strings.SetCharStaticString)
test_set(char_strings.SetCharArrayStaticString)
test_set(char_strings.SetConstCharHeapString)
test_set(char_strings.SetConstCharStaticString)
test_set(char_strings.SetConstCharArrayStaticString)
test_set(char_strings.SetCharConstStaticString)
test_set(char_strings.SetConstCharConstStaticString)
test_set(char_strings.SetConstCharTypedefString)

-- get set function
test_pingpong(char_strings.CharPingPong)
test_pingpong(char_strings.CharArrayPingPong)
for i = 0, count - 1 do
  local msg = "Ping" .. i -- char[16] buffer, keep short enough to fit
  assert(char_strings.CharArrayDimsPingPong(msg) == msg)
end

assert(char_strings.CharArrayDimsLength("Ping") == 4)
assert(char_strings.CharArrayDimsLength("0123456789abcde") == 15)
assert(not pcall(char_strings.CharArrayDimsLength, "0123456789abcdef"))

-- variables: settable globals - set then read back
for i = 0, count - 1 do
  local msg = OTHERLAND_MSG .. i
  char_strings.global_char = msg
  assert(char_strings.global_char == msg)
end
-- global_char_array1 is a char[] with no size, so it is read only
assert(char_strings.global_char_array1 == CPLUSPLUS_MSG)
assert(not pcall(function() char_strings.global_char_array1 = OTHERLAND_MSG end))
for i = 0, count - 1 do
  local msg = OTHERLAND_MSG .. i
  char_strings.global_char_array2 = msg
  assert(char_strings.global_char_array2 == msg)
end
assert(not pcall(function() char_strings.global_char_array2 = CPLUSPLUS_MSG .. CPLUSPLUS_MSG end))
assert(char_strings.char_array_no_nul.full == "abcd")
assert(char_strings.char_array_no_nul.after == "XYZ")
char_strings.global_char_one = "a"
assert(char_strings.global_char_one == "a")
one = char_strings.CharArrayOne()
one.one = "b"
assert(one.one == "b")
assert(char_strings.CharArrayPingPong(nil) == nil)
assert(char_strings.CharArrayDimsPingPong(nil) == nil)
assert(not pcall(char_strings.PlainCharPingPong, nil))
assert(not pcall(function() char_strings.char_array_null.four = nil end))
assert(not pcall(function() char_strings.global_char_array_null = nil end))
assert(char_strings.char_array_null.four == "qqq")
assert(char_strings.global_char_array_null == "qqq")

-- variables: read-only const globals
assert(char_strings.global_const_char == CPLUSPLUS_MSG)
assert(char_strings.global_const_char_array1 == CPLUSPLUS_MSG)
assert(char_strings.global_const_char_array2 == CPLUSPLUS_MSG)

-- char *& tests
assert(char_strings.GetCharPointerRef() == CPLUSPLUS_MSG)
test_set(char_strings.SetCharPointerRef)
assert(char_strings.GetConstCharPointerRef() == CPLUSPLUS_MSG)
test_set(char_strings.SetConstCharPointerRef)
