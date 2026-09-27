from cpp14_decltype_auto import *
import cpp14_decltype_auto as _mod

from swig_test_utils import swig_check, swig_assert

# 'decltype(auto)' deduces from the initialiser, as 'auto' does.
swig_check(cvar.var_int, 42)
swig_check(cvar.var_const, 7)

# Unlike 'auto', 'decltype(auto)' keeps the reference, so var_ref is wrapped as 'int &' and
# reaches Python as a pointer object rather than as the plain int that var_int gives.
swig_check(isinstance(cvar.var_int, int), True)
swig_check(isinstance(cvar.var_ref, int), False)

# A parenthesised name deduces a reference to what it names, so each of these reads and writes the original.
cvar.var_paren_int = 10
swig_check(cvar.paren_int, 10)
cvar.var_paren_nested = 11
swig_check(cvar.paren_int, 11)
swig_check(paren_deref(cvar.var_paren_ptr), 11)
cvar.var_paren_class.member = 12
swig_check(cvar.paren_class.member, 12)
swig_assert(cvar.var_paren_array is not None, "var_paren_array")
cvar.var_paren_static = 13
swig_check(cvar.Paren_count, 13)
swig_check(cvar.var_paren_typedef_ref, cvar.paren_int)
swig_check(cvar.var_paren_enumerator, paren_dark)
swig_check(cvar.var_paren_scoped, ParenScoped_scoped_dark)
swig_check(hasattr(cvar, "var_paren_function"), False)

# A parenthesised address is the pointer itself.
swig_check(paren_address_value(cvar.var_paren_address), 11)

# A deduced return type cannot be deduced from the body, so these are all ignored.
for ignored in ("ret_plain", "ret_trailing"):
    if hasattr(_mod, ignored):
        raise RuntimeError("%s should be ignored (deduced return type)" % ignored)

# A string literal deduces a reference to the array of characters it is, which is wrapped as the
# string that array is wrapped as.
swig_check(cvar.var_string, "text")
swig_check(cvar.var_string_raw, "text")
swig_check(cvar.var_string_concat, "text")
swig_check(cvar.var_string_parens, "text")

# A wide literal deduces a reference to an array of wchar_t, which has no string wrapping.
swig_check(isinstance(cvar.var_string_wide, str), False)
swig_check(isinstance(cvar.var_string_raw_wide, str), False)

# A u8, u or U literal is of a character type SWIG has no type for, so these are ignored.
for ignored in ("var_string_utf8", "var_string_char16", "var_string_char32",
                "var_string_raw_utf8", "var_string_raw_char16", "var_string_raw_char32"):
    if hasattr(cvar, ignored):
        raise RuntimeError("%s should be ignored (not wrappable as a variable)" % ignored)

# An expression with a literal as an operand is not a literal, so this is a plain 'const char *'.
swig_check(cvar.var_string_expr, "ext")

# Nor is a cast of a literal, so this 'const char *' can be set to a longer string, unlike a reference to the array.
swig_check(cvar.var_string_cast, "text")
cvar.var_string_cast = "longer text"
swig_check(cvar.var_string_cast, "longer text")

k = Klass(11)
swig_check(k.plain(), 11)

if hasattr(Klass, "mem"):
    raise RuntimeError("Klass::mem should be ignored (deduced return type)")

swig_check(KlassMyDecltype().convert().value, 13)

# A new-expression deduces the pointer it gives.
swig_check(new_int_value(cvar.var_new), 5)
swig_check(new_klass_value(cvar.var_new_klass), 3)
