open Swig
open Using_private

let _ =
  let f = new_FooBar '() in
  let _ = f -> "[x]" (3) in
  assert (f -> blah (4) as int = 4);
  assert (f -> defaulted () as int = -1);
  assert (f -> defaulted (222) as int = 222)
;;
