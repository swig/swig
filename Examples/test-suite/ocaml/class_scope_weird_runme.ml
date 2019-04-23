open Swig
open Class_scope_weird

let f = new_Foo (C_void)
let g = new_Foo (C_int 3)
let _ = assert (get_int ((invoke f) "bar" (C_int 3)) = 3)
