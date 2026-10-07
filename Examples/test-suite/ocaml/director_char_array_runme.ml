open Swig
open Director_char_array

let director_unroll ob meth args =
  match meth with
    | "take_array" | "take_const_array" | "take_array_ref" | "take_const_array_ref" ->
      (match args with
         | C_list [ s ] -> C_int (String.length (s as string))
         | _ -> raise (Failure meth))
    | "is_null_array" ->
      (match args with
         | C_list [ C_string _ ] -> C_int 0
         | C_list [ _ ] -> C_int 1
         | _ -> raise (Failure meth))
    | _ -> (invoke ob) meth args

let d = new_derived_object new_CharArrayDirector (director_unroll) '()
let _ =
  assert (d -> call_take_array () as int = 4);
  assert (d -> call_take_const_array () as int = 4);
  assert (d -> call_take_array_ref () as int = 4);
  assert (d -> call_take_const_array_ref () as int = 4);
  assert (d -> call_take_array_short () as int = 2);
  assert (d -> call_take_array_ref_short () as int = 2);
  assert (d -> call_is_null_array () as int = 1)
