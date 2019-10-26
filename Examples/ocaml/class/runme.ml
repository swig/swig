(* file: runme.ml

 This file illustrates the proxy class C++ interface generated
 by SWIG. *)

open Swig
open Example

let repr o =
  Printf.sprintf "<%s at %#x>" (o -> ":classof" () as string) (o -> "&" () as int)

(* ----- Object creation ----- *)

let _ = print_endline "Creating some objects:"
let c = new_Circle '(10)
let _ = Printf.printf "    Created circle %s\n" (repr c)
let s = new_Square '(10)
let _ = Printf.printf "    Created square %s\n" (repr s)

(* ----- Access a static member ----- *)

let _ = Printf.printf "\nA total of %d shapes were created\n" (_Shape_nshapes '() as int)

(* ----- Member data access ----- *)

(* Set the location of the object *)

let _ = c -> "[x]" (20)
let _ = c -> "[y]" (30)

(* Temp var to work around a swigp4 bug (it doesn't properly handle "-" in some cases). *)
let arg = (-10. to float)
let _ = s -> "[x]" (arg)
let _ = s -> "[y]" (5)

let _ = print_endline "\nHere is their current position:"
let _ = Printf.printf "    Circle = (%f, %f)\n" (c -> "[x]" () as float) (c -> "[y]" () as float)
let _ = Printf.printf "    Square = (%f, %f)\n" (s -> "[x]" () as float) (s -> "[y]" () as float)

(* ----- Call some methods ----- *)

let _ = print_endline "\nHere are some properties of the shapes:"

let _ = List.iter (fun o ->
  Printf.printf "    %s\n" (repr o);
  Printf.printf "        area      =  %f\n" (o -> area () as float);
  Printf.printf "        perimeter =  %f\n" (o -> perimeter () as float)
  ) [c; s]

let _ = print_endline "\nGuess I'll clean up now"

(* Note: this invokes the virtual destructor *)
let _ = c -> "~" ()
let _ = s -> "~" ()

let _ = Printf.printf "%d shapes remain\n" (_Shape_nshapes '() as int)
let _ = print_endline "Goodbye"
