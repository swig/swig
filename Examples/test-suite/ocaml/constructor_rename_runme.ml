open Swig
open Constructor_rename

let x = new_RenamedConstructor '()
let _ = assert ((x -> ":classof" () as string) = "Foo")
