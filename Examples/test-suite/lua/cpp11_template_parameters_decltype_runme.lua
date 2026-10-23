local v=require("cpp11_template_parameters_decltype")


local show = false -- for debugging
v.tester(show)
local json0 = v.Json("hi")
assert(json0.ctor == 0, "json0")
assert(json0:mmm("bye") == 100, "json0:mmm")

local converter = v.Converter()
local json1 = v.Json(converter)
assert(json1.ctor == 1, "json1")
assert(json1:mmm(converter) == 101, "json1:mmm")

local myMapStringString = v.MapStringString()
local json2 = v.Json(myMapStringString)
assert(json2.ctor == 2, "json2")
assert(json2:mmm(myMapStringString) == 102, "json2:mmm")

local myVectorString = v.VectorString()
local json3 = v.Json(myVectorString)
assert(json3.ctor == 3, "json3")
assert(json3:mmm(myVectorString) == 103, "json3:mmm")
