import lib_std_string

x="hello"



if lib_std_string.test_ccvalue(x) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_string.test_cvalue(x) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_string.test_value(x) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_string.test_const_reference(x) != x:
  raise RuntimeError, "bad string mapping"


s = lib_std_string.string("he")
s += "ll"
s.append('o')

if s != x:
  print s, x
  raise RuntimeError, "bad string mapping"

if s[1:4] != x[1:4]:
  raise RuntimeError, "bad string mapping"

if lib_std_string.test_value(s) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_string.test_const_reference(s) != x:
  raise RuntimeError, "bad string mapping"

a = lib_std_string.A(s)

if lib_std_string.test_value(a) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_string.test_const_reference(a) != x:
  raise RuntimeError, "bad string mapping"

b = lib_std_string.string(" world")

if a + b != "hello world":
  raise RuntimeError, "bad string mapping"
  
if a + " world" != "hello world":
  raise RuntimeError, "bad string mapping"

if "hello" + b != "hello world":
  raise RuntimeError, "bad string mapping"

c = "hello" + b
if c.find_last_of("l") != 9:
  raise RuntimeError, "bad string mapping"
  
s = "hello world"

b = lib_std_string.B("hi")

b.name = "hello"
if b.name != "hello":
  raise RuntimeError, "bad string mapping"


b.a = lib_std_string.A("hello")
if b.a != "hello":
  raise RuntimeError, "bad string mapping"


