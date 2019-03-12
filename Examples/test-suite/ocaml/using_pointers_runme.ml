open Swig
open Using_pointers

let f = new_FooBar '()
try
  ignore (f -> exception_spec (1)); assert false
with Failure _ -> ()
try
  ignore (f -> exception_spec (2)); assert false
with Failure _ -> ()
