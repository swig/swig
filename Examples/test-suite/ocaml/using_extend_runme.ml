open Swig
open Using_extend

let _ =
  let f = new_FooBar '() in
  assert (f -> blah (3) as int = 3);
  assert (f -> blah (3.5) as float = 3.5);
  assert (f -> blah ("hello") as string = "hello");
  assert (f -> blah (3, 4) as int = 7);
  assert (f -> blah (3.5, 7.5) as float = 11.);
  assert (f -> duh (3) as int = 3)
;;
