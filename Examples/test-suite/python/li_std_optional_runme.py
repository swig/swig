from li_std_optional import *

def check(flag):
    if not flag:
        raise RuntimeError("Check failed")

# Test optional with value
r = make_optional(42)
check(isinstance(r, int))
check(r == 42)

# Test empty optional returns None
r2 = make_empty_optional()
check(r2 is None)

# Test value_or
r3 = optional_value_or(make_optional(10), 99)
check(r3 == 10)

r4 = optional_value_or(make_empty_optional(), 99)
check(r4 == 99)

# Test passthrough with both by-value and by-const-ref
r5 = optional_passthrough(5, 3.5)
check(r5 == 8.5)

# Test passthrough with empty optional for by-value
r6 = optional_passthrough(make_empty_optional(), 3.5)
check(r6 == 3.5)

# Test passthrough with None
r7 = optional_passthrough(None, 3.5)
check(r7 == 3.5)
