(* example_prog.ml *)

open Example

exception BadReturn

let x = int_of_string Sys.argv.(1)
let y = int_of_string Sys.argv.(2)
let (xf,yf) = match _factor (C_list [ C_int x ; C_int y ]) with
    C_list [ C_int a ; C_int b ] -> a,b
  | _ -> raise BadReturn
let _ = print_endline
	  ("Factorization of " ^ (string_of_int x) ^ 
	   " and " ^ (string_of_int y) ^ 
	   " is " ^ (string_of_int xf) ^ 
	   " and " ^ (string_of_int yf))
