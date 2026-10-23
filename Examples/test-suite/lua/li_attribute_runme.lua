require("li_attribute")

local aa = li_attribute.A(1, 2, 3)
assert(aa.a == 1)
aa.a = 3
assert(aa.a == 3, "aa.a: " .. aa.a)
assert(aa.b == 2, "aa.b: " .. aa.b)
aa.b = 5
assert(aa.b == 5)
assert(aa.d == aa.b)
assert(aa.c == 3)
--aa.c = 5
--assert(aa.c == 3)

local pi = li_attribute.Param_i(7)
assert(pi.value == 7)
pi.value = 3
assert(pi.value == 3)

local b = li_attribute.B(aa)
assert(b.a.c == 3)

-- class/struct attribute with get/set methods using return/pass by reference
local myFoo = li_attribute.MyFoo()
myFoo.x = 8
local myClass = li_attribute.MyClass()
myClass.Foo = myFoo
assert(myClass.Foo.x == 8)
myClass.Foo2 = myFoo
assert(myClass.Foo2.x == 8)

-- class/struct attribute with get/set methods using return/pass by value
local myClassVal = li_attribute.MyClassVal()
assert(myClassVal.ReadWriteFoo.x == -1)
assert(myClassVal.ReadOnlyFoo.x == -1)
myClassVal.ReadWriteFoo = myFoo
assert(myClassVal.ReadWriteFoo.x == 8)
assert(myClassVal.ReadOnlyFoo.x == 8)

-- string attribute with get/set methods using return/pass by value
local myStringyClass = li_attribute.MyStringyClass("initial string")
assert(myStringyClass.ReadWriteString == "initial string")
assert(myStringyClass.ReadOnlyString == "initial string")
myStringyClass.ReadWriteString = "changed string"
assert(myStringyClass.ReadWriteString == "changed string")
assert(myStringyClass.ReadOnlyString == "changed string")
