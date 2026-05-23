open Swig
open Director_minimal

let director_unroll_MyMinimal ob meth args =
  match meth with
    | "run" -> C_bool true
    | _ -> (invoke ob) meth args

let c = new_derived_object
  new_Minimal (director_unroll_MyMinimal) '()
let _ = assert ((c -> get () as bool) = true)
