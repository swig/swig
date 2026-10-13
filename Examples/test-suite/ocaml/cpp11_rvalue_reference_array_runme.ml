open Swig
open Cpp11_rvalue_reference_array

let null_rejected f = try ignore (f ()); false with Invalid_argument _ -> true

let () =
  (* An rvalue reference to an array is passed as a reference to an array, which cannot be NULL *)
  assert (_sum_of (_others_address C_void) as int = 100);
  assert (_first_of (_others_unsized_address C_void) as int = 10);
  assert (_items_sum (_items_address C_void) as int = 3);
  assert (null_rejected (fun () -> _sum_of (C_list [ C_void ])));
  assert (null_rejected (fun () -> _first_of (C_list [ C_void ])));

  (* An rvalue reference to an array of char is a string *)
  assert (_length_of (C_string "abc") as int = 3);
  assert (_length_of_writable (C_string "xy") as int = 2);
  assert (null_rejected (fun () -> _length_of (C_list [ C_void ])));

  (* Setting a variable that is an rvalue reference to an array copies into the array it refers to *)
  assert (_numbers_sum C_void as int = 10);
  ignore (_numbers_rref (_others_address C_void));
  assert (_numbers_sum C_void as int = 100);
  assert (_letters_rref C_void as string = "abc");
  ignore (_letters_rref (C_string "xy"));
  assert (_letters_are C_void as string = "xy");

  let member = new_RvalueRefArrayMember '() in
  assert ((invoke member) "sum" C_void as int = 10);
  ignore ((invoke member) "[member_rref]" (_others_address C_void));
  assert ((invoke member) "sum" C_void as int = 100);
  assert ((invoke member) "[text_rref]" C_void as string = "hi");
  ignore ((invoke member) "[text_rref]" (C_string "bye"));
  assert ((invoke member) "text_is" C_void as string = "bye")
