open Swig
open Typedef_inherit

let _ =
  let a = new_Foo '() and b = new_Bar '() in
  assert (_do_blah (a) as string = "Foo::blah");
  assert (_do_blah (b) as string = "Bar::blah");
  let c = new_Spam '() and d = new_Grok '() in
  assert (_do_blah2 (c) as string = "Spam::blah");
  assert (_do_blah2 (d) as string = "Grok::blah");
  assert (d -> far() as string = "Spam::far")
;;
