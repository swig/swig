open Swig
open Director_classes

let held = new_DoubleHolder '(4.5)

let director_classes_OCamlDerived ob meth args =
  match meth with
    | "Ref" -> held
    | "ConstPtrRef" -> held
    | _ -> (invoke ob) meth args

let director_classes_NotOverridden ob meth args = (invoke ob) meth args

let director_classes_NullRef ob meth args =
  match meth with
    | "Ref" -> C_void
    | _ -> (invoke ob) meth args

let _ =
  let caller = new_Caller '() in
  let dh = new_DoubleHolder '(444.555) in
  let b = new_Base '(100.0) in
  ignore (caller -> set (b));
  assert ((caller -> RefCall (dh)) -> "[val]" () as float = 444.555);
  assert ((caller -> ConstPtrRefCall (dh)) -> "[val]" () as float = 444.555);
  ignore (caller -> reset ());
  let p = new_derived_object new_Base (director_classes_NotOverridden) '(200.0) in
  ignore (caller -> set (p));
  assert ((caller -> ConstPtrRefCall (dh)) -> "[val]" () as float = 444.555);
  ignore (caller -> reset ());
  let d = new_derived_object new_Base (director_classes_OCamlDerived) '(300.0) in
  ignore (caller -> set (d));
  assert ((caller -> RefCall (dh)) -> "[val]" () as float = 4.5);
  assert ((caller -> ConstPtrRefCall (dh)) -> "[val]" () as float = 4.5);
  ignore (caller -> reset ());
  let n = new_derived_object new_Base (director_classes_NullRef) '(400.0) in
  ignore (caller -> set (n));
  (try
    ignore (caller -> RefCall (dh)); assert false
  with Invalid_argument _ -> ());
  ignore (caller -> reset ())
;;
