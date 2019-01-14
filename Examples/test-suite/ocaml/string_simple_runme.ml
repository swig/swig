open Swig
open String_simple

let str = "olé"

let copy = _copy_str (C_string str) as string

let _ = if str <> copy then
  raise (Failure ("Error: copy is not equal: original="^str^", copy="^copy))
