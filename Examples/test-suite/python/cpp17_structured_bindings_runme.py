import cpp17_structured_bindings as _mod

from swig_test_utils import swig_check

# A structured binding is ignored, so none of the names it introduces is wrapped.
for ignored in ("plain_a", "plain_b", "ref_a", "ref_b", "cref_a", "cref_b",
                "rref_a", "rref_b"):
    if hasattr(_mod.cvar, ignored):
        raise RuntimeError("%s should be ignored (structured binding)" % ignored)

# Everything declared after the structured bindings is still parsed and wrapped.
swig_check(_mod.parsing_continues(), 42)
swig_check(_mod.Holder(11).get(), 11)
swig_check(_mod.cvar.global_pt.x, 1)
