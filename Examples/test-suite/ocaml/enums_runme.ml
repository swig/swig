open Swig
open Enums

let _ =
  assert (_GlobalInstance '() as int = 0);
  ignore (_GlobalInstance (C_int 30));
  assert (_GlobalInstance '() as int = 30)
;;
