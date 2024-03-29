from python_builtin import *

if is_python_builtin():
  # Test 0 for default tp_hash
  vs = ValueStruct(1234)
  h = hash(vs)
  d = dict()
  d[h] = "hi"
  if h not in d:
    raise RuntimeError("h should be in d")
  h2 = hash(ValueStruct.inout(vs))
  if h != h2:
    raise RuntimeError("default tp_hash not working")

  # Test 1a for tp_hash
  if hash(SimpleValue(222)) != 222:
    raise RuntimeError("tp_hash not working")

  # Test 1b for tp_hash
  if hash(SimpleValue2(333)) != 333:
    raise RuntimeError("tp_hash not working")

  # Test 2 for tp_hash
  try:
    # Was incorrectly raising: SystemError: error return without exception set
    h = hash(BadHashFunctionReturnType())
    raise RuntimeError("Missing TypeError")
  except TypeError:
    pass

  # Test 3 for tp_hash
  passed = False
  try:
    h = hash(ExceptionHashFunction())
  except RuntimeError as e:
    passed = str(e).find("oops") != -1
    pass

  if not passed:
    raise RuntimeError("did not catch exception in hash()")

  # Test 4 for tp_dealloc (which is handled differently to other slots in the SWIG source)
  d = Dealloc1()
  if cvar.Dealloc1CalledCount != 0:
    raise RuntimeError("count should be 0")
  del d
  if cvar.Dealloc1CalledCount != 1:
    raise RuntimeError("count should be 1")

  d = Dealloc2()
  if cvar.Dealloc2CalledCount != 0:
    raise RuntimeError("count should be 0")
  del d
  if cvar.Dealloc2CalledCount != 1:
    raise RuntimeError("count should be 1")

  d = Dealloc3()
  if cvar.Dealloc3CalledCount != 0:
    raise RuntimeError("count should be 0")
  del d
  if cvar.Dealloc3CalledCount != 1:
    raise RuntimeError("count should be 1")

  # Test 5 for python:compare feature
  m10 = MyClass(10)
  m20 = MyClass(20)
  m15 = MyClass(15)

  if not m10 < m15:
    raise RuntimeError("m10 < m15")
  if not m10 < m20:
    raise RuntimeError("m10 < m20")
  if not m15 < m20:
    raise RuntimeError("m15 < m20")

  if m10 > m15:
    raise RuntimeError("m10 > m15")
  if m10 > m20:
    raise RuntimeError("m10 > m20")
  if m15 > m20:
    raise RuntimeError("m15 > m20")

  if MyClass.less_than_counts != 6:
    raise RuntimeError("python:compare feature not working")

# Test 6
sa = SimpleArray(5)
elements = [x for x in sa]
if elements != [0, 10, 20, 30, 40]:
  raise RuntimeError("Iteration not working")
if len(sa) != 5:
  raise RuntimeError("len not working")
for i in range(5):
  if sa[i] != i*10:
    raise RuntimeError("indexing not working")
subslice = sa[1:3]
elements = [x for x in subslice]
if elements != [10, 20]:
  raise RuntimeError("slice not working")

# Test 7 mapping to Python's pow
x = ANumber(2)
y = ANumber(4)
z = x ** y
if z.Value() != 16:
  raise RuntimeError("x ** y wrong")
z = pow(x, y)
if z.Value() != 16:
  raise RuntimeError("pow(x, y) wrong")
z = ANumber(9)
z = pow(x, y, z)
if z.Value() != 7:
  raise RuntimeError("pow(x, y, z) wrong")

# Test 8 https://github.com/swig/swig/pull/2771 __setitem__ for deleting item, uses C NULL
def check_gsi(gsi, idx, value, args_count, kw_count):
  if gsi.idx != idx:
    raise RuntimeError("idx wrong {}".format(idx))
  if gsi.value != value:
    raise RuntimeError("value wrong {}".format(value))
  if gsi.args_count != args_count:
    raise RuntimeError("args_count wrong {}".format(args_count))
  if gsi.kw_count != kw_count:
    raise RuntimeError("kw_count wrong {}".format(kw_count))
  gsi.reset()

if is_python_builtin():
  gsi = GetSetItem()
  gsi[0] = 111
  check_gsi(gsi, 0, 111, -100, -100)
  del gsi[0]
  check_gsi(gsi, 0, -11, -100, -100)
  gsi(222, fred = 333, jack = 444)
  check_gsi(gsi, -100, -100, 1, 2)
  gsi(333)
  check_gsi(gsi, -100, -100, 1, -11)
