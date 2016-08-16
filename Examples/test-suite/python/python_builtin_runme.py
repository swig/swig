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

