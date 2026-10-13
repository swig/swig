open Swig
open Member_immutable_vars

let read_only f = try ignore (f ()); false with Failure _ -> true

let () =
  let v = new_ImmutableVars '() in
  ignore ((invoke v) "[mutable_var]" (C_int 80));
  assert ((invoke v) "[mutable_var]" C_void as int = 80);
  assert (read_only (fun () -> (invoke v) "[specific_immutable_var]" (C_int 81)));
  assert ((invoke v) "[specific_immutable_var]" C_void as int = 41);
  assert (read_only (fun () -> (invoke v) "[const_var]" (C_int 82)));
  assert ((invoke v) "[const_var]" C_void as int = 42);

  let d = new_DerivedImmutableVars '() in
  ignore ((invoke d) "[derived_mutable_var]" (C_int 83));
  assert ((invoke d) "[derived_mutable_var]" C_void as int = 83);
  ignore ((invoke d) "[mutable_var]" (C_int 84));
  assert ((invoke d) "[mutable_var]" C_void as int = 84);
  assert (read_only (fun () -> (invoke d) "[specific_immutable_var]" (C_int 85)));
  assert ((invoke d) "[specific_immutable_var]" C_void as int = 41)
