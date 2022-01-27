open Swig
open Cpp_nodefault

let foo1 = new_Foo '(1, 2)
let _ = foo1 -> "[a]" (5)
let _ = assert ((foo1 -> "[a]" () as int) = 5)

let foo2 = _create '(1, 2)
let _ = _consume '(foo1,foo2)

let bar1 = new_Bar '()
let gvar = _gvar '()
let args = (C_list [ gvar ; foo2 ])
let _ = bar1 -> "consume" (args)
let foo3 = bar1 -> "create" (1, 2)
let _ = foo3 -> "[a]" (6)
let _ = assert ((foo3 -> "[a]" () as int) = 6)
