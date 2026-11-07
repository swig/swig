"""Regression test for https://github.com/swig/swig/issues/2638.

When one module uses a type defined by another module, destroying the
shared capsule must not clear the type's clientdata while objects of
that type are still alive. Deleting the capsule early simulates the
interpreter shutdown ordering that used to trigger 'swig/python
detected a memory leak, no destructor found' and skipped the C++
destructor.
"""
import sys

from swig_test_utils import swig_assert, swig_check

import clientdata_teardown_a
import clientdata_teardown_b

# The destructor must not have run yet.
swig_check(clientdata_teardown_b.counted_dtors_called(), 0)

c = clientdata_teardown_b.Counted()
swig_check(c.get(), 42)
swig_check(clientdata_teardown_a.use_counted(c), 42)

# Find the shared runtime data module and capsule without hardcoding
# the runtime version suffix.
rtmod = None
for name, mod in sys.modules.items():
    if name.startswith("swig_runtime_data"):
        rtmod = mod
        break
swig_assert(rtmod is not None, "swig runtime data module not found")
capsule_names = [a for a in dir(rtmod) if a.startswith("type_pointer_capsule")]
swig_check(len(capsule_names), 1)
delattr(rtmod, capsule_names[0])

# The object must still be destroyed through its normal destructor.
del c
swig_check(clientdata_teardown_b.counted_dtors_called(), 1)
