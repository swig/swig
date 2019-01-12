open Swig
open Cast_operator

let a = new_A '()
let _ = assert ((a -> "tochar" () as string) = "hi")
