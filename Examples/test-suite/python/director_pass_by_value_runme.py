import director_pass_by_value

passByVal = None
class director_pass_by_value_Derived(director_pass_by_value.DirectorPassByValueAbstractBase):
  def virtualMethod(self, b):
    global passByVal
    passByVal = b

# bug was the passByVal global object was destroyed after the call to virtualMethod had finished.
director_pass_by_value.Caller().call_virtualMethod(director_pass_by_value_Derived())
if director_pass_by_value.has_cplusplus11():
    director_pass_by_value.Counter.check_counts(1, 0, 0, 1, 0, 1) # check move constructor called and just one destructor
ret = passByVal.getVal();
if ret != 0x12345678:
  raise RuntimeError("Bad return value, got " + hex(ret))
