open Swig
open Constover

let test_str = "test" to string
let _ =
  assert ((_test (test_str) as string) = "test");
  assert ((_test_pconst (test_str) as string) = "test_pconst");
;;

let f = new_Foo '()
let _ =
  assert ((f -> "test" (test_str) as string) = "test");
  assert ((f -> "test_pconst" (test_str) as string) = "test_pconst");
  assert ((f -> "test_constm" (test_str) as string) = "test_constmethod");
  assert ((f -> "test_pconstm" (test_str) as string) = "test_pconstmethod");
;;
