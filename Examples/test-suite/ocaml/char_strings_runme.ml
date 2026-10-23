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

  (* set functions *)
  test_set _SetCharHeapString;
  test_set _SetCharStaticString;
  test_set _SetCharArrayStaticString;
  test_set _SetConstCharHeapString;
  test_set _SetConstCharStaticString;
  test_set _SetConstCharArrayStaticString;
  test_set _SetCharConstStaticString;
  test_set _SetConstCharConstStaticString;
  test_set _SetConstCharTypedefString;

  (* get set function *)
  test_pingpong _CharPingPong;
  test_pingpong _CharArrayPingPong;
  List.iter (fun i ->
    let msg = "Ping" ^ string_of_int i in
    assert (_CharArrayDimsPingPong (C_string msg) as string = msg)
  ) iters;
  assert (_CharArrayDimsLength (C_string "Ping") as int = 4);
  assert (_CharArrayDimsLength (C_string "0123456789abcde") as int = 15);
  assert (try ignore (_CharArrayDimsLength (C_string "0123456789abcdef")); false with Invalid_argument _ -> true);

  (* variables: settable globals - set then read back *)
  List.iter (fun i ->
    let msg = other_msg ^ string_of_int i in
    assert (_global_char (C_string msg) as string = msg);
    assert (_global_char C_void as string = msg)
  ) iters;
  (* global_char_array1 is a char[] with no size, so it is read only *)
  assert (_global_char_array1 C_void as string = cpp_msg);
  assert (try ignore (_global_char_array1 (C_string other_msg)); false with Failure _ -> true);
  List.iter (fun i ->
    let msg = other_msg ^ string_of_int i in
    assert (_global_char_array2 (C_string msg) as string = msg);
    assert (_global_char_array2 C_void as string = msg)
  ) iters;
  assert (try ignore (_global_char_array2 (C_string (cpp_msg ^ cpp_msg))); false with Invalid_argument _ -> true);
  let no_nul = create_CharArrayNoNul_from_ptr (_char_array_no_nul C_void) in
  assert ((invoke no_nul) "[full]" C_void as string = "abcd");
  assert ((invoke no_nul) "[after]" C_void as string = "XYZ");
  assert (_global_char_one (C_string "a") as string = "a");
  let one = new_CharArrayOne C_void in
  ignore ((invoke one) "[one]" (C_string "b"));
  assert ((invoke one) "[one]" C_void as string = "b");
  assert (match _CharArrayPingPong (C_list [ C_void ]) with C_string _ -> false | _ -> true);
  assert (match _CharArrayDimsPingPong (C_list [ C_void ]) with C_string _ -> false | _ -> true);
  let null_member = create_CharArrayNull_from_ptr (_char_array_null C_void) in
  assert (try ignore ((invoke null_member) "[four]" (C_list [ C_void ])); false with Invalid_argument _ -> true);
  assert ((invoke null_member) "[four]" C_void as string = "qqq");

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
