open Swig
open Allowexcept

let _ =
  assert (_global_variable '() = C_void);
  assert (_Foo_static_member_variable '() = C_void)
;;
