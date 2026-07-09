open Swig
open Char_strings

let cpp_msg = "A message from the deep dark world of C++, where anything is possible."
let other_msg = "Little message from the safe world."

(* Note: the swigp4 syntax extension overloads the "to" keyword as a cast
   operator, so "for i = 0 to n" cannot be used here - iterate with List.iter. *)
let iters = [ 0; 1; 2; 3; 4 ]

(* Each set function takes (string, number) and returns true when the string
   received matches OTHERLAND_MSG concatenated with number. *)
let test_set setter =
  List.iter (fun i ->
    let msg = other_msg ^ string_of_int i in
    assert (setter (C_list [ C_string msg ; C_int i ]) as bool = true)
  ) iters

(* The char *& / const char *& set functions have an "argout" typemap that also
   returns the referenced string, so the result is a list [string; bool] with
   the bool return value last. *)
let test_set_ref setter =
  List.iter (fun i ->
    let msg = other_msg ^ string_of_int i in
    match setter (C_list [ C_string msg ; C_int i ]) with
      C_list [ _ ; b ] -> assert (get_bool b = true)
    | _ -> assert false
  ) iters

let test_pingpong pp =
  List.iter (fun i ->
    let msg = other_msg ^ string_of_int i in
    assert (pp (C_string msg) as string = msg)
  ) iters

let _ =
  (* get functions *)
  List.iter (fun _i ->
    assert (_GetCharHeapString C_void as string = cpp_msg);
    ignore (_DeleteCharHeapString C_void)
  ) iters;
  List.iter (fun _i ->
    assert (_GetConstCharProgramCodeString C_void as string = cpp_msg);
    ignore (_DeleteCharHeapString C_void)
  ) iters;
  assert (_GetCharStaticString C_void as string = cpp_msg);
  assert (_GetCharStaticStringFixed C_void as string = cpp_msg);
  assert (_GetConstCharStaticStringFixed C_void as string = cpp_msg);

  (* set functions.  The char[] parameter variants (SetCharArrayStaticString,
     SetConstCharArrayStaticString) are omitted: OCaml's char[] 'in' typemap
     strcpy's into the (null) argument pointer and crashes - a pre-existing
     char array limitation unrelated to char *&. *)
  test_set _SetCharHeapString;
  test_set _SetCharStaticString;
  test_set _SetConstCharHeapString;
  test_set _SetConstCharStaticString;
  test_set _SetCharConstStaticString;
  test_set _SetConstCharConstStaticString;
  test_set _SetConstCharTypedefString;

  (* get set function.  CharArrayPingPong / CharArrayDimsPingPong take char[]
     parameters and are omitted for the same char array limitation as above. *)
  test_pingpong _CharPingPong;

  (* variables: settable globals - set then read back *)
  List.iter (fun i ->
    let msg = other_msg ^ string_of_int i in
    assert (_global_char (C_string msg) as string = msg);
    assert (_global_char C_void as string = msg)
  ) iters;
  List.iter (fun i ->
    let msg = other_msg ^ string_of_int i in
    assert (_global_char_array1 (C_string msg) as string = msg);
    assert (_global_char_array1 C_void as string = msg)
  ) iters;
  List.iter (fun i ->
    let msg = other_msg ^ string_of_int i in
    assert (_global_char_array2 (C_string msg) as string = msg);
    assert (_global_char_array2 C_void as string = msg)
  ) iters;

  (* variables: read-only const globals *)
  assert (_global_const_char C_void as string = cpp_msg);
  assert (_global_const_char_array1 C_void as string = cpp_msg);
  assert (_global_const_char_array2 C_void as string = cpp_msg);

  (* char *& tests *)
  assert (_GetCharPointerRef C_void as string = cpp_msg);
  test_set_ref _SetCharPointerRef;
  assert (_GetConstCharPointerRef C_void as string = cpp_msg);
  test_set_ref _SetConstCharPointerRef
;;
