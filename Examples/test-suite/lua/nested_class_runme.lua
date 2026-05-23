require("import")            -- the import fn
import("nested_class", true) -- import lib into global

-- Test basic nested classes
local outer = nested_class.Outer()
outer.a = 1
outer.b = 2

-- Test creating nested structs, classes and unions via factory methods
local is1 = outer:makeInnerStruct1()
local ic1 = outer:makeInnerClass1()
local iu1 = outer:makeInnerUnion1()

local is2 = outer:makeInnerStruct2()
local ic2 = outer:makeInnerClass2()
local iu2 = outer:makeInnerUnion2()

local ic4 = outer:makeInnerClass4Typedef()
local is4 = outer:makeInnerStruct4Typedef()
local iu4 = outer:makeInnerUnion4Typedef()

local ic5 = outer:makeInnerClass5()
local is5 = outer:makeInnerStruct5()
local iu5 = outer:makeInnerUnion5()

local ic5t = outer:makeInnerClass5Typedef()
local is5t = outer:makeInnerStruct5Typedef()
local iu5t = outer:makeInnerUnion5Typedef()

-- Test accessing nested class types through the outer class
-- In Lua, nested classes are accessed as Outer.InnerClass
assert(nested_class.Outer.InnerStruct1 ~= nil, "Outer.InnerStruct1 should exist")
assert(nested_class.Outer.InnerClass1 ~= nil, "Outer.InnerClass1 should exist")
assert(nested_class.Outer.InnerUnion1 ~= nil, "Outer.InnerUnion1 should exist")
assert(nested_class.Outer.InnerStruct2 ~= nil, "Outer.InnerStruct2 should exist")
assert(nested_class.Outer.InnerClass2 ~= nil, "Outer.InnerClass2 should exist")
assert(nested_class.Outer.InnerUnion2 ~= nil, "Outer.InnerUnion2 should exist")
assert(nested_class.Outer.InnerClass4Typedef ~= nil, "Outer.InnerClass4Typedef should exist")
assert(nested_class.Outer.InnerStruct4Typedef ~= nil, "Outer.InnerStruct4Typedef should exist")
assert(nested_class.Outer.InnerUnion4Typedef ~= nil, "Outer.InnerUnion4Typedef should exist")
assert(nested_class.Outer.InnerClass5Typedef ~= nil, "Outer.InnerClass5Typedef should exist")
assert(nested_class.Outer.InnerStruct5Typedef ~= nil, "Outer.InnerStruct5Typedef should exist")
assert(nested_class.Outer.InnerUnion5Typedef ~= nil, "Outer.InnerUnion5Typedef should exist")
assert(nested_class.Outer.InnerMultiple ~= nil, "Outer.InnerMultiple should exist")
assert(nested_class.Outer.InnerMultipleDerived ~= nil, "Outer.InnerMultipleDerived should exist")
assert(nested_class.Outer.InnerMultipleAnonTypedef1 ~= nil, "Outer.InnerMultipleAnonTypedef1 should exist")
assert(nested_class.Outer.InnerMultipleNamedTypedef1 ~= nil, "Outer.InnerMultipleNamedTypedef1 should exist")
assert(nested_class.Outer.InnerSameName ~= nil, "Outer.InnerSameName should exist")

-- Test multiple instances
local im1 = outer.MultipleInstance1
local im2 = outer.MultipleInstance2
local im3 = outer.MultipleInstance3
local im4 = outer.MultipleInstance4

local imd1 = outer.MultipleDerivedInstance1
local imd2 = outer.MultipleDerivedInstance2
local imd3 = outer.MultipleDerivedInstance3
local imd4 = outer.MultipleDerivedInstance4

-- Test anonymous typedef inner classes via factory methods
local mat1 = outer:makeInnerMultipleAnonTypedef1()
local mat2 = outer:makeInnerMultipleAnonTypedef2()
local mat3 = outer:makeInnerMultipleAnonTypedef3()

local mnt = outer:makeInnerMultipleNamedTypedef()
local mnt1 = outer:makeInnerMultipleNamedTypedef1()
local mnt2 = outer:makeInnerMultipleNamedTypedef2()
local mnt3 = outer:makeInnerMultipleNamedTypedef3()

-- Test InnerSameName
local isn = outer:makeInnerSameName()

-- Test creating instances of nested classes directly
local innerStruct1 = nested_class.Outer.InnerStruct1()
innerStruct1.x = 42
assert(innerStruct1.x == 42, "InnerStruct1.x should be 42")

local innerClass1 = nested_class.Outer.InnerClass1()
innerClass1.x = 99
assert(innerClass1.x == 99, "InnerClass1.x should be 99")

local innerUnion1 = nested_class.Outer.InnerUnion1()
innerUnion1.x = 10
assert(innerUnion1.x == 10, "InnerUnion1.x should be 10")

-- Test the foo method on Outer
assert(outer:foo() == 1, "Outer.foo() should return 1")

