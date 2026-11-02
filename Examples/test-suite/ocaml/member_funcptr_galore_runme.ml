open Swig
open Member_funcptr_galore

let _ =
  let m = new_MemberFuncPtrs '() in
  let cc1 = _cc1 '() in
  let cc7 = _cc7 '() in
  let pp1 = _pp1 '() in
  let cc5 = _cc5 '() in
  let pp5 = _pp5 '() in
  assert (m -> aaa1 (cc1) as int = 0);
  assert (m -> aaa6 (cc1) as int = 0);
  assert (m -> aaa7 (cc1) as int = 0);
  assert (m -> aaa1 (cc7) as int = 0);
  assert (m -> aaa7 (cc7) as int = 0);
  assert (m -> bbb7 (pp1) as int = 0);
  assert (m -> aaa5 (cc5) as int = 0);
  assert (m -> bbb5 (pp5) as int = 0);
  let add_by_value = _ADD_BY_VALUE '() in
  assert (_call1 '(add_by_value, 1, 2) as int = 3);
  (try
    ignore (m -> aaa7 (pp1)); assert false
  with Failure _ -> ());
  (* A non-const reference to a member pointer takes a pointer to a member pointer, not a member pointer *)
  (try
    ignore (m -> aaa5 (cc1)); assert false
  with Failure _ -> ());
  (try
    ignore (m -> bbb5 (pp1)); assert false
  with Failure _ -> ());
  (try
    ignore (m -> bbb3 (pp1)); assert false
  with Failure _ -> ());
  try
    ignore (m -> bbb7 (cc1)); assert false
  with Failure _ -> ()
;;
