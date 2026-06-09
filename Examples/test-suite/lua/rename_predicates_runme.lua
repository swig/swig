local v=require("rename_predicates")

local r = v.RenamePredicates(123)
r:MF_member_function()
v.RenamePredicates.MF_static_member_function()
r:MF_extend_function_before()
r:MF_extend_function_after()
v.GF_global_function()

assert(r.MV_member_variable == 123)
r.MV_member_variable = 1234
assert(r.MV_member_variable == 1234)

assert(v.RenamePredicates_MV_static_member_variable == 456)
v.RenamePredicates_MV_static_member_variable = 4567
assert(v.RenamePredicates_MV_static_member_variable == 4567)

assert(v.GV_global_variable == 789)
v.GV_global_variable = 7890
assert(v.GV_global_variable == 7890)

v.UC_UPPERCASE()
v.LC_lowercase()
v.TI_Title()
v.FU_FirstUpperCase()
v.FL_firstLowerCase()
v.CA_CamelCase()
v.LC_lowerCamelCase()
v.UC_under_case_it()

local ex = v.ExtendCheck()
ex:MF_real_member1()
ex:MF_real_member2()
ex:EX_EXTENDMETHOD1()
ex:EX_EXTENDMETHOD2()
ex:EX_EXTENDMETHOD3()
