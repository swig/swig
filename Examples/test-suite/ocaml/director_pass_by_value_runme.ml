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

let cpp11 = _has_cplusplus11 '() as bool

let _ =
  let caller = new_Caller '() in
  assert (caller -> call_virtualMethod (d) = C_void);
  assert (Array.length !passByVal = 1);
(* TODO: only run if cpp11... let _ = _Counter_check_counts (C_list [C_int 0; C_int 0; C_int 0; C_int 1; C_int 0; C_int 1]) in*) (* check move constructor called and just one destructor *)
  let a = List.hd (fnhelper (!passByVal.(0))) in
  assert (a -> getVal () as int = 0x12345678);
  assert (a -> "~" () = C_void);
;;
