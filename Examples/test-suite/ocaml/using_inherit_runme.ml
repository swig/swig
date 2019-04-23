open Swig
open Using_inherit

let _ =
  let b = new_Bar '() in
  assert (b -> test (3) as int = 3);
  assert (b -> test (3.5) as float = 3.5);
  let b = new_Bar2 '() in
  assert (b -> test (3) as int = 6);
  assert (b -> test (3.5) as float = 7.0);
  let b = new_Bar3 '() in
  assert (b -> test (3) as int = 6);
  assert (b -> test (3.5) as float = 7.0);
  let b = new_Bar4 '() in
  assert (b -> test (3) as int = 6);
  assert (b -> test (3.5) as float = 7.0);

  let f = new_Fred1 '() in
  assert (f -> test (3) as int = 3);
  assert (f -> test (3.5) as float = 7.0);
  let f = new_Fred2 '() in
  assert (f -> test (3) as int = 3);
  assert (f -> test (3.5) as float = 7.0)
;;
