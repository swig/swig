open Swig
open Char_binary_rev_len

let _ =
  let t = new_Test '() in
  assert (t -> strlen ("hile") as int = 4);
  assert (t -> strlen ("hil\x00") as int = 4);
  let t2 = new_Test '("hile") in
  assert (t2 -> getisize () as int = 4);
  assert (t2 -> strlen ("hil\x00a") as int = 5);
;;
