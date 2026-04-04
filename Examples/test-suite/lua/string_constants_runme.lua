local v=require("string_constants")

-- Lua do not support any characters coding
-- For any non-ASCII character we use the '\<decimal>' escape sequance notation per byte!

-- ISO 8859-1/Latin-1
-- capital 'AE' U+00C6 tranlate to UTF-8 C3(195) 86(134)
-- capital ''I' with circumflex U+00CE tranlate to UTF-8 C3(195) 8E(142)
local ss0="\195\134\195\142OU\n"
local zs0="" -- "\0" TODO pass constant strings with zero value in them
local qq0="\b00! \1" .. "8b00!" -- we must split string for "\1" value
local aa0="A\rB\nC"

assert(v.SS1 == ss0)
assert(v.AA1 == aa0)
assert(v.EE1 == "TUV")
assert(v.XX1 == "WXY")
assert(v.ZS1 == zs0)
assert(v.ES1 == "")
assert(v.QQ1 == qq0)
assert(v.PR1 == "paren")
assert(v.SS2 == ss0)
assert(v.AA2 == aa0)
assert(v.EE2 == "TUV")
assert(v.XX2 == "WXY")
assert(v.ZS2 == zs0)
assert(v.ES2 == "")
assert(v.QQ2 == qq0)
assert(v.PR2 == "paren")
assert(v.SS3 == ss0)
assert(v.AA3 == aa0)
assert(v.EE3 == "TUV")
assert(v.XX3 == "WXY")
assert(v.ZS3 == zs0)
assert(v.ES3 == "")
assert(v.QQ3 == qq0)
assert(v.PR3 == "paren")
local t = v.things()
assert(t:defarguments1() == ss0)
assert(t:defarguments2() == aa0)
assert(t:defarguments3() == "TUV")
assert(t:defarguments4() == "WXY")
assert(t:defarguments5() == zs0)
assert(t:defarguments6() == "")
assert(t:defarguments7() == qq0)
assert(t:defarguments8() == "paren")
