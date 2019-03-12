open Swig
open Abstract_typedef

let e = new_Engine '()
let a = new_A '()
let _ =  assert ((a -> "write" (e) as bool) = true)
