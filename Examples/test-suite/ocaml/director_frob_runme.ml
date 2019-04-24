open Swig
open Director_frob

let foo = new_Bravo '()
assert (foo -> abs_method () as string = "Bravo::abs_method()")
