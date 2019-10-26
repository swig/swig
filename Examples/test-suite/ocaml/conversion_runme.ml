open Swig
open Conversion

let _ =
  let bar = new_Bar '() in
  assert (bar -> ":classof" () as string = "Bar");
  let foo = bar -> toFoo () in
  assert (foo -> ":classof" () as string = "Foo");
;;
