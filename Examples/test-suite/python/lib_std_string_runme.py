import lib_std_string

x="hello"

if lib_std_string.test_value(x) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_string.test_const_reference(x) != x:
  raise RuntimeError, "bad string mapping"


s = lib_std_string.string("he")
s.append("llo")

if lib_std_string.test_value(s) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_string.test_const_reference(s) != x:
  raise RuntimeError, "bad string mapping"

a = lib_std_string.A("hello")

if lib_std_string.test_value(a) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_string.test_const_reference(a) != x:
  raise RuntimeError, "bad string mapping"
