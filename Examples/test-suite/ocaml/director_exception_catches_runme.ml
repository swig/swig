open Swig
open Director_exception_catches

exception CustomException of string

let new_MyClass ob meth args =
  match meth with
    | "description" -> raise (CustomException "CustomException thrown in description().")
    | _ -> (invoke ob) meth args

let b = new_derived_object new_BaseClass (new_MyClass) '()
try
  ignore (_BaseClass_call_description (b)); assert false
with CustomException s ->
  assert (s = "CustomException thrown in description().")
