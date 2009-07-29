import special_variable_functions

name = special_variable_functions.Name()
if special_variable_functions.testFred(name) != "none":
  raise "test failed"
if special_variable_functions.testJack(name) != "$specialname":
  raise "test failed"
if special_variable_functions.testJill(name) != "jilly":
  raise "test failed"
if special_variable_functions.testMary(name) != "SWIGTYPE_p_NameWrap":
  raise "test failed"

