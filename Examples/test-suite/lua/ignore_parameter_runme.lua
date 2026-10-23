local v=require("ignore_parameter")

-- Global function tests
assert(v.jaguar(0, 1.0) == "hello")
assert(v.lotus("foo", 1.0) == 101)
assert(v.tvr("foo", 0) == 8.8)
assert(v.ferrari() == 101)

-- Member function tests
local sc = v.SportsCars()
assert(sc:daimler(0, 1.0) == "hello")
assert(sc:astonmartin("foo", 1.0) == 101)
assert(sc:bugatti("foo", 0) == 8.8)
assert(sc:lamborghini() == 101)
assert(sc:audi() == 8.8)

-- Constructor tests
v.MiniCooper(0, 1.0)
v.MorrisMinor("foo", 1.0)
v.FordAnglia("foo", 0)
v.AustinAllegro()
