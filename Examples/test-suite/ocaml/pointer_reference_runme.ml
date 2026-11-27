open Swig
open Pointer_reference

let _ =
  let s = _get '() in
  assert ((s -> "[value]" ()) as int = 10);
  let ss = new_Struct '(20) in
  ignore (_set ss);
  let instance = create_Struct_from_ptr (_Struct_instance '()) in
  assert ((instance -> "[value]" ()) as int = 20);
  assert (_overloading '(1) as int = 111);
  assert (_overloading ss as int = 222);
  assert (_pointer_reference_typedef_const ss as int = 20);
  assert (_opaque_value (_opaque_pointer_reference '()) as int = 30)
;;
