local v=require("enum_thorough")

-- Just test an in and out typemap for enum SWIGTYPE and const enum SWIGTYPE & typemaps
assert(v.speedTest4(v.SpeedClass.slow) == v.SpeedClass.slow)
assert(v.speedTest5(v.SpeedClass.slow) == v.SpeedClass.slow)
