open Swig
open Mod_a
open Mod_b

let c = new_C '()
let d = new_D '()
let _ = d -> "DoSomething" (c)
