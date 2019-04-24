open Swig
open Exception_order

let a = new_A '()

let check meth args expected =
  try
    ignore ((invoke a) meth (args)); assert false
  with Failure msg -> assert (msg = expected)

let _ =
  check "foo" '() "C++ E1 exception thrown";
  check "bar" '() "C++ E2 exception thrown";
  check "foobar" '() "postcatch unknown";
  check "barfoo" (C_int 1) "C++ E1 exception thrown";
  check "barfoo" (C_int 2) "C++ E2 * exception thrown";
;;
