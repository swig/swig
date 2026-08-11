import typemap_variables

# Regression test for issue #2056: %typemap(in) with struct qualification
# matching member variable setters.
a = typemap_variables.StructA()
b = typemap_variables.StructB()

# Setting member exercises the qualified 'in' typemap on the setter
# parameter. If the typemap matches, the wrapper compiles and runs
# without error (the in typemap forces arg2=0).
a.member = 42
b.member = 99
