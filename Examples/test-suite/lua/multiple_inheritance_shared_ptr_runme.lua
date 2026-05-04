local v=require("multiple_inheritance_shared_ptr")

-- Test base class as a parameter
function jcbase1b(cb1)
    return cb1:cbase1y()
end
function jcbase2(cb2)
    return cb2:cbase2()
end
function jabase1(ab1)
    return ab1:abase1()
end

-- Test Derived1
local d1 = v.Derived1()
assert(d1:cbase1y() == 3, "Derived1::cbase1y()")
assert(d1:cbase2() == 4, "Derived1::cbase2()")

-- Test Derived2
local d2 = v.Derived2()
assert(d2:cbase1y() == 6, "Derived2::cbase1y()")
assert(d2:abase1() == 5, "Derived2::abase1()")

-- Test Derived3
local d3 = v.Derived3()
assert(d3:cbase1y() == 7, "Derived3::cbase1y()")
assert(d3:cbase2() == 8, "Derived3::cbase2()")
assert(d3:abase1() == 9, "Derived3::abase1()")

-- Test Bottom1
local b1 = v.Bottom1()
assert(b1:cbase1y() == 103, "Bottom1::cbase1y()")
assert(b1:cbase2() == 104, "Bottom1::cbase2()")

-- Test Bottom2
local b2 = v.Bottom2()
assert(b2:cbase1y() == 206, "Bottom2::cbase1y()")
assert(b2:abase1() == 205, "Bottom2::abase1()")

-- Test Bottom3
local b3 = v.Bottom3()
assert(b3:cbase1y() == 307, "Bottom3::cbase1y()")
assert(b3:cbase2() == 308, "Bottom3::cbase2()")
assert(b3:abase1() == 309, "Bottom3::abase1()")

-- Test interfaces from c++ classes
local cb1 = v.CBase1()
local cb2 = v.CBase2()
assert(cb1:cbase1y() == 1, "CBase1::cbase1y()")
assert(cb2:cbase2() == 2, "CBase2::cbase2()")

-- Test abstract class as return value
local ab1 = d3:cloneit()
assert(ab1:abase1() == 9, "Derived3::abase1() through ABase1")

-- Test concrete base class as return value
local cb6 = d2:cloneit()
local cb7 = d1:cloneit()
assert(cb6:cbase1y() == 6, "Derived2::cbase1y() through CBase1")
assert(cb7:cbase2() == 4, "Derived1:cbase2() through ABase1")

-- Test multi inheritance
local cb3 = v.Derived1()
local cb4 = v.Derived3()
local cb5 = v.Derived3()
local ab6 = v.Derived2()
assert(cb3:cbase1y() == 3, "Derived1::cbase1y() through CBase1")
assert(cb4:cbase1y() == 7, "Derived3::cbase1y() through CBase1")
assert(cb5:cbase2() == 8, "Derived3::cbase2() through CBase2")
assert(ab6:abase1() == 5, "Derived2::abase1() through ABase1")

-- Test base classes as parameter
assert(jcbase1b(d1) == 3, "jcbase1b() through Derived1 as parameter")
assert(jcbase1b(d2) == 6, "jcbase1b() through Derived2 as parameter")
assert(jcbase1b(d3) == 7, "jcbase1b() through Derived3 as parameter")
assert(jcbase2(d1) == 4, "jcbase2() through Derived1 as parameter")
assert(jcbase2(d3) == 8, "jcbase2() through Derived3 as parameter")
assert(jabase1(d2) == 5, "jabase1() through Derived2 as parameter")
assert(jabase1(d3) == 9, "jabase1() through Derived3 as parameter")

-- Value parameters
-- Test CBase1 CBase2 as parameters (note slicing for Derived and Bottom classes)
assert(v.InputValCBase1(d1) == 1, "InputValCBase1(), Derived1 as a parameter")
assert(v.InputValCBase1(d2) == 1, "InputValCBase1(), Derived2 as a parameter")
assert(v.InputValCBase1(d3) == 1, "InputValCBase1(), Derived3 as a parameter")
assert(v.InputValCBase2(d3) == 2, "InputValCBase2(), Derived3 as a parameter")
assert(v.InputValCBase2(d1) == 2, "InputValCBase2(), Derived1 as a parameter")
assert(v.InputValCBase1(cb1) == 1, "InputValCBase1(), CBase1 as a parameter")
assert(v.InputValCBase2(cb2) == 2, "InputValCBase2(), CBase2 as a parameter")
assert(v.InputValCBase1(b1) == 1, "InputValCBase1(), Bottom1 as a parameter")
assert(v.InputValCBase1(b2) == 1, "InputValCBase1(), Bottom2 as a parameter")
assert(v.InputValCBase1(b3) == 1, "InputValCBase1(), Bottom3 as a parameter")
assert(v.InputValCBase2(b3) == 2, "InputValCBase2(), Bottom3 as a parameter")
assert(v.InputValCBase2(b1) == 2, "InputValCBase2(), Bottom1 as a parameter")

-- Pointer parameters
-- Test ABase1 as a parameter
assert(v.InputPtrABase1(d2) == 5, "InputPtrABase1() through Derived2 as a parameter")
assert(v.InputPtrABase1(d3) == 9, "InputPtrABase1() through Derived3 as a parameter")
assert(v.InputPtrABase1(b2) == 205, "InputPtrABase1() through Bottom2 as a parameter")
assert(v.InputPtrABase1(b3) == 309, "InputPtrABase1() through Bottom3 as a parameter")

-- Test CBase1 CBase2 as parameters
assert(v.InputPtrCBase1(d1) == 3, "InputPtrCBase1(), Derived1 as a parameter")
assert(v.InputPtrCBase1(d2) == 6, "InputPtrCBase1(), Derived2 as a parameter")
assert(v.InputPtrCBase1(d3) == 7, "InputPtrCBase1(), Derived3 as a parameter")
assert(v.InputPtrCBase2(d3) == 8, "InputPtrCBase2(), Derived3 as a parameter")
assert(v.InputPtrCBase2(d1) == 4, "InputPtrCBase2(), Derived1 as a parameter")
assert(v.InputPtrCBase1(cb1) == 1, "InputPtrCBase1(), CBase1 as a parameter")
assert(v.InputPtrCBase2(cb2) == 2, "InputPtrCBase2(), CBase2 as a parameter")
assert(v.InputPtrCBase1(b1) == 103, "InputPtrCBase1(), Bottom1 as a parameter")
assert(v.InputPtrCBase1(b2) == 206, "InputPtrCBase1(), Bottom2 as a parameter")
assert(v.InputPtrCBase1(b3) == 307, "InputPtrCBase1(), Bottom3 as a parameter")
assert(v.InputPtrCBase2(b3) == 308, "InputPtrCBase2(), Bottom3 as a parameter")
assert(v.InputPtrCBase2(b1) == 104, "InputPtrCBase2(), Bottom1 as a parameter")

-- Reference parameters
-- Test ABase1 as a parameter
assert(v.InputRefABase1(d2) == 5, "InputRefABase1() through Derived2 as a parameter")
assert(v.InputRefABase1(d3) == 9, "InputRefABase1() through Derived3 as a parameter")
assert(v.InputRefABase1(b2) == 205, "InputRefABase1() through Bottom2 as a parameter")
assert(v.InputRefABase1(b3) == 309, "InputRefABase1() through Bottom3 as a parameter")

-- Test CBase1 CBase2 as parameters
assert(v.InputRefCBase1(d1) == 3, "InputRefCBase1(), Derived1 as a parameter")
assert(v.InputRefCBase1(d2) == 6, "InputRefCBase1(), Derived2 as a parameter")
assert(v.InputRefCBase1(d3) == 7, "InputRefCBase1(), Derived3 as a parameter")
assert(v.InputRefCBase2(d3) == 8, "InputRefCBase2(), Derived3 as a parameter")
assert(v.InputRefCBase2(d1) == 4, "InputRefCBase2(), Derived1 as a parameter")
assert(v.InputRefCBase1(cb1) == 1, "InputRefCBase1(), CBase1 as a parameter")
assert(v.InputRefCBase2(cb2) == 2, "InputRefCBase2(), CBase2 as a parameter")
assert(v.InputRefCBase1(b1) == 103, "InputRefCBase1(), Bottom1 as a parameter")
assert(v.InputRefCBase1(b2) == 206, "InputRefCBase1(), Bottom2 as a parameter")
assert(v.InputRefCBase1(b3) == 307, "InputRefCBase1(), Bottom3 as a parameter")
assert(v.InputRefCBase2(b3) == 308, "InputRefCBase2(), Bottom3 as a parameter")
assert(v.InputRefCBase2(b1) == 104, "InputRefCBase2(), Bottom1 as a parameter")

-- Const reference pointer parameters
-- Test ABase1 as a parameter
assert(v.InputCPtrRefABase1(d2) == 5, "InputCPtrRefABase1() through Derived2 as a parameter")
assert(v.InputCPtrRefABase1(d3) == 9, "InputCPtrRefABase1() through Derived3 as a parameter")
assert(v.InputCPtrRefABase1(b2) == 205, "InputCPtrRefABase1() through Bottom2 as a parameter")
assert(v.InputCPtrRefABase1(b3) == 309, "InputCPtrRefABase1() through Bottom3 as a parameter")

-- Test CBase1 CBase2 as parameters
assert(v.InputCPtrRefCBase1(d1) == 3, "InputCPtrRefCBase1(), Derived1 as a parameter")
assert(v.InputCPtrRefCBase1(d2) == 6, "InputCPtrRefCBase1(), Derived2 as a parameter")
assert(v.InputCPtrRefCBase1(d3) == 7, "InputCPtrRefCBase1(), Derived3 as a parameter")
assert(v.InputCPtrRefCBase2(d3) == 8, "InputCPtrRefCBase2(), Derived3 as a parameter")
assert(v.InputCPtrRefCBase2(d1) == 4, "InputCPtrRefCBase2(), Derived1 as a parameter")
assert(v.InputCPtrRefCBase1(cb1) == 1, "InputCPtrRefCBase1(), CBase1 as a parameter")
assert(v.InputCPtrRefCBase2(cb2) == 2, "InputCPtrRefCBase2(), CBase2 as a parameter")
assert(v.InputCPtrRefCBase1(b1) == 103, "InputCPtrRefCBase1(), Bottom1 as a parameter")
assert(v.InputCPtrRefCBase1(b2) == 206, "InputCPtrRefCBase1(), Bottom2 as a parameter")
assert(v.InputCPtrRefCBase1(b3) == 307, "InputCPtrRefCBase1(), Bottom3 as a parameter")
assert(v.InputCPtrRefCBase2(b3) == 308, "InputCPtrRefCBase2(), Bottom3 as a parameter")
assert(v.InputCPtrRefCBase2(b1) == 104, "InputCPtrRefCBase2(), Bottom1 as a parameter")

-- Shared pointer parameters
--[[ TODO can not cast to boost::shared_ptr<>

-- Test ABase1 as a parameter
assert(v.InputSharedPtrABase1(d2) == 5, "InputSharedPtrABase1() through Derived2 as a parameter")
assert(v.InputSharedPtrABase1(d3) == 9, "InputSharedPtrABase1() through Derived3 as a parameter")
assert(v.InputSharedPtrABase1(b2) == 205, "InputSharedPtrABase1() through Bottom2 as a parameter")
assert(v.InputSharedPtrABase1(b3) == 309, "InputSharedPtrABase1() through Bottom3 as a parameter")

-- Test CBase1 CBase2 as parameters
assert(v.InputSharedPtrCBase1(d1) == 3, "InputSharedPtrCBase1(), Derived1 as a parameter")
assert(v.InputSharedPtrCBase1(d2) == 6, "InputSharedPtrCBase1(), Derived2 as a parameter")
assert(v.InputSharedPtrCBase1(d3) == 7, "InputSharedPtrCBase1(), Derived3 as a parameter")
assert(v.InputSharedPtrCBase2(d3) == 8, "InputSharedPtrCBase2(), Derived3 as a parameter")
assert(v.InputSharedPtrCBase2(d1) == 4, "InputSharedPtrCBase2(), Derived1 as a parameter")
assert(v.InputSharedPtrCBase1(cb1) == 1, "InputSharedPtrCBase1(), CBase1 as a parameter")
assert(v.InputSharedPtrCBase2(cb2) == 2, "InputSharedPtrCBase2(), CBase2 as a parameter")
assert(v.InputSharedPtrCBase1(b1) == 103, "InputSharedPtrCBase1(), Bottom1 as a parameter")
assert(v.InputSharedPtrCBase1(b2) == 206, "InputSharedPtrCBase1(), Bottom2 as a parameter")
assert(v.InputSharedPtrCBase1(b3) == 307, "InputSharedPtrCBase1(), Bottom3 as a parameter")
assert(v.InputSharedPtrCBase2(b3) == 308, "InputSharedPtrCBase2(), Bottom3 as a parameter")
assert(v.InputSharedPtrCBase2(b1) == 104, "InputSharedPtrCBase2(), Bottom1 as a parameter")

-- Shared pointer reference parameters
-- Test ABase1 as a parameter
assert(v.InputSharedPtrRefABase1(d2) == 5, "InputSharedPtrRefABase1() through Derived2 as a parameter")
assert(v.InputSharedPtrRefABase1(d3) == 9, "InputSharedPtrRefABase1() through Derived3 as a parameter")
assert(v.InputSharedPtrRefABase1(b2) == 205, "InputSharedPtrRefABase1() through Bottom2 as a parameter")
assert(v.InputSharedPtrRefABase1(b3) == 309, "InputSharedPtrRefABase1() through Bottom3 as a parameter")

-- Test CBase1 CBase2 as parameters
assert(v.InputSharedPtrRefCBase1(d1) == 3, "InputSharedPtrRefCBase1(), Derived1 as a parameter")
assert(v.InputSharedPtrRefCBase1(d2) == 6, "InputSharedPtrRefCBase1(), Derived2 as a parameter")
assert(v.InputSharedPtrRefCBase1(d3) == 7, "InputSharedPtrRefCBase1(), Derived3 as a parameter")
assert(v.InputSharedPtrRefCBase2(d3) == 8, "InputSharedPtrRefCBase2(), Derived3 as a parameter")
assert(v.InputSharedPtrRefCBase2(d1) == 4, "InputSharedPtrRefCBase2(), Derived1 as a parameter")
assert(v.InputSharedPtrRefCBase1(cb1) == 1, "InputSharedPtrRefCBase1(), CBase1 as a parameter")
assert(v.InputSharedPtrRefCBase2(cb2) == 2, "InputSharedPtrRefCBase2(), CBase2 as a parameter")
assert(v.InputSharedPtrRefCBase1(b1) == 103, "InputSharedPtrRefCBase1(), Bottom1 as a parameter")
assert(v.InputSharedPtrRefCBase1(b2) == 206, "InputSharedPtrRefCBase1(), Bottom2 as a parameter")
assert(v.InputSharedPtrRefCBase1(b3) == 307, "InputSharedPtrRefCBase1(), Bottom3 as a parameter")
assert(v.InputSharedPtrRefCBase2(b3) == 308, "InputSharedPtrRefCBase2(), Bottom3 as a parameter")
assert(v.InputSharedPtrRefCBase2(b1) == 104, "InputSharedPtrRefCBase2(), Bottom1 as a parameter")
]]

-- Derived classes as parameters
assert(v.InputValDerived1(d1) == 3+4, "InputValDerived1()")
assert(v.InputValDerived2(d2) == 6+5, "InputValDerived2()")
assert(v.InputValDerived3(d3) == 7+8+9, "InputValDerived3()")

assert(v.InputRefDerived1(d1) == 3+4, "InputRefDerived1()")
assert(v.InputRefDerived2(d2) == 6+5, "InputRefDerived2()")
assert(v.InputRefDerived3(d3) == 7+8+9, "InputRefDerived3()")

assert(v.InputPtrDerived1(d1) == 3+4, "InputPtrDerived1()")
assert(v.InputPtrDerived2(d2) == 6+5, "InputPtrDerived2()")
assert(v.InputPtrDerived3(d3) == 7+8+9, "InputPtrDerived3()")

assert(v.InputCPtrRefDerived1(d1) == 3+4, "InputCPtrRefDerived1()")
assert(v.InputCPtrRefDerived2(d2) == 6+5, "InputCPtrRefDerived2()")
assert(v.InputCPtrRefDerived3(d3) == 7+8+9, "InputCPtrRefDerived3()")

--[[ TODO can not cast to boost::shared_ptr<>
assert(v.InputSharedPtrDerived1(d1) == 3+4, "InputSharedPtrDerived1()")
assert(v.InputSharedPtrDerived2(d2) == 6+5, "InputSharedPtrDerived2()")
assert(v.InputSharedPtrDerived3(d3) == 7+8+9, "InputSharedPtrDerived3()")

assert(v.InputSharedPtrRefDerived1(d1) == 3+4, "InputSharedPtrRefDerived1()")
assert(v.InputSharedPtrRefDerived2(d2) == 6+5, "InputSharedPtrRefDerived2()")
assert(v.InputSharedPtrRefDerived3(d3) == 7+8+9, "InputSharedPtrRefDerived3()")
]]

-- Bottom classes as Derived parameters
assert(v.InputValDerived1(b1) == 3+4, "InputValDerived1()")
assert(v.InputValDerived2(b2) == 6+5, "InputValDerived2()")
assert(v.InputValDerived3(b3) == 7+8+9, "InputValDerived3()")

assert(v.InputRefDerived1(b1) == 103+104, "InputRefDerived1()")
assert(v.InputRefDerived2(b2) == 206+205, "InputRefDerived2()")
assert(v.InputRefDerived3(b3) == 307+308+309, "InputRefDerived3()")

assert(v.InputPtrDerived1(b1) == 103+104, "InputPtrDerived1()")
assert(v.InputPtrDerived2(b2) == 206+205, "InputPtrDerived2()")
assert(v.InputPtrDerived3(b3) == 307+308+309, "InputPtrDerived3()")

assert(v.InputCPtrRefDerived1(b1) == 103+104, "InputCPtrRefDerived1()")
assert(v.InputCPtrRefDerived2(b2) == 206+205, "InputCPtrRefDerived2()")
assert(v.InputCPtrRefDerived3(b3) == 307+308+309, "InputCPtrRefDerived3()")

--[[ TODO can not cast to boost::shared_ptr<>
assert(v.InputSharedPtrDerived1(b1) == 103+104, "InputSharedPtrDerived1()")
assert(v.InputSharedPtrDerived2(b2) == 206+205, "InputSharedPtrDerived2()")
assert(v.InputSharedPtrDerived3(b3) == 307+308+309, "InputSharedPtrDerived3()")

assert(v.InputSharedPtrRefDerived1(b1) == 103+104, "InputSharedPtrRefDerived1()")
assert(v.InputSharedPtrRefDerived2(b2) == 206+205, "InputSharedPtrRefDerived2()")
assert(v.InputSharedPtrRefDerived3(b3) == 307+308+309, "InputSharedPtrRefDerived3()")
]]

-- Bottom classes as Bottom parameters
assert(v.InputValBottom1(b1) == 103+104, "InputValBottom1()")
assert(v.InputValBottom2(b2) == 206+205, "InputValBottom2()")
assert(v.InputValBottom3(b3) == 307+308+309, "InputValBottom3()")

assert(v.InputRefBottom1(b1) == 103+104, "InputRefBottom1()")
assert(v.InputRefBottom2(b2) == 206+205, "InputRefBottom2()")
assert(v.InputRefBottom3(b3) == 307+308+309, "InputRefBottom3()")

assert(v.InputPtrBottom1(b1) == 103+104, "InputPtrBottom1()")
assert(v.InputPtrBottom2(b2) == 206+205, "InputPtrBottom2()")
assert(v.InputPtrBottom3(b3) == 307+308+309, "InputPtrBottom3()")

assert(v.InputCPtrRefBottom1(b1) == 103+104, "InputCPtrRefBottom1()")
assert(v.InputCPtrRefBottom2(b2) == 206+205, "InputCPtrRefBottom2()")
assert(v.InputCPtrRefBottom3(b3) == 307+308+309, "InputCPtrRefBottom3()")

--[[ TODO can not cast to boost::shared_ptr<>
assert(v.InputSharedPtrBottom1(b1) == 103+104, "InputSharedPtrBottom1()")
assert(v.InputSharedPtrBottom2(b2) == 206+205, "InputSharedPtrBottom2()")
assert(v.InputSharedPtrBottom3(b3) == 307+308+309, "InputSharedPtrBottom3()")

assert(v.InputSharedPtrRefBottom1(b1) == 103+104, "InputSharedPtrRefBottom1()")
assert(v.InputSharedPtrRefBottom2(b2) == 206+205, "InputSharedPtrRefBottom2()")
assert(v.InputSharedPtrRefBottom3(b3) == 307+308+309, "InputSharedPtrRefBottom3()")
]]

-- Return pointers
assert(v.MakePtrDerived1_CBase1():cbase1y() == 3, "MakePtrDerived1_CBase1")
assert(v.MakePtrDerived1_CBase2():cbase2() == 4, "MakePtrDerived1_CBase2")
assert(v.MakePtrDerived2_CBase1():cbase1y() == 6, "MakePtrDerived2_CBase1")
assert(v.MakePtrDerived2_ABase1():abase1() == 5, "MakePtrDerived2_ABase1")
assert(v.MakePtrDerived3_ABase1():abase1() == 9, "MakePtrDerived3_ABase1")
assert(v.MakePtrDerived3_CBase1():cbase1y() == 7, "MakePtrDerived3_CBase1")
assert(v.MakePtrDerived3_CBase2():cbase2() == 8, "MakePtrDerived3_CBase2")

-- Return references
assert(v.MakeRefDerived1_CBase1():cbase1y() == 3, "MakeRefDerived1_CBase1")
assert(v.MakeRefDerived1_CBase2():cbase2() == 4, "MakeRefDerived1_CBase2")
assert(v.MakeRefDerived2_CBase1():cbase1y() == 6, "MakeRefDerived2_CBase1")
assert(v.MakeRefDerived2_ABase1():abase1() == 5, "MakeRefDerived2_ABase1")
assert(v.MakeRefDerived3_ABase1():abase1() == 9, "MakeRefDerived3_ABase1")
assert(v.MakeRefDerived3_CBase1():cbase1y() == 7, "MakeRefDerived3_CBase1")
assert(v.MakeRefDerived3_CBase2():cbase2() == 8, "MakeRefDerived3_CBase2")

-- Return const pointer references
assert(v.MakeConstPtrRefDerived1_CBase1():cbase1y() == 3, "MakeConstPtrRefDerived1_CBase1")
assert(v.MakeConstPtrRefDerived1_CBase2():cbase2() == 4, "MakeConstPtrRefDerived1_CBase2")
assert(v.MakeConstPtrRefDerived2_CBase1():cbase1y() == 6, "MakeConstPtrRefDerived2_CBase1")
assert(v.MakeConstPtrRefDerived2_ABase1():abase1() == 5, "MakeConstPtrRefDerived2_ABase1")
assert(v.MakeConstPtrRefDerived3_ABase1():abase1() == 9, "MakeConstPtrRefDerived3_ABase1")
assert(v.MakeConstPtrRefDerived3_CBase1():cbase1y() == 7, "MakeConstPtrRefDerived3_CBase1")
assert(v.MakeConstPtrRefDerived3_CBase2():cbase2() == 8, "MakeConstPtrRefDerived3_CBase2")

-- Return by value (sliced objects)
assert(v.MakeValDerived1_CBase1():cbase1y() == 1, "MakeValDerived1_CBase1")
assert(v.MakeValDerived1_CBase2():cbase2() == 2, "MakeValDerived1_CBase2")
assert(v.MakeValDerived2_CBase1():cbase1y() == 1, "MakeValDerived2_CBase1")
assert(v.MakeValDerived3_CBase1():cbase1y() == 1, "MakeValDerived3_CBase1")
assert(v.MakeValDerived3_CBase2():cbase2() == 2, "MakeValDerived3_CBase2")

--[[ TODO can not cast to boost::shared_ptr<>
-- Return smart pointers
assert(v.MakeSharedPtrDerived1_CBase1():cbase1y() == 3, "MakeSharedPtrDerived1_CBase1")
assert(v.MakeSharedPtrDerived1_CBase2():cbase2() == 4, "MakeSharedPtrDerived1_CBase2")
assert(v.MakeSharedPtrDerived2_CBase1():cbase1y() == 6, "MakeSharedPtrDerived2_CBase1")
assert(v.MakeSharedPtrDerived2_ABase1():abase1() == 5, "MakeSharedPtrDerived2_ABase1")
assert(v.MakeSharedPtrDerived3_ABase1():abase1() == 9, "MakeSharedPtrDerived3_ABase1")
assert(v.MakeSharedPtrDerived3_CBase1():cbase1y() == 7, "MakeSharedPtrDerived3_CBase1")
assert(v.MakeSharedPtrDerived3_CBase2():cbase2() == 8, "MakeSharedPtrDerived3_CBase2")

-- Return smart pointers
assert(v.MakeSharedPtrRefDerived1_CBase1():cbase1y() == 3, "MakeSharedPtrRefDerived1_CBase1")
assert(v.MakeSharedPtrRefDerived1_CBase2():cbase2() == 4, "MakeSharedPtrRefDerived1_CBase2")
assert(v.MakeSharedPtrRefDerived2_CBase1():cbase1y() == 6, "MakeSharedPtrRefDerived2_CBase1")
assert(v.MakeSharedPtrRefDerived2_ABase1():abase1() == 5, "MakeSharedPtrRefDerived2_ABase1")
assert(v.MakeSharedPtrRefDerived3_ABase1():abase1() == 9, "MakeSharedPtrRefDerived3_ABase1")
assert(v.MakeSharedPtrRefDerived3_CBase1():cbase1y() == 7, "MakeSharedPtrRefDerived3_CBase1")
assert(v.MakeSharedPtrRefDerived3_CBase2():cbase2() == 8, "MakeSharedPtrRefDerived3_CBase2")
]]
