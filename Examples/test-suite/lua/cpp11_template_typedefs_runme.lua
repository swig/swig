local v=require("cpp11_template_typedefs")

local t = v.create_TypedefName()
assert(swig_type(t) == "ns::TypedefName< int > *|ns::SomeType< char const *,int,5 > *", "wrong type of 't'")
assert(t.a == "hello", "t.a should be 'hello'")
assert(t.b == 10, "t.b should be 10")
assert(t:get_n() == 5, "t.get_n() should be 5")

local t_bool = v.create_TypedefNameBool()
assert(swig_type(t_bool) == "ns::TypedefName< bool > *|ns::SomeType< char const *,bool,5 > *", "wrong type of t_bool")
assert(t_bool.a == "hello", "t_bool.a should be 'hello'")
assert(t_bool.b, "t_bool.b should be True")
assert(t_bool:get_n() == 15, "t_bool.get_n() should be 15")

assert(v.get_SomeType_b(t) == 10, "get_SomeType_b(t) should be 10")
assert(v.get_SomeType_b2(t) == 10, "get_SomeType_b2(t) should be 10")

local t2 = v.SomeTypeInt4()
t2.b = 0
local t3 = v.identity(t2)
t3.b = 5
assert(t2.b == 5, "t2.b should be 5")

assert(v.get_bucket_allocator1() == 1, "bucket_allocator1 should be 1")
assert(v.get_bucket_allocator2() == 2, "bucket_allocator2 should be 2")
