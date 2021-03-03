open Swig
open Template_tbase_template

let a = _make_Class_dd '()
assert (a -> test () as string = "test")
