open Swig
open Char_constant

let _ =
  assert (_CHAR_CONSTANT '() as char = 'x');
  assert (_STRING_CONSTANT '() as string = "xyzzy");
  assert (_ESC_CONST '() as char = '\x01');
  assert (_NULL_CONST '() as char = '\x00');
  assert (_SPECIALCHARA '() as char = 'A');
  assert (_SPECIALCHARB '() as char = 'B');
  assert (_SPECIALCHARC '() as char = 'C');
  assert (_SPECIALCHARD '() as char = 'D');
  assert (_SPECIALCHARE '() as char = 'E');
  assert (_ia '() as char = 'a');
  assert (_ib '() as char = 'b');
;;
