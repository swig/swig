local v=require("copyctor")

local bar = v.Bar()
bar = v.Bar(bar)

local foo = v.Foo()
foo = v.Foo(bar)

local car = v.Car()

local hoo = v.Hoo()
hoo = v.Hoo(bar)
hoo = v.Hoo(car)
