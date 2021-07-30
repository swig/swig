open Swig
open Inctest

let _ = new_A '()
let _ = new_B '()
let _ = assert (_importtest1 '(5) as int = 15)
let _ = assert (_importtest2 '("black") as string = "white")
