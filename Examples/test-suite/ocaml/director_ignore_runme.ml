open Swig
open Director_ignore

let _DIgnoresDerived ob meth args =
  match meth with
    | "OverloadedMethod" -> C_int 0
    | _ -> (invoke ob) meth args

let a =new_derived_object new_DIgnores (_DIgnoresDerived) '()
let _ = assert (a -> Triple (5) as int = 15)

let _DAbstractIgnoresDerived ob meth args =
  match meth with
    | "OverloadedMethod" -> C_int 0
    | _ -> (invoke ob) meth args

let a = new_derived_object new_DAbstractIgnores (_DAbstractIgnoresDerived) '()
let _ = assert (a -> Quadruple (5) as int = 20)
