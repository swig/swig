import lib_std_wstring

x=u"hello"


if lib_std_wstring.test_ccvalue(x) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_wstring.test_cvalue(x) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_wstring.test_value(x) != x:
  print x, lib_std_wstring.test_value(x)
  raise RuntimeError, "bad string mapping"

if lib_std_wstring.test_const_reference(x) != x:
  raise RuntimeError, "bad string mapping"


s = lib_std_wstring.wstring(u"he")
s += u"llo"

if s != x:
  print s, x
  raise RuntimeError, "bad string mapping"

if s[1:4] != x[1:4]:
  raise RuntimeError, "bad string mapping"

if lib_std_wstring.test_value(s) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_wstring.test_const_reference(s) != x:
  raise RuntimeError, "bad string mapping"

a = lib_std_wstring.A(s)

if lib_std_wstring.test_value(a) != x:
  raise RuntimeError, "bad string mapping"

if lib_std_wstring.test_const_reference(a) != x:
  raise RuntimeError, "bad string mapping"

b = lib_std_wstring.wstring(" world")

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

b = lib_std_wstring.B("hi")

b.name = u"hello"
if b.name != "hello":
  raise RuntimeError, "bad string mapping"


b.a = lib_std_wstring.A("hello")
if b.a != u"hello":
  raise RuntimeError, "bad string mapping"


