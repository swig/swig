var rename_predicates = require("rename_predicates");

r = new rename_predicates.RenamePredicates(123);
r.MF_member_function();
rename_predicates.RenamePredicates.MF_static_member_function();
r.MF_extend_function_before();
r.MF_extend_function_after();
rename_predicates.GF_global_function();

if (r.MV_member_variable != 123) {
    throw new Error("variable wrong");
}
r.MV_member_variable = 1234;
if (r.MV_member_variable != 1234) {
    throw new Error("variable wrong");
}

if (rename_predicates.RenamePredicates.MV_static_member_variable != 456) {
    throw new Error("variable wrong");
}
rename_predicates.RenamePredicates_MV_static_member_variable = 4567;
if (rename_predicates.RenamePredicates_MV_static_member_variable != 4567) {
    throw new Error("variable wrong");
}

if (rename_predicates.GV_global_variable != 789) {
    throw new Error("variable wrong");
}
rename_predicates.GV_global_variable = 7890;
if (rename_predicates.GV_global_variable != 7890) {
    throw new Error("variable wrong");
}

rename_predicates.UC_UPPERCASE();
rename_predicates.LC_lowercase();
rename_predicates.TI_Title();
rename_predicates.FU_FirstUpperCase();
rename_predicates.FL_firstLowerCase();
rename_predicates.CA_CamelCase();
rename_predicates.LC_lowerCamelCase();
rename_predicates.UC_under_case_it();

ex = new rename_predicates.ExtendCheck();
ex.MF_real_member1();
ex.MF_real_member2();
ex.EX_EXTENDMETHOD1();
ex.EX_EXTENDMETHOD2();
ex.EX_EXTENDMETHOD3();
