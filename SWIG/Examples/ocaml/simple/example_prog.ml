(* example_prog.ml *)

open Swig
open Example

(* Call our gcd() function *)

exception NoReturn

let single_int x = 
  match x with C_int a -> a | _ -> raise NoReturn
let get_float x = 
  match x with C_float f -> f | C_double f -> f | _ -> raise NoReturn

let x = 42
let y = 105
let g = single_int (_gcd (C_list [ C_int x ; C_int y ]))
let _ = Printf.printf "The gcd of %d and %d is %d\n" x y g

(* Manipulate the Foo global variable *)

(* Output its current value *)
let _ = Printf.printf "Foo = %f\n" (get_float (_Foo C_void))

(* Change its value *)
let _ = _Foo (C_float 3.1415926)

(* See if the change took effect *)
let _ = Printf.printf "Foo = %f\n" (get_float (_Foo C_void))









