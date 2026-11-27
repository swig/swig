# Regression test for a SWIG bug where std::vector<T> cannot be used as a parameter or
# return type across an %import boundary when T is only forward-declared in the
# importing module, while T's real definition and %template(...) std::vector<T> live in
# the imported module. See import_vector_fwd_a.i for the full explanation.

import import_vector_fwd_a
import import_vector_fwd_b

bv = import_vector_fwd_b.BarVector()
bv.append(import_vector_fwd_b.Bar())

c = import_vector_fwd_a.Container()
if not c.addBars(bv):
    raise RuntimeError("addBars failed")

bars = c.getBars()
if not isinstance(bars, import_vector_fwd_b.BarVector):
    raise RuntimeError("getBars returned wrong type: %s" % type(bars))
if len(bars) != 1:
    raise RuntimeError("getBars returned wrong size: %d" % len(bars))
