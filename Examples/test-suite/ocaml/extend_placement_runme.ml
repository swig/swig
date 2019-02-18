open Swig
open Extend_placement

let _ =
  let f = new_Foo '() in
  assert (f -> spam () as int = 1);
  assert (new_Foo '(1) -> spam () as int = 1);
  let f = new_Foo '(1, 1) in
  assert (f -> spam () as int = 1);
  assert (f -> spam ("hello") as int = 2);
  assert (f -> spam (1) as int = 1);
  assert (f -> spam (1, 2) as int = 3);
  assert (f -> spam (2, 4, 6) as int = 6);
  assert (f -> spam (f) as int = 0);
  let arg = C_double 1. in
  assert (f -> spam (f, arg) as int = 0);

  assert (new_Bar '() -> spam () as int = 1);
  let b = new_Bar '(1) in
  assert (b -> spam () as int = 1);
  assert (b -> spam ("hello") as int = 2);
  assert (b -> spam (1) as int = 1);
  assert (b -> spam (1, 2) as int = 3);
  assert (b -> spam (2, 4, 6) as int = 6);
  assert (b -> spam (b) as int = 0);
  let arg = C_double 1. in
  assert (b -> spam (b, arg) as int = 0);

  assert (new_FooTi '() -> spam () as int = 1);
  assert (new_FooTi '(1) -> spam () as int = 1);
  let f = new_FooTi '(1, 1) in
  assert (f -> spam () as int = 1);
  assert (f -> spam ("hello") as int = 2);
  assert (f -> spam (1) as int = 1);
  assert (f -> spam (1, 2) as int = 3);
  assert (f -> spam (2, 4, 6) as int = 6);
  let foo = new_Foo '() in
  assert (f -> spam (foo) as int = 0);
  let arg = C_double 1. in
  assert (f -> spam (foo, arg) as int = 0);

  assert (new_BarTi '() -> spam () as int = 1);
  let b = new_BarTi '(1) in
  assert (b -> spam () as int = 1);
  assert (b -> spam ("hello") as int = 2);
  assert (b -> spam (1) as int = 1);
  assert (b -> spam (1, 2) as int = 3);
  assert (b -> spam (2, 4, 6) as int = 6);
  let bar = new_Bar '() in
  assert (b -> spam (bar) as int = 0);
  let arg = C_double 1. in
  assert (b -> spam (bar, arg) as int = 0);
;;
