open Swig
open Director_primitives

let many_parms_args = ref C_void

let director_primitives_MyBase ob meth args =
  match meth with
    | "IntMethod" ->
      (match args with
         | C_list [ x ] -> x
         | _ -> raise (Failure meth))
    | "EnumMethod" ->
      (match args with
         | C_list [ C_enum `HShadowSoft ] -> C_enum `HShadowHard
         | C_list [ C_enum `HShadowNone ] -> C_enum `HShadowNone
         | _ -> raise (Failure meth))
    | "ManyParmsMethod" -> many_parms_args := args; C_void
    | _ -> (invoke ob) meth args

let _ =
  let caller = new_Caller '() in
  let d = new_derived_object new_Base (director_primitives_MyBase) '(100.0) in
  ignore (caller -> set (d));
  assert (caller -> IntMethodCall ((C_int (-123))) as int = -123);
  assert (caller -> EnumMethodCall ((C_enum `HShadowSoft)) = C_enum `HShadowHard);
  assert (caller -> EnumMethodCall ((C_enum `HShadowNone)) = C_enum `HShadowNone);
  ignore (caller -> ManyParmsMethodCall ((C_bool true), (C_int (-123)), (C_int 123), (C_double 123.5), "test string", "another string", (C_enum `HShadowHard)));
  (match !many_parms_args with
     | C_list [ _; _; _; _; _; _; h ] -> assert (h = C_enum `HShadowHard)
     | _ -> assert false);
  ignore (caller -> reset ());
  let b = new_Base '(200.0) in
  ignore (caller -> set (b));
  assert (caller -> EnumMethodCall ((C_enum `HShadowSoft)) = C_enum `HShadowSoft);
  ignore (caller -> reset ());
;;
