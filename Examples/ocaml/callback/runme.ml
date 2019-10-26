(* file: runme.ml

This file illustrates cross-language polymorphism using directors. *)

open Swig
open Example

let new_OCamlCallback ob meth args =
  match meth with
    | "run" -> print_endline "OCamlCallback.run()"; C_void
    | _ -> (invoke ob) meth args

let caller = new_Caller '()

let _ = print_endline "Adding and calling a normal C++ callback"
let _ = print_endline "----------------------------------------"

let callback = new_Callback '()
let _ = caller -> "setCallback" (callback)
let _ = caller -> "call" ()
let _ = caller -> "delCallback" ()

let _ = print_endline "\nAdding and calling an OCaml callback"
let _ = print_endline "------------------------------------"

let callback = new_derived_object new_Callback (new_OCamlCallback) '()
let _  = caller -> "setCallback" (callback)
let _  = caller -> "call" ()
let _  = caller -> "delCallback" ()
let _  = print_endline "\nOCaml exit"
