open Swig
open Li_std_string

let _ =
  assert (_test_value '("Fee") as string = "Fee");
  try
    ignore (_test_value '(None)); assert false
  with Invalid_argument _ -> ()

  assert (_test_const_reference '("Fee") as string = "Fee");
  try
    ignore (_test_const_reference '(None)); assert false
  with Invalid_argument _ -> ()

  let stringPtr = _test_pointer_out '() in
  ignore (_test_pointer '(stringPtr));
  let stringPtr = _test_const_pointer_out '() in
  ignore (_test_const_pointer '(stringPtr));
  let stringPtr = _test_reference_out '() in
  ignore (_test_reference '(stringPtr));

  try
    ignore (_test_throw '()); assert false
  with Failure s -> assert (s = "test_throw message")
  try
    ignore (_test_const_reference_throw '()); assert false
  with Failure s -> assert (s = "test_const_reference_throw message")
  assert (_GlobalString2 '() as string = "global string 2");
  let s = C_string "initial string" in
  ignore (_GlobalString2 '(s));
  assert (_GlobalString2 '() = s);
  assert (_ConstGlobalString '() as string = "const global string");

  let myStructure = new_Structure '() in
  assert (myStructure -> "[MemberString2]" () as string = "member string 2");
  assert (myStructure -> "[MemberString2]" (s) = C_void);
  assert (myStructure -> "[MemberString2]" () = s);
  assert (myStructure -> "[ConstMemberString]" () as string = "const member string");

  assert (_Structure_StaticMemberString2 '() as string = "static member string 2");
  ignore (_Structure_StaticMemberString2 '(s));
  assert (_Structure_StaticMemberString2 '() = s);
  assert (_Structure_ConstStaticMemberString '() as string = "const static member string")

  assert (_stdstring_empty '() as string = "")
  assert (_c_empty '() as string = "")
  (* FIXME: Can't work out what C++ NULL maps to here...
  assert (_c_null '() = None)
  assert (_get_null (_c_null '()) = None)
  *)
  assert (_get_null (_c_empty '()) as string = "non-null")
  assert (_get_null (_stdstring_empty '()) as string = "non-null")
;;
