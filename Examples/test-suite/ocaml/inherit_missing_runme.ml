open Swig
open Inherit_missing

let _ =
  let a = _new_Foo '() and b = new_Bar '() and c = new_Spam '() in
  assert (_do_blah '(a) as string =  "Foo::blah");
  assert (_do_blah '(b) as string =  "Bar::blah");
  assert (_do_blah '(c) as string =  "Spam::blah");
  assert (_delete_Foo '(a) =  C_void)
;;
