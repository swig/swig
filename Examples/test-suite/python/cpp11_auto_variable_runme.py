from cpp11_auto_variable import *

from swig_test_utils import swig_check, swig_assert

# A named cast deduces the type it casts to.
swig_check(cvar.cast_double, 1.0)
swig_assert(isinstance(cvar.cast_double, float), "cast_double should be a float")
swig_check(cvar.cast_uint, 1)
swig_assert(isinstance(cvar.cast_uint, int), "cast_uint should be an int")
swig_check(cvar.cast_constcharptr, "abc")
cvar.cast_constcharptr = "xyz"
swig_check(cvar.cast_constcharptr, "xyz")

# The address of a variable in scope deduces to a pointer to it.
swig_assert(cvar.ptr_t is not None, "ptr_t")
swig_assert(cvar.ptr_zero is not None, "ptr_zero")

# Parentheses around the initialiser do not change what is deduced.
swig_check(cvar.paren_int, 1)
swig_assert(isinstance(cvar.paren_int, int), "paren_int should be an int")
swig_check(cvar.paren_double, 1.0)
swig_assert(isinstance(cvar.paren_double, float), "paren_double should be a float")
swig_assert(cvar.paren_ptr is not None, "paren_ptr")
swig_assert(cvar.paren_nested_ptr is not None, "paren_nested_ptr")
swig_check(cvar.paren_nested, 1)

# A promoted narrow integral type is an int, so it holds a value the narrow type could not.
for name in ["promoted_short", "promoted_ushort", "promoted_char", "promoted_bool"]:
    setattr(cvar, name, 100000)
    swig_check(getattr(cvar, name), 100000)
swig_check(cvar.negated_short, -1)

# A typedef hiding const or an array does not stop deduction dropping or decaying it.
swig_check(cvar.typedef_const, 4)
cvar.typedef_const = 40
swig_check(cvar.typedef_const, 40)
swig_check(int_ptr_second(cvar.typedef_array), 6)
swig_check(int_ptr_second(cvar.typedef_array_ptr), 6)
swig_check(cvar.typedef_alias, 8)

# A subscript deduces the element type.
swig_check(cvar.array_element, 31)
swig_check(cvar.pointer_element, 32)
swig_check(int_ptr_second(cvar.matrix_row), 44)
swig_check(cvar.matrix_element, 45)
swig_check(cvar.typedef_array_element, 7)
swig_check(cvar.paren_element, 30)
swig_check(cvar.literal_element, "b")
swig_check(cvar.indexed_element, 2.5)
swig_assert(isinstance(cvar.indexed_element, float), "indexed_element should be a float")
swig_check(matrix_default(), 41)
# The 'int &' variables are wrapped as pointers, which see the elements they refer to change.
set_subscript_array_value(0, 60)
set_subscript_array_value(2, 62)
swig_check(deref_const_int_ptr(cvar.element_ref), 60)
swig_check(deref_const_int_ptr(cvar.forwarded_element), 62)

# auto drops a reference hidden by a typedef.
swig_check(cvar.typedef_ref_element, 71)
swig_assert(isinstance(cvar.typedef_ref_element, int), "typedef_ref_element should be an int")
swig_check(cvar.typedef_ref_copy, 70)
swig_assert(isinstance(cvar.typedef_ref_copy, int), "typedef_ref_copy should be an int")
swig_check(deref_const_int_ptr(cvar.typedef_ref_address), 70)
swig_check(deref_const_int_ptr(cvar.typedef_ref_forwarded), 71)
swig_check(cvar.typedef_ref_paren, 70)
swig_assert(isinstance(cvar.typedef_ref_paren_class, RefIndexedInt), "typedef_ref_paren_class should be a RefIndexedInt")

# A C-style cast deduces the type it casts to, and a dereference the type pointed to.
swig_check(deref_const_int_ptr(cvar.cstyle_cast_ptr), 0)
swig_assert(cvar.cstyle_cast_null is None, "cstyle_cast_null")
swig_check(cvar.cstyle_cast_double, 0.0)
swig_assert(isinstance(cvar.cstyle_cast_double, float), "cstyle_cast_double should be a float")
swig_check(cvar.pointer_condition, 2)
swig_check(cvar.pointer_compare, True)
swig_check(cvar.dereferenced, 0)
swig_check(cvar.dereferenced_cast, 1)

# A functional cast to a class deduces the class.
swig_check(cvar.class_brace.y, 2)
swig_check(cvar.class_paren.v, 3)
swig_check(cvar.class_empty.x, 0)
swig_check(cvar.class_alias.y, 5)
swig_check(cvar.class_qualified.i, 6)
swig_check(cvar.class_template.t, 7)
swig_assert(cvar.class_forward is not None, "class_forward")
swig_check(cvar.long_brace, 9)
swig_check(point_x(), 10)

# An enumerator in a namespace or a class deduces the qualified enumeration.
swig_check(cvar.namespace_enumerator, auto_dark)
swig_check(cvar.class_enumerator, AutoHolder.auto_big)

# An unscoped enumerator qualified by its enumeration deduces the enumeration.
swig_check(cvar.qualified_enumerator, auto_green)
swig_check(cvar.nested_qualified_enumerator, auto_dark)
swig_check(cvar.class_qualified_enumerator, AutoHolder.auto_big)
