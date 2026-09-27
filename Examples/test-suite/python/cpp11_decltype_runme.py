import cpp11_decltype
from swig_test_utils import swig_assert, swig_check

a = cpp11_decltype.A()
a.i = 5
if a.i != 5:
    raise RuntimeError("Assignment to a.i failed.")

a.j = 10
if a.j != 10:
    raise RuntimeError("Assignment to a.j failed.")

n = a.get_number(5)
if n != 10:
    raise RuntimeError("get_number(5) should return 10.")

n = a.get_number(6)
if n != 0:
    raise RuntimeError("get_number(6) should return 0.")

b = cpp11_decltype.B()

if b.a != False:
    raise RuntimeError("b.a should be False")

if b.b != True:
    raise RuntimeError("b.b should be True")

if b.negate(True) != False:
    raise RuntimeError("b.negate(True) should return False")

if b.negate(False) != True:
    raise RuntimeError("b.negate(False) should return True")

swig_check(b.scaled(3, 1.5), 4.5)

# The parameter types, int, not the double globals of the same names.
swig_check(cpp11_decltype.shadowed_sum(7, 8), 15)
swig_assert(isinstance(cpp11_decltype.shadowed_sum(7, 8), int), "shadowed_sum should return an int")
swig_check(cpp11_decltype.shadowed_negate(4), -4)

m = cpp11_decltype.MemberTrailing()
m.d = 3
swig_check(m.via_this(), 3)
swig_check(m.this_sum(), 4)
swig_check(m.call(), 7)
swig_check(m.call_sum(), 14)
swig_check(m.self_ptr().d, 3)
swig_check(m.self_cptr().d, 3)
swig_check(m.self_deref().d, 3)
swig_check(m.self_ref_ptr().d, 3)
swig_check(m.self_cref_deref().d, 3)
t = cpp11_decltype.TemplateTrailingInt()
t.v = 5
swig_check(t.via_this(), 5)
swig_check(t.self_ptr().v, 5)
swig_check(t.self_deref().v, 5)
# The member function returning an int, not the global one returning a double.
swig_check(m.shadowed_call(), 8)
swig_assert(isinstance(m.shadowed_call(), int), "shadowed_call should return an int")

swig_check(cpp11_decltype.deref_first(cpp11_decltype.deref_lvalue()), 4)
swig_check(cpp11_decltype.deref_first(cpp11_decltype.parameter_deref(cpp11_decltype.three_values())), 11)
swig_check(cpp11_decltype.deref_sum(cpp11_decltype.three_values()), 12)

swig_check(cpp11_decltype.deref_first(cpp11_decltype.subscript_lvalue()), 5)
swig_check(cpp11_decltype.deref_first(cpp11_decltype.parameter_subscript(cpp11_decltype.three_values(), 2)), 33)
swig_check(cpp11_decltype.subscript_sum(cpp11_decltype.three_values()), 23)
swig_check(cpp11_decltype.deref_first(cpp11_decltype.indexed_element()), 9)
# An 'int &' variable is wrapped as a pointer, which sees the element it refers to change.
swig_check(cpp11_decltype.deref_first(cpp11_decltype.cvar.subscript_ref), 20)
cpp11_decltype.set_subscript_value(1, 21)
swig_check(cpp11_decltype.deref_first(cpp11_decltype.cvar.subscript_ref), 21)
swig_check(cpp11_decltype.cvar.literal_element_ref, "b")
# The template argument is an array type, so the member is an array.
holder = cpp11_decltype.ArrayHolder3()
holder.held = cpp11_decltype.three_values()
swig_check(cpp11_decltype.deref_first(holder.held), 11)
swig_check(cpp11_decltype.ArrayHolder3.count, 3)

# decltype(&i) deduces 'int *', so the address is returned rather than the function being ignored.
if b.get_number_address(None) is None:
    raise RuntimeError("b.get_number_address should return a pointer")

# A parameter is in scope in the trailing return type, so these return int and float, not Shadowed.
if cpp11_decltype.parameter_shadows_global(5) != 6:
    raise RuntimeError("parameter_shadows_global(5) should return 6")

if cpp11_decltype.parameter_only(1.5) != 2.5:
    raise RuntimeError("parameter_only(1.5) should return 2.5")

# A function parameter deduces to a function pointer and an array parameter to a pointer to its element,
# so the results can be passed to functions taking those pointer types.
if cpp11_decltype.call_through(cpp11_decltype.function_parameter(cpp11_decltype.cvar.increment_ptr), 4) != 5:
    raise RuntimeError("function_parameter should return a callable function pointer")

if cpp11_decltype.deref_first(cpp11_decltype.array_parameter(cpp11_decltype.three_values())) != 11:
    raise RuntimeError("array_parameter should return an int pointer")

if cpp11_decltype.deref_first(cpp11_decltype.const_array_parameter(cpp11_decltype.three_values())) != 11:
    raise RuntimeError("const_array_parameter should return an int pointer")

if cpp11_decltype.deref_first2(cpp11_decltype.array_parameter_address(cpp11_decltype.three_values())) != 11:
    raise RuntimeError("array_parameter_address should return a pointer to an int pointer")

# A typedef hides the array or function the parameter is, but the same adjustments apply through it.
if cpp11_decltype.call_through(cpp11_decltype.function_alias_parameter(cpp11_decltype.cvar.increment_ptr), 4) != 5:
    raise RuntimeError("function_alias_parameter should return a callable function pointer")

if cpp11_decltype.deref_first(cpp11_decltype.array_alias_parameter(cpp11_decltype.three_values())) != 11:
    raise RuntimeError("array_alias_parameter should return an int pointer")

if cpp11_decltype.deref_first2(cpp11_decltype.array_alias_parameter_address(cpp11_decltype.three_values())) != 11:
    raise RuntimeError("array_alias_parameter_address should return a pointer to an int pointer")

if cpp11_decltype.call_through(cpp11_decltype.function_using_parameter(cpp11_decltype.cvar.increment_ptr), 4) != 5:
    raise RuntimeError("function_using_parameter should return a callable function pointer")

if cpp11_decltype.call_through(cpp11_decltype.function_template_using_parameter(cpp11_decltype.cvar.increment_ptr), 4) != 5:
    raise RuntimeError("function_template_using_parameter should return a callable function pointer")

# A decltype of a parenthesised name is a reference to what the name was declared with, so this one
# is an 'int *&' and the getter hands back its address, while the unparenthesised name is an 'int *'.
if cpp11_decltype.deref_first2(cpp11_decltype.cvar.ptr_lvalue) != 1:
    raise RuntimeError("ptr_lvalue should be a reference to an int pointer")

if cpp11_decltype.deref_first(cpp11_decltype.cvar.plain_ptr) != 1:
    raise RuntimeError("plain_ptr should point at paren_int")

# Being a reference, rebinding paren_ptr is visible through ptr_lvalue but not through plain_ptr.
cpp11_decltype.cvar.paren_ptr = cpp11_decltype.other_address()
if cpp11_decltype.deref_first2(cpp11_decltype.cvar.ptr_lvalue) != 2:
    raise RuntimeError("ptr_lvalue should follow paren_ptr")

if cpp11_decltype.deref_first(cpp11_decltype.cvar.plain_ptr) != 1:
    raise RuntimeError("plain_ptr should still point at paren_int")

# An 'int &' is wrapped by value, so it reads and writes the object it refers to.
if cpp11_decltype.cvar.int_lvalue != 1:
    raise RuntimeError("int_lvalue should be 1")

cpp11_decltype.cvar.int_lvalue = 7
if cpp11_decltype.cvar.paren_int != 7:
    raise RuntimeError("assigning to int_lvalue should write through to paren_int")

if cpp11_decltype.cvar.held_lvalue.member != 3:
    raise RuntimeError("held_lvalue should refer to paren_held")

# An enumeration is wrapped by value too, so these read as the enumerator rather than as an opaque pointer.
if cpp11_decltype.cvar.enum_lvalue != cpp11_decltype.enumerated_a:
    raise RuntimeError("enum_lvalue should be enumerated_a")

cpp11_decltype.cvar.enum_lvalue = cpp11_decltype.enumerated_b
if cpp11_decltype.cvar.paren_enum != cpp11_decltype.enumerated_b:
    raise RuntimeError("assigning to enum_lvalue should write through to paren_enum")

if cpp11_decltype.cvar.scoped_enum_lvalue != cpp11_decltype.ScopedEnumerated_scoped_a:
    raise RuntimeError("scoped_enum_lvalue should be scoped_a")

if cpp11_decltype.cvar.typedef_enum_lvalue != cpp11_decltype.typedefed_a:
    raise RuntimeError("typedef_enum_lvalue should be typedefed_a")

swig_check(cpp11_decltype.cvar.constructed_held.member, 7)
swig_check(cpp11_decltype.cvar.braced_held.member, 9)

# A parenthesised enumerator has the type of its enumeration.
swig_check(cpp11_decltype.cvar.paren_enumerator, cpp11_decltype.enumerated_b)
swig_check(cpp11_decltype.cvar.paren_qualified_enumerator, cpp11_decltype.enumerated_b)
swig_check(cpp11_decltype.cvar.paren_scoped_enumerator, cpp11_decltype.ScopedEnumerated_scoped_b)
cpp11_decltype.cvar.paren_scoped_enumerator = cpp11_decltype.ScopedEnumerated_scoped_a
swig_check(cpp11_decltype.cvar.paren_scoped_enumerator, cpp11_decltype.ScopedEnumerated_scoped_a)
swig_check(cpp11_decltype.cvar.paren_namespace_enumerator, cpp11_decltype.hue_blue)
