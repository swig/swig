open Swig
open Throw_exception

let x = new_Foo '()

let check meth args expected =
  try
    let _ = ((invoke x) meth (args)) in assert false
  with Failure msg -> assert (msg = expected)

let _ =
  check "test_int" '() "C++ int exception thrown, value: 37";
  check "test_msg" '() "Dead";
  check "test_cls" '() "C++ CError exception thrown";
  check "test_cls_ptr" '() "C++ CError * exception thrown";
  check "test_cls_ref" '() "C++ CError & exception thrown";
  check "test_cls_td" '() "C++ Namespace::ErrorTypedef exception thrown";
  check "test_cls_ptr_td" '() "C++ Namespace::ErrorPtr exception thrown";
  check "test_cls_ref_td" '() "C++ Namespace::ErrorRef exception thrown";
  check "test_array" '() "C++ int [10] exception thrown";
  check "test_enum" '() "C++ Namespace::EnumTest exception thrown";
  check "test_multi" '(1) "C++ int exception thrown, value: 37";
  check "test_multi" '(2) "Dead";
  check "test_multi" '(3) "C++ CError exception thrown";
;;
