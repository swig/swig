open Swig
open Fvirtual

let _ =
  let sw = new_NodeSwitch '() and n = new_Node '() in
  assert (n -> addChild (n) as int = 1);
  assert (sw -> addChild (n) as int = 2);
  assert (sw -> addChild (sw) as int = 2);
  assert (sw -> addChild (n, false) as int = 3)
;;
