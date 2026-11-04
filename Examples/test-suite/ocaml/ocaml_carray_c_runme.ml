open Swig
open Ocaml_carray_c

let new_item v =
  let item = new_CarrayItem '() in
  ignore ((invoke item) "[value]" (C_int v));
  item

let _ =
  let ints = C_array (Array.init 8 (fun i -> C_int (i + 1))) in
  assert (_sum_ints ints as int = 36);
  let doubles = C_array [| C_double 0.5; C_double 1.5; C_double 2.5; C_double 3.5 |] in
  assert (_sum_doubles doubles as float = 8.);
  let schars = C_array [| C_int (-1); C_int 2; C_int (-3); C_int 4 |] in
  assert (_sum_schars schars as int = 2);
  let uchars = C_array [| C_int 200; C_int 50; C_int 1; C_int 4 |] in
  assert (_sum_uchars uchars as int = 255);
  assert (_sum_items (C_array [| new_item 3; new_item 4 |]) as int = 7);
  assert (_count_chars (C_string "ab") as int = 2);
  (* C_void is passed as NULL for an array parameter *)
  assert (_sum_ints (C_list [ C_void ]) as int = -1);
  assert (_sum_doubles (C_list [ C_void ]) as float = -1.);
  assert (_sum_items (C_list [ C_void ]) as int = -1);
  (* Setting an array member variable to C_void raises an error, as there is nothing to copy from *)
  let m = new_CarrayMember '() in
  ignore ((invoke m) "[ints]" ints);
  assert (try ignore ((invoke m) "[ints]" (C_list [ C_void ])); false with Invalid_argument _ -> true);
  assert (_sum_ints ((invoke m) "[ints]" C_void) as int = 36)
;;

let _ =
  let ints = C_array [| C_int 5; C_int 7; C_int 9 |] in
  assert (_sum_ints_unknown_size (C_list [ ints; C_int 3 ]) as int = 21);
  let doubles = C_array [| C_double 0.25; C_double 0.5 |] in
  assert (_sum_doubles_unknown_size (C_list [ doubles; C_int 2 ]) as float = 0.75);
  let items = C_array [| new_item 1; new_item 2; new_item 3; new_item 4 |] in
  assert (_sum_items_unknown_size (C_list [ items; C_int 4 ]) as int = 10);
  let colors = C_array [| C_enum `CARRAY_RED; C_enum `CARRAY_BLUE; C_enum `CARRAY_BLUE |] in
  assert (_sum_colors_unknown_size (C_list [ colors; C_int 3 ]) as int = 9);
  assert (_sum_ints_unknown_size (C_list [ C_void; C_int 0 ]) as int = -1);
  assert (_sum_items_unknown_size (C_list [ C_void; C_int 0 ]) as int = -1);
  assert (_sum_colors_unknown_size (C_list [ C_void; C_int 0 ]) as int = -1)
;;

let _ =
  let colors = C_array [| C_enum `CARRAY_RED; C_enum `CARRAY_GREEN; C_enum `CARRAY_BLUE |] in
  assert (_sum_colors colors as int = 7);
  assert (_sum_colors (C_list [ C_void ]) as int = -1);
  (* An array shorter than a fixed size array is an error *)
  let too_short f = try ignore (f ()); false with Invalid_argument _ -> true in
  assert (too_short (fun () -> _sum_ints (C_array [| C_int 1; C_int 2 |])));
  assert (too_short (fun () -> _sum_doubles (C_array [| C_double 0.5 |])));
  assert (too_short (fun () -> _sum_items (C_array [| new_item 3 |])));
  assert (too_short (fun () -> _sum_colors (C_array [| C_enum `CARRAY_RED |])));
  let m = new_CarrayMember '() in
  assert (too_short (fun () -> (invoke m) "[ints]" (C_array [| C_int 1 |])))
;;
