open Swig
open Global_immutable_vars

let read_only f = try ignore (f ()); false with Failure _ -> true

let () =
  assert (_default_mutable_var C_void as int = 40);
  assert (_global_immutable_var C_void as int = 41);
  assert (_specific_mutable_var C_void as int = 42);
  assert (_global_mutable_var C_void as int = 43);
  assert (_specific_immutable_var C_void as int = 44);

  ignore (_default_mutable_var (C_int 80));
  assert (_default_mutable_var C_void as int = 80);
  ignore (_specific_mutable_var (C_int 82));
  assert (_specific_mutable_var C_void as int = 82);
  ignore (_global_mutable_var (C_int 83));
  assert (_global_mutable_var C_void as int = 83);

  assert (read_only (fun () -> _global_immutable_var (C_int 81)));
  assert (read_only (fun () -> _specific_immutable_var (C_int 81)));

  assert (_check_values (C_list [ C_int 80; C_int 41; C_int 82; C_int 83; C_int 44 ]) as int <> 0)
