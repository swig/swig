open Swig
open Template_rename

let _ =
  let i = new_iFoo '() and d = new_dFoo '() in
  assert (i -> blah_test (4) as int = 4);
  assert (i -> spam_test (5) as int = 5);
  assert (i -> groki_test (6) as int = 6);
  assert (d -> blah_test (7) as int = 7);
  assert (d -> spam (8) as int = 8);
  assert (d -> grok_test (9) as int = 9)
;;
