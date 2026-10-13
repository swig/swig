open Swig
open Arrays_null

let null_rejected f = try ignore (f ()); false with Invalid_argument _ -> true

let _ =
  let s = new_ArraysNull '() in
  let other = new_ArraysNull '() in
  ignore (_arrays_null_fill (C_list [ other; C_int 10 ]));
  ignore ((invoke s) "[ints]" ((invoke other) "[ints]" C_void));
  ignore ((invoke s) "[items]" ((invoke other) "[items]" C_void));
  ignore ((invoke s) "[grid]" ((invoke other) "[grid]" C_void));
  assert (_arrays_null_check (C_list [ s; C_int 10 ]) as int = 1);

  (* Setting an array member or global variable to NULL is an error, as there is nothing to copy from *)
  assert (null_rejected (fun () -> (invoke s) "[ints]" (C_list [ C_void ])));
  assert (null_rejected (fun () -> (invoke s) "[items]" (C_list [ C_void ])));
  assert (null_rejected (fun () -> (invoke s) "[grid]" (C_list [ C_void ])));
  assert (_arrays_null_check (C_list [ s; C_int 10 ]) as int = 1);

  ignore (_arrays_null_ints ((invoke s) "[ints]" C_void));
  ignore (_arrays_null_items ((invoke s) "[items]" C_void));
  ignore (_arrays_null_grid ((invoke s) "[grid]" C_void));
  assert (_arrays_null_globals_check (C_int 10) as int = 1);

  (* C_void alone reads a global variable, so a NULL pointer is used to set one to NULL *)
  let null = C_ptr (0L, 0L) in
  assert (null_rejected (fun () -> _arrays_null_ints null));
  assert (null_rejected (fun () -> _arrays_null_items null));
  assert (null_rejected (fun () -> _arrays_null_grid null));
  assert (null_rejected (fun () -> _arrays_null_ints_ref null));
  assert (null_rejected (fun () -> _arrays_null_bools null));
  assert (_arrays_null_globals_check (C_int 10) as int = 1);

  (* C_void is passed on as a NULL pointer for an array parameter *)
  assert (_arrays_null_ints_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_ints_unsized_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_enums_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_enums_unsized_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_items_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_items_unsized_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_bools_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_bools_unsized_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_chars_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_chars_unsized_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_strings_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_strings_unsized_isnull (C_list [ C_void ]) as int = 1);

  (* A reference to an array cannot be NULL *)
  assert (null_rejected (fun () -> _arrays_null_ints_ref_first (C_list [ C_void ])))
;;
