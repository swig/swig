from cpp17_optional import *


test_optionals = TestOptionals()

# Checking SimpleOptional

# test_simple_optional_initial_get
optU32 = test_optionals.getSimpleOptional()
assert optU32 is None or isinstance(optU32, int), "test_optionals.getSimpleOptional(): Expected None or int, got {}".format(repr(optU32))

# test_simple_optional_set
optU32 = 32
test_optionals.setSimpleOptional(optU32)

optU32_after_set = test_optionals.getSimpleOptional()
assert optU32_after_set == 32, "test_optionals.setSimpleOptional(): Expected 32, got {}".format(repr(optU32_after_set))
