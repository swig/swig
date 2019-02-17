open Swig
open Wrapmacro

let _ =
  let args = C_list [ C_int64 2L ; C_int64 1L ] in
  assert (_maximum '(args) as int = 2);
  let args =  C_list [ C_double (2. /. 7.) ; C_double 256. ] in 
  assert (_maximum '(args) as float = 256.);
  assert (_GUINT16_SWAP_LE_BE_CONSTANT '(0x1234) as int = 0x3412);
;;
