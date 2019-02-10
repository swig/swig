open Swig
open Rename_predicates

let _ =
  let r = new_RenamePredicates '(123) in
  assert (r -> MF_member_function () = C_void);
  assert (_RenamePredicates_MF_static_member_function '() = C_void);
  assert (r -> MF_member_function () = C_void);
  assert (r -> MF_extend_function_before () = C_void);
  assert (r -> MF_extend_function_after () = C_void);
  assert (_GF_global_function '() = C_void);

  assert (r -> "[MV_member_variable]" () as int = 123);
  assert (r -> "[MV_member_variable]" (1234) = C_void);
  assert (r -> "[MV_member_variable]" () as int = 1234);

  assert (_RenamePredicates_MV_static_member_variable '() as int = 456);
  assert (_RenamePredicates_MV_static_member_variable '(4567) as int = 4567);
  assert (_RenamePredicates_MV_static_member_variable '() as int = 4567);

  assert (_GV_global_variable '() as int = 789);
  assert (_GV_global_variable '(7890) as int = 7890);
  assert (_GV_global_variable '() as int = 7890);

  assert (_UC_UPPERCASE '() = C_void);
  assert (_LC_lowercase '() = C_void);
  assert (_TI_Title '() = C_void);
  assert (_FU_FirstUpperCase '() = C_void);
  assert (_FL_firstLowerCase '() = C_void);
  assert (_CA_CamelCase '() = C_void);
  assert (_LC_lowerCamelCase '() = C_void);
  assert (_UC_under_case_it '() = C_void);

  let ex = new_ExtendCheck '() in
  assert (ex -> MF_real_member1 () = C_void);
  assert (ex -> MF_real_member2 () = C_void);
  assert (ex -> EX_EXTENDMETHOD1 () = C_void);
  assert (ex -> EX_EXTENDMETHOD2 () = C_void);
  assert (ex -> EX_EXTENDMETHOD3 () = C_void)
;;
