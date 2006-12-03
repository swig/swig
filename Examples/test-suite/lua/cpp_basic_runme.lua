require("import")	-- the import fn
import("cpp_basic")	-- import code
cb=cpp_basic    -- renaming import

-- catch "undefined" global variables
setmetatable(getfenv(),{__index=function (t,i) error("undefined global variable `"..i.."'",2) end})

f=cb.Foo(4)
assert(f.num==4)
f.num=-17
assert(f.num==-17)

b=cb.Bar()

b.fptr=f
assert(b.fptr.num==-17)
assert(b:test(-3,b.fptr)==-5)
f.num=12
assert(b.fptr.num==12)

assert(b.fref.num==-4)
assert(b:test(12,b.fref)==23)

-- references don't take ownership, so if we didn't define this here it might get garbage collected
f2=cb.Foo(23)
b.fref=f2
assert(b.fref.num==23)
assert(b:test(-3,b.fref)==35)

assert(b.fval.num==15)
assert(b:test(3,b.fval)==33)
b.fval=cb.Foo(-15)  -- this is safe as it is copied into the C++
assert(b.fval.num==-15)
assert(b:test(3,b.fval)==-27)

f3=b:testFoo(12,b.fref)
assert(f3.num==32)

-- now test global
f4=cb.Foo(6)
cb.Bar_global_fptr=f4
assert(cb.Bar_global_fptr.num==6)
f4.num=8
assert(cb.Bar_global_fptr.num==8)

assert(cb.Bar_global_fref.num==23)
cb.Bar_global_fref=cb.Foo(-7) -- this will set the value
assert(cb.Bar_global_fref.num==-7)

assert(cb.Bar_global_fval.num==3)
cb.Bar_global_fval=cb.Foo(-34)
assert(cb.Bar_global_fval.num==-34)

-- Now test member function pointers
func1_ptr=cb.get_func1_ptr()
func2_ptr=cb.get_func2_ptr()
f.num=4
assert(f:func1(2)==16)
assert(f:func2(2)==-8)

f.func_ptr=func1_ptr
assert(cb.test_func_ptr(f,2)==16)
f.func_ptr=func2_ptr
assert(cb.test_func_ptr(f,2)==-8)
