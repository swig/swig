var rename_predicates = require("rename_predicates");

var r = new rename_predicates.RenamePredicates(123);
/* await */(r.MF_member_function());
/* await */(rename_predicates.RenamePredicates.MF_static_member_function());
/* await */(r.MF_extend_function_before());
/* await */(r.MF_extend_function_after());
/* await */(rename_predicates.GF_global_function());

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

/* await */(rename_predicates.UC_UPPERCASE());
/* await */(rename_predicates.LC_lowercase());
/* await */(rename_predicates.TI_Title());
/* await */(rename_predicates.FU_FirstUpperCase());
/* await */(rename_predicates.FL_firstLowerCase());
/* await */(rename_predicates.CA_CamelCase());
/* await */(rename_predicates.LC_lowerCamelCase());
/* await */(rename_predicates.UC_under_case_it());

var ex = new rename_predicates.ExtendCheck();
/* await */(ex.MF_real_member1());
/* await */(ex.MF_real_member2());
/* await */(ex.EX_EXTENDMETHOD1());
/* await */(ex.EX_EXTENDMETHOD2());
/* await */(ex.EX_EXTENDMETHOD3());
