import special_variable_macros

cvar = special_variable_macros.cvar
name = special_variable_macros.Name()
if special_variable_macros.testFred(name) != "none":
    raise "test failed"
if cvar.accessed_examplekw != 0:
    raise "Precondition failed"
if special_variable_macros.testJack(name) != "$specialname":
    raise "test failed"
if cvar.accessed_examplekw != 1:
    raise "Postcondition failed"
if special_variable_macros.testJill(name) != "jilly":
    raise "test failed"
if special_variable_macros.testMary(name) != "SWIGTYPE_p_NameWrap":
    raise "test failed"
if special_variable_macros.testJames(name) != "SWIGTYPE_Name":
    raise "test failed"
if special_variable_macros.testJim(name) != "multiname num":
    raise "test failed"
if special_variable_macros.testJohn(special_variable_macros.PairIntBool(10, False)) != 123:
    raise "test failed"
