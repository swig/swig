local v=require("template_methods")

local num = 1.1

-- Global templated functions
local i = v.convolve1Bool()
v.convolve1Bool(true)
i = v.convolve2Float()
v.convolve3FloatRenamed(num)
i = v.convolve4Float()
v.convolve4FloatRenamed(num)
i = v.convolve5FloatRenamed()
v.convolve5FloatRenamed(num)

-- Static templated methods
local k = v.Klass()
local b = k:KlassTMethodBoolRenamed(true)
k:KlassTMethodBool()
b = v.Klass.KlassStaticTMethodBoolRenamed(true)
v.Klass.KlassStaticTMethodBool()

local cp = v.ComponentProperties()
cp:adda("key1", "val1", "key2", 22.2)
cp:adda("key1", "val1", "key2", "val2", "key3", "val3")
cp:adda("key1", 1, "key2", 2, "key3", 3)
