v=require("smart_pointer_const_overload")

function test(b, f)
    assert(f.x1 == 0)
    -- Test member variable get
    assert(b.x1 == 0)
    assert(f.access1 == v.CONST_ACCESS)
    -- Test member variable set
    b.x1 = 1
    assert(f.x1 == 1)
    assert(f.access1 == v.MUTABLE_ACCESS)
    -- Test const method
    assert(b:getx1() == 1)
    assert(f.access1 == v.CONST_ACCESS)
    -- Test mutable method
    b:setx1(2)
    assert(f.x1 == 2)
    assert(f.access1 == v.MUTABLE_ACCESS)
    -- Test extended const method
    assert(b:getx2() == 2)
    assert(f.access1 == v.CONST_ACCESS)
    -- Test extended mutable method
    b:setx2(3)
    assert(f.x1 == 3)
    assert(f.access1 == v.MUTABLE_ACCESS)
    -- Test static method
    b:statMethod()
    assert(f.access1 == v.CONST_ACCESS)
    -- Test const member
    f.access1 = v.MUTABLE_ACCESS
    assert(b.y == 0)
    assert(f.access1 == v.CONST_ACCESS)
    -- Test get through mutable pointer to const member
    f.access1 = v.MUTABLE_ACCESS
    assert(v.get_int(b.yp) == 0)
    assert(f.access1 == v.CONST_ACCESS)
    -- Test get through const pointer to mutable member
    f.x1 = 4
    f.access1 = v.MUTABLE_ACCESS
    assert(v.get_int(b.xp) == 4)
    assert(f.access1 == v.CONST_ACCESS)
    -- Test set through const pointer to mutable member
    f.access1 = v.MUTABLE_ACCESS
    v.set_int(b.xp, 5)
    assert(f.x1 == 5)
    assert(f.access1 == v.CONST_ACCESS)
    -- Test set pointer to const member
    b.yp = v.new_int(6)
    assert(f.y == 0)
    assert(v.get_int(f.yp) == 6)
    assert(f.access1 == v.MUTABLE_ACCESS)
    v.delete_int(f.yp)
end

v.CONST_ACCESS = 1
v.MUTABLE_ACCESS = 2

local f = v.Foo()
local b = v.Bar(f)
local f2 = v.Foo()
local b2 = v.Bar2(f2)

test(b, f)
test(b2, f2)
