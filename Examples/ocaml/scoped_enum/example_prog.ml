open Swig
open Example

let _ = _f (match Sys.argv.(1) with "Tag1" -> ``Tag1 | "Tag2" -> ``Tag2)
