open Swig
open Director_pass_by_value

let passByVal = ref [| |]

let director_pass_by_value_Derived ob meth args =
  match meth with
    | "virtualMethod" -> passByVal := Array.append !passByVal [|args|]; C_void
    | _ -> (invoke ob) meth args

let d =
  new_derived_object
    new_DirectorPassByValueAbstractBase
    (director_pass_by_value_Derived)
    '()

let _ =
  let caller = new_Caller '() in
  assert (caller -> call_virtualMethod (d) = C_void);
  assert (Array.length !passByVal = 1);
  let a = List.hd (fnhelper (!passByVal.(0))) in
  assert (a -> getVal () as int = 0x12345678);
  assert (a -> "~" () = C_void);
;;
