(* This example was mostly lifted from the guile example directory *)

open Example

let v = new_StringVector C_void 

let _ = 
  for i = 0 to (Array.length Sys.argv) - 1 do
    (invoke v) "push_back" (C_string Sys.argv.(i))
  done

let _ = _vec_write v
