open Swig
open Char_binary

let _ =
  let t = new_Test '() in
  assert (t -> strlen ("hile") as int = 4);
  assert (t -> ustrlen ("hile") as int = 4);
  assert (t -> strlen ("hil\x00") as int = 4);
  assert (t -> ustrlen ("hil\x00") as int = 4);

  let pc = _new_pchar '(5) in
  assert (_pchar_setitem '(pc, 0, 'h') = C_void);
  assert (_pchar_setitem '(pc, 1, 'o') = C_void);
  assert (_pchar_setitem '(pc, 2, 'l') = C_void);
  assert (_pchar_setitem '(pc, 3, 'a') = C_void);
  assert (_pchar_setitem '(pc, 4, 0) = C_void);
  assert (t -> strlen (pc) as int = 4);
  assert (t -> ustrlen (pc) as int = 4);
  ignore (_var_pchar '(pc));
  assert (_var_pchar '() as string = "hola");
  ignore (_var_namet '(pc));
  assert (_var_namet '() as string = "hola");
  _delete_pchar(pc)
;;
