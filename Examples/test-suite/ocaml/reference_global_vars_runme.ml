open Swig
open Reference_global_vars

let _ =
  let tc = _getconstTC '() in
  assert (tc -> "[num]" () as int = 33);

  let _ = _var_bool (_createref_bool (C_bool false)) in
  assert (_value_bool (_var_bool '()) as bool = false);

  let _ = _var_bool (_createref_bool (C_bool true)) in
  assert (_value_bool (_var_bool '()) as bool = true);

  let _ = _var_char (_createref_char (C_char 'w')) in
  assert (_value_char (_var_char '()) as char = 'w');

  let _ = _var_unsigned_char (_createref_unsigned_char (C_uchar 'w')) in
  assert (_value_unsigned_char (_var_unsigned_char '()) as char = 'w');

  let _ = _var_signed_char (_createref_signed_char (C_uchar 'w')) in
  assert (_value_signed_char (_var_signed_char '()) as char = 'w');

  let _ = _var_short (_createref_short (C_short 10)) in
  assert (_value_short (_var_short '()) as int = 10);

  let _ = _var_unsigned_short (_createref_unsigned_short (C_ushort 10)) in
  assert (_value_unsigned_short (_var_unsigned_short '()) as int = 10);

  let _ = _var_int (_createref_int (C_int 10)) in
  assert (_value_int (_var_int '()) as int = 10);

  let _ = _var_unsigned_int (_createref_unsigned_int (C_int 10)) in
  assert (_value_unsigned_int (_var_unsigned_int '()) as int = 10);

  let _ = _var_long (_createref_long (C_int64 10L)) in
  assert (_value_long (_var_long '()) as int = 10);

  let _ = _var_unsigned_long (_createref_unsigned_long (C_int64 10L)) in
  assert (_value_unsigned_long (_var_unsigned_long '()) as int = 10);

  let _ = _var_long_long (_createref_long_long (C_int64 0x6FFFFFFFFFFFFFF8L)) in
  assert (_value_long_long (_var_long_long '()) = C_int64 0x6FFFFFFFFFFFFFF8L);

  let _ = _var_unsigned_long_long (_createref_unsigned_long_long (C_int64 0x6FFFFFFFFFFFFFF8L)) in
  assert (_value_unsigned_long_long (_var_unsigned_long_long '()) = C_int64 0x6FFFFFFFFFFFFFF8L);

  let _ = _var_float (_createref_float (C_float 10.)) in
  assert (_value_float (_var_float '()) as float = 10.);

  let _ = _var_double (_createref_double (C_double 10.)) in
  assert (_value_double (_var_double '()) as float = 10.);

  let tc = new_TestClass '(20) in
  let _ = _var_TestClass (_createref_TestClass (tc)) in
  let tc = _value_TestClass (_var_TestClass '()) in
  assert (tc -> "[num]" () as int = 20);
;;
