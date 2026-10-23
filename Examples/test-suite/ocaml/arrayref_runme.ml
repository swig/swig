open Swig
open Arrayref

(* OCaml has no typemap for assigning to an array variable of an arbitrary type, so setting
   numbers_ref is left out here for the same reason setting numbers itself would be. *)

let () =
  assert (_numbers_sum C_void as int = 10);

  (* An array of char is a string here, and so is a reference to one. *)
  assert (_letters C_void as string = "abc");
  assert (_letters_ref C_void as string = "abc");
  assert (_letters_ref (C_string "xy") as string = "xy");
  assert (_letters_are C_void as string = "xy");
  assert (_frozen_ref C_void as string = "xyz");
  assert (_length_of_writable (C_string "abc") as int = 3);
  assert (try ignore (_length_of_writable (C_list [ C_void ])); false with Invalid_argument _ -> true);
  assert (try ignore (_length_of_writable (C_string "abcdefgh")); false with Invalid_argument _ -> true)
