import li_constraints

def check_double(et, fn, f, val):
    actual = True
    proper = False
    try:
      fn(val)
    except ValueError as e:
      actual = False
      proper = "Expected a " + f + " value." == "%s"%(e)
    if actual:
      if not et:
        raise Exception("function '%s' with %d should perform an exception"%(f, val))
    else:
      if et:
        raise Exception("function '%s' with %d should not perform an exception"%(f, val))
      elif not proper:
        raise Exception("function '%s' with %d should perform a proper exception"%(f, val))
    pass

nonnegative = lambda v : li_constraints.test_nonnegative(v)
check_double(True, nonnegative, "non-negative", 10)
check_double(True, nonnegative, "non-negative", 0)
check_double(False, nonnegative, "non-negative", -10)

nonpositive = lambda v : li_constraints.test_nonpositive(v)
check_double(False, nonpositive, "non-positive", 10)
check_double(True, nonpositive, "non-positive", 0)
check_double(True, nonpositive, "non-positive", -10)

positive = lambda v : li_constraints.test_positive(v)
check_double(True, positive, "positive", 10)
check_double(False, positive, "positive", 0)
check_double(False, positive, "positive", -10)

negative = lambda v : li_constraints.test_negative(v)
check_double(False, negative, "negative", 10)
check_double(False, negative, "negative", 0)
check_double(True, negative, "negative", -10)

nonzero = lambda v : li_constraints.test_nonzero(v)
check_double(True, nonzero, "nonzero", 10)
check_double(False, nonzero, "nonzero", 0)
check_double(True, nonzero, "nonzero", -10)

have_exception = False
try:
   li_constraints.test_nonnull(None)
except ValueError as e:
   have_exception = "Received a NULL pointer." == "%s"%(e)
if not have_exception:
   raise Exception("test_nonnull should perform exception with 'null' value")
nonnull = li_constraints.get_nonnull()
li_constraints.test_nonnull(nonnull)
