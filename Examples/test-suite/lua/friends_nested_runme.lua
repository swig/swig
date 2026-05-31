local v=require("friends_nested")

local om = v.option_map()
local m = v.mark_t()
local ac = v.acc_cond()
local mm = v.more_acc_cond.squeezed_in.more_mark_t()

local cout = v.std_cout_reference()
v.std_cout_badbit() -- uncomment this to see std::cout
v.operatorshift(cout, om)
m:operatorshift(0)
v.operatorshift(cout, m)
v.operatorshift(cout, ac)
-- v.operatorshift(cout, mm) TODO Lua do not support: operator <<(ostream &,more_mark_t &)

-- Test nested templates and classes
local oc = v.OuterClass()
local inner_double = v.OuterClass.InnerDouble(1.1)
local inner_int = v.OuterClass.InnerInt(2)
local inner_short = v.OuterClass.InnerShort(3)

v.friendly(inner_double)
v.friendly(inner_int)
v.friendly(inner_short)

local iis_double = v.OuterClass.InnerDouble.InnerInnerStruct(11.1)
local iis_int = v.OuterClass.InnerInt.InnerInnerStruct(22)
local iis_short = v.OuterClass.InnerShort.InnerInnerStruct(33)

v.friendly_inner_qualified(iis_double)
v.friendly_inner_qualified(iis_int)
v.friendly_inner_qualified(iis_short)

local iit_bool = v.OuterClass.InnerDouble.InnerInnerBool(111.1, true)
local iit_char = v.OuterClass.InnerInt.InnerInnerChar(222, 'x')
local iit_string = v.OuterClass.InnerShort.InnerInnerString(333, "hi")

v.friendly_inner_x(iit_bool)
-- v.friendly_inner_x(iit_char) TODO Lua do not support: friendly_inner_x(InnerInnerTemplate<char>)
v.friendly_inner_x(iit_string)

local vi_iit_bool = v.OuterClass.InnerDouble.InnerInnerBool.VeryInner(111.1, true)
local vi_iit_char = v.OuterClass.InnerInt.InnerInnerChar.VeryInner(222, 'x')
-- vi_iit_string = v.OuterClass.InnerShort.InnerInnerString.VeryInner(333, "hi") TODO Lua fails translate string to char *

v.very_inner(vi_iit_bool)
-- v.very_inner(vi_iit_char) TODO Lua do not support: very_inner(InnerInnerTemplate<char>)
--v.very_inner(vi_iit_string) TODO vi_iit_string is failing
