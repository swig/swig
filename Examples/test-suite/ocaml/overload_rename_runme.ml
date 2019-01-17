open Swig
open Overload_rename

let _ = new_Foo (C_float 1.)
let _ = new_Foo (C_list [ C_float 1. ; C_float 1. ])
let _ = new_Foo_int (C_list [ C_float 1. ; C_int 1 ])
let _ = new_Foo_int (C_list [ C_float 1. ; C_int 1 ; C_float 1. ])
