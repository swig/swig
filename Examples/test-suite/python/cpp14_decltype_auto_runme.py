from cpp14_decltype_auto import *
import cpp14_decltype_auto as _mod

from swig_test_utils import swig_check

# 'decltype(auto)' deduces from the initialiser, as 'auto' does.
swig_check(cvar.var_int, 42)
swig_check(cvar.var_const, 7)

# Unlike 'auto', 'decltype(auto)' keeps the reference, so var_ref is wrapped as 'int &' and
# reaches Python as a pointer object rather than as the plain int that var_int gives.
swig_check(isinstance(cvar.var_int, int), True)
swig_check(isinstance(cvar.var_ref, int), False)

# A deduced return type cannot be deduced from the body, so these are all ignored.
for ignored in ("ret_plain", "ret_trailing"):
    if hasattr(_mod, ignored):
        raise RuntimeError("%s should be ignored (deduced return type)" % ignored)

# A string literal deduces a reference to an array of a character type SWIG cannot recover, and a
# parenthesised name deduces a reference the name was not declared with, so both are ignored.
for ignored in ("var_string", "var_string_wide", "var_string_utf8", "var_string_char16",
                "var_string_char32", "var_string_raw", "var_string_raw_wide",
                "var_string_raw_utf8", "var_string_raw_char16", "var_string_raw_char32",
                "var_parenthesised"):
    if hasattr(cvar, ignored):
        raise RuntimeError("%s should be ignored (not wrappable as a variable)" % ignored)

k = Klass(11)
swig_check(k.plain(), 11)

if hasattr(Klass, "mem"):
    raise RuntimeError("Klass::mem should be ignored (deduced return type)")

swig_check(KlassMyDecltype().convert().value, 13)
