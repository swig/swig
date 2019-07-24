open Swig
open Typedef_class

let a = new_RealA '()
let _ = a -> "[a]" (3)

let b = new_B '()
let _ = assert (b -> testA (a) as int = 3)

let bb = new_BB '()
let bb2 = new_BB '(2)
let _ = assert (bb -> aa_method (1.) as int = 0)
let bbb = new_BBB '()
