open Swig
open Template_methods

let _ =
  let num = C_float 1. in
  assert (_convolve1Bool '() as int = 0);
  assert (_convolve1Bool '(true) = C_void);
  assert (_convolve2Float '() as int = 0);
  assert (_convolve3FloatRenamed '(num) = C_void);
  assert (_convolve4Float '() as int = 0);
  assert (_convolve4FloatRenamed '(num) = C_void);
  assert (_convolve5FloatRenamed '() as int = 0);
  assert (_convolve5FloatRenamed '(num) = C_void);

  let k = new_Klass '() in
  assert (k -> KlassTMethodBoolRenamed (true) as bool = true);
  assert (k -> KlassTMethodBool () = C_void);
  assert (_Klass_KlassStaticTMethodBoolRenamed '(true) as bool = true);
  assert (_Klass_KlassStaticTMethodBool '() = C_void);

  let cp = new_ComponentProperties '() in
  assert (cp -> adda ("key1", "val1", "key2", 22.2) = C_void);
  assert (cp -> adda ("key1", "val1", "key2", "val2", "key3", "val3") = C_void);
  assert (cp -> adda ("key1", 1, "key2", 2, "key3", 3) = C_void)
;;
