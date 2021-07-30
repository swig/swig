open Swig
open Abstract_access

let d = new_D '()
let _ = assert ((d -> "do_x" () as int) = 1)
