open Swig
open Template_ref_type

let xr = new_XC '()
let y = new_Y '()
let _ = y -> find (xr)
