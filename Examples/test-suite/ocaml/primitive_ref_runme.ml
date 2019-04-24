open Swig
open Primitive_ref

let _ =
  assert (_ref_int '(3) as int = 3);
  assert (_ref_short '(3) as int = 3);
  assert (_ref_ushort '(3) as int = 3);
  assert (_ref_long '(3) as int = 3);
  assert (_ref_ulong '(3) as int = 3);
  assert (_ref_schar '(3) as int = 3);
  assert (_ref_uchar '(3) as int = 3);
  assert (_ref_float '(3.5) as float = 3.5);
  assert (_ref_double '(3.5) as float = 3.5);
  assert (_ref_bool '(true) as bool = true);
  let arg = C_char 'x' in
  assert (_ref_char '(arg) as char = 'x');
  assert (_ref_over '(0) as int = 0);
  let a = new_A '(12) in
  assert (_ref_over '(a) as int = 12);
;;
