local v=require("cpp11_type_aliasing")

assert(v.get_host_target().bits == 32, "get_host_target().bits should return 32")
assert(v.mult2(10) == 20, "mult2(10) should return 20")

local int_ptr = v.allocate_int()
v.inplace_mult2(int_ptr)
assert(v.read_int(int_ptr) == 24, "read_int should return 24")
v.free_int(int_ptr)

local pair = v.PairSubclass(3, 4)
assert(pair:first() == 3, "pair.first() should return 3")
assert(pair:second() == 4, "pair.second() should return 4")
assert(pair.a == 3, "pair.a should be 3")

assert(v.plus1(5) == 6, "plus1(5) should return 6")
-- assert(v.call(v.mult2_cb, 7) == 14, "call(mult2_cb, 7) should return 14") TODO '%callback' does not work
assert(v.call(v.get_callback(), 7) == 14, "call(get_callback(), 7) should return 14")
