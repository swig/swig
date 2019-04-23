open Swig
open Chartest

let _ =
  assert (_GetPrintableChar '() as char = 'a');
  assert (_GetUnprintableChar '() as char = '\127');
  assert (_printable_global_char '() as char = 'a');
  assert (_unprintable_global_char '() as char = '\127');
  assert (_globchar0 '() as char = '\x00');
  assert (_globchar1 '() as char = '\x01');
  assert (_globchar2 '() as char = '\n');
  assert (_globcharA '() as char = 'A');
  assert (_globcharB '() as char = 'B');
  assert (_globcharC '() as char = 'C');
  assert (_globcharD '() as char = 'D');
  assert (_globcharE '() as char = 'E');
  assert (_CharTestClass_memberchar0 '() as char = '\x00');
  assert (_CharTestClass_memberchar1 '() as char = '\x01');
  assert (_CharTestClass_memberchar2 '() as char = '\n');
  assert (_CharTestClass_membercharA '() as char = 'A');
  assert (_CharTestClass_membercharB '() as char = 'B');
  assert (_CharTestClass_membercharC '() as char = 'C');
  assert (_CharTestClass_membercharD '() as char = 'D');
  assert (_CharTestClass_membercharE '() as char = 'E');
;;
