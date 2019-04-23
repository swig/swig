(* runme.ml *)

open Swig
open Example

exception BadReturn

let x = if Array.length Sys.argv > 1 then int_of_string Sys.argv.(1) else 16
let y = if Array.length Sys.argv > 2 then int_of_string Sys.argv.(2) else 12
let (xf,yf) = match _factor '((x to int),(y to int)) with
    C_list [ C_int a ; C_int b ] -> a,b
  | _ -> raise BadReturn
let _ = print_endline
	  ("Factorization of " ^ (string_of_int x) ^ 
	   " and " ^ (string_of_int y) ^ 
	   " is " ^ (string_of_int xf) ^ 
	   " and " ^ (string_of_int yf))
