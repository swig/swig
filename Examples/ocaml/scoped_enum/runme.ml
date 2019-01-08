open Swig
open Example

let arg = if Array.length Sys.argv > 1 then Sys.argv.(1) else "Tag1"
let _ = _f (match arg with "Tag1" -> ``Tag1 | _ -> ``Tag2)
