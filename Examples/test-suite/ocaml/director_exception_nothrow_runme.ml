open Swig
open Director_exception_nothrow

let _MyBar ob meth args =
  match meth with
    | "pang" -> C_string "_MyBar::pang()"
    | _ -> (invoke ob) meth args

let a = new_derived_object new_Bar (_MyBar) '()
let _ =  assert (_MyBar a "pang" '() as string = "_MyBar::pang()")
let b = new_Bar '()
let _ =  assert (b -> pang () as string = "Bar::pang()")
