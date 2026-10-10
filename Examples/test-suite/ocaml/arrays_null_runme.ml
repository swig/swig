open Swig
open Arrays_null

let fails f = try ignore (f ()); false with Failure _ -> true

let _ =
  (* Without array typemaps, such as those in carray.i, an array argument of any kind fails, so C_void does too *)
  assert (fails (fun () -> _arrays_null_ints_isnull (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_ints_unsized_isnull (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_enums_isnull (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_enums_unsized_isnull (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_items_isnull (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_items_unsized_isnull (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_bools_isnull (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_bools_unsized_isnull (C_list [ C_void ])));
  assert (_arrays_null_chars_isnull (C_list [ C_void ]) as int = 1);
  assert (_arrays_null_chars_unsized_isnull (C_list [ C_void ]) as int = 1);
  assert (fails (fun () -> _arrays_null_strings_isnull (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_strings_unsized_isnull (C_list [ C_void ])));

  let s = new_ArraysNull '() in
  ignore (_arrays_null_fill (C_list [ s; C_int 10 ]));
  (* Setting an array member variable fails in the same way and leaves it unchanged *)
  assert (fails (fun () -> (invoke s) "[ints]" (C_list [ C_void ])));
  assert (fails (fun () -> (invoke s) "[items]" (C_list [ C_void ])));
  assert (fails (fun () -> (invoke s) "[grid]" (C_list [ C_void ])));
  assert (_arrays_null_check (C_list [ s; C_int 10 ]) as int = 1);

  (* C_void alone reads a global variable, so one cannot be set to NULL, and setting an array one fails as well *)
  assert (fails (fun () -> _arrays_null_ints (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_items (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_grid (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_ints_ref (C_list [ C_void ])));
  assert (fails (fun () -> _arrays_null_bools (C_list [ C_void ])))
;;
