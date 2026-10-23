require("li_typemaps")
catch_undef_globs() -- catch "undefined" global variables

-- Check double INPUT typemaps
assert(li_typemaps.in_double(22.22) == 22.22)
assert(li_typemaps.inr_double(22.22) == 22.22)

-- Check double OUTPUT typemaps
assert(li_typemaps.out_double(22.22) == 22.22)
assert(li_typemaps.outr_double(22.22) == 22.22)

-- Check double INOUT typemaps
assert(li_typemaps.inout_double(22.22) == 22.22)
assert(li_typemaps.inoutr_double(22.22) == 22.22)

-- check long long
assert(li_typemaps.in_ulonglong(20)==20)
assert(li_typemaps.inr_ulonglong(20)==20)
assert(li_typemaps.out_ulonglong(20)==20)
assert(li_typemaps.outr_ulonglong(20)==20)
assert(li_typemaps.inout_ulonglong(20)==20)
assert(li_typemaps.inoutr_ulonglong(20)==20)

-- check bools
assert(li_typemaps.in_bool(true))
assert(not li_typemaps.inr_bool(false))
assert(li_typemaps.out_bool(true))
assert(not li_typemaps.outr_bool(false))
assert(li_typemaps.inout_bool(true))
assert(not li_typemaps.inoutr_bool(false))

-- the others
a,b=li_typemaps.inoutr_int2(1,2)
assert(a==1 and b==2)

f,i,i2=li_typemaps.out_foo(10)
assert(f.a==10 and i==20 and i2==30)

-- Two parameters using the same typemap
assert(li_typemaps.in_int_multi(3, 4) ==  7)
assert(li_typemaps.out_int_multi(5, 6) == 5, 6)
assert(li_typemaps.inout_int_multi(7, 8) == 14, 24)

-- A reference cannot be bound to a null pointer, so nil is rejected rather than dereferenced in the call
assert(not pcall(function () li_typemaps.inr_int(nil) end))
assert(not pcall(function () li_typemaps.inoutr_int(nil) end))
