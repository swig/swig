open Swig
open Memberin_extend

let _ =
  let em1 = new_ExtendMe '() and em2 = new_ExtendMe '() in
  assert (em1 -> "[thing]" ("em1thing") = C_void);
  assert (em2 -> "[thing]" ("em2thing") = C_void);
  assert (em1 -> "[thing]" () as string = "em1thing");
  assert (em2 -> "[thing]" () as string = "em2thing");
;;
