open Swig
open C99_vla_array_libraries

let _ =
  let ints = C_array [| C_int 1; C_int 2; C_int 3 |] in
  assert (_sum_ints (C_list [ C_int 3; ints ]) as int = 6);
  (* Only as many elements as the size given at runtime are copied, a shorter array being an error *)
  assert (_sum_ints (C_list [ C_int 2; ints ]) as int = 3);
  assert (try ignore (_sum_ints (C_list [ C_int 4; ints ])); false with Invalid_argument _ -> true);
  let doubles = C_array [| C_double 0.5; C_double 1.5 |] in
  assert (_sum_doubles (C_list [ C_int 2; doubles ]) as float = 2.);
  let colours = C_array [| C_enum `GREEN; C_enum `BLUE |] in
  assert (_sum_colours (C_list [ C_int 2; colours ]) as int = 3);
  assert (_sum_const_colours (C_list [ C_int 2; colours ]) as int = 3);
  assert (try ignore (_sum_colours (C_list [ C_int 3; colours ])); false with Invalid_argument _ -> true);
  let new_item v =
    (* new_Item returns a raw pointer for a C struct used without a typedef *)
    let item = create_Item_from_ptr (new_Item '()) in
    ignore ((invoke item) "[value]" (C_int v));
    item in
  let items = C_array [| new_item 3; new_item 4 |] in
  assert (_sum_items (C_list [ C_int 2; items ]) as int = 7);
  assert (_sum_items (C_list [ C_int 1; items ]) as int = 3);
  assert (try ignore (_sum_items (C_list [ C_int 3; items ])); false with Invalid_argument _ -> true)
;;
