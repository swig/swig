(* example_prog.ml *)

open Example

(* Call our gcd() function *)

let x = 42
let y = 105
let g = gcd x y
let _ = Printf.printf "The gcd of %d and %d is %d\n" x y g

(* Manipulate the Foo global variable *)

(* Output its current value *)
let _ = Printf.printf "Foo = %f\n" (_Foo_get ())

(* Change its value *)
let _ = _Foo_set 3.1415926

(* See if the change took effect *)
let _ = Printf.printf "Foo = %f\n" (_Foo_get ())









