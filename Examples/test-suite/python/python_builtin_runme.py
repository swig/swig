from python_builtin import *

if is_python_builtin():
  # Test 1 for tp_hash
  if hash(SimpleValue(222)) != 222:
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
  except RuntimeError, e:
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

