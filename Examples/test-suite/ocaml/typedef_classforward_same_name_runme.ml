open Swig
open Typedef_classforward_same_name

let _ =
  let foo = new_Foo '() in
  ignore (foo -> "[x]" (5));
  assert (_extractFoo '(foo) as int = 5);
  let boo = new_Boo '() in
  ignore (boo -> "[x]" (5));
  assert (_extractBoo '(boo) as int = 5)
;;
