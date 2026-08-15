import cpp20_structured_bindings as _mod

from swig_test_utils import swig_check

# A structured binding is ignored whichever C++20 spelling it uses, so none of the names it
# introduces is wrapped.
for ignored in ("paren_a", "paren_b", "static_a", "static_b", "tl_a", "tl_b",
                "static_cref_a", "static_cref_b"):
    if hasattr(_mod.cvar, ignored):
        raise RuntimeError("%s should be ignored (structured binding)" % ignored)

# Everything declared after the structured bindings is still parsed and wrapped.
swig_check(_mod.parsing_continues(), 42)
swig_check(_mod.capture_binding(), 3)
swig_check(_mod.cvar.global_pt.x, 1)
