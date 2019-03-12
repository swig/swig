open Swig
open Template_inherit

let _ =
  let a = new_FooInt '() and b = new_FooDouble '() and c = new_BarInt '()
  and d = new_BarDouble '() and e = new_FooUInt '() and f = new_BarUInt '() in
  assert (a -> blah () as string = "Foo");
  assert (b -> blah () as string = "Foo");
  assert (e -> blah () as string = "Foo");
  assert (c -> blah () as string = "Bar");
  assert (d -> blah () as string = "Bar");
  assert (f -> blah () as string = "Bar");
  assert (c -> foomethod () as string = "foomethod");
  assert (d -> foomethod () as string = "foomethod");
  assert (f -> foomethod () as string = "foomethod");
  assert (_invoke_blah_int '(a) as string = "Foo");
  assert (_invoke_blah_int '(c) as string = "Bar");
  assert (_invoke_blah_double '(b) as string = "Foo");
  assert (_invoke_blah_double '(d) as string = "Bar");
  assert (_invoke_blah_uint '(e) as string = "Foo");
  assert (_invoke_blah_uint '(f) as string = "Bar")
;;
