open Swig
open Struct_value

let b = new_Bar (C_void)
let a = (invoke b) "[a]" (C_void)
let _ = (invoke a) "[x]" (C_int 3)
let _ = assert((invoke a) "[x]" (C_void) = C_int 3)

let bb = (invoke b) "[b]" (C_void)
let _ = (invoke bb) "[x]" (C_int 3)
let _ = assert((invoke bb) "[x]" (C_void) = C_int 3)
