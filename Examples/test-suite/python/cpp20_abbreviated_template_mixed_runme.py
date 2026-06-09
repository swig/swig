from cpp20_abbreviated_template_mixed import *

from swig_test_utils import swig_check

# Each non-decorated case pairs std::string with a numeric type, so Python's type system catches an
# argument order swap (it isn't enough to compare ints to doubles - those would silently convert).
# Each mix function joins its arguments with '/' between them via a shared join_text helper, so
# the expected strings show the binding directly.

# a. Explicit typename + auto.  T=std::string, auto=int.
swig_check(a_mix_si("hello", 5), "hello/5")

# b. Auto + explicit typename.  Template <U=std::string, auto=int> -> wrapped (int x, std::string y).
swig_check(b_mix_is(3, "hi"), "3/hi")

# c. Two explicit parms surrounding an auto.  Template <T=int, V=int, auto=std::string> ->
# wrapped (int, string, int) per the function parm order.
swig_check(c_mix_isi(1, "x", 2), "1/x/2")

# d. Constrained explicit + constrained auto.  T=int, auto=double.
swig_check(d_mix_id(3, 4.0), "3/4.00")

# e. Two autos surrounding an explicit typename.  auto=string, T=int, auto=string.
swig_check(e_mix_iss("a", 7, "b"), "a/7/b")

# Cases f..j combine 'auto' with a variadic explicit pack.  Per C++20 [dcl.fct]/19 the invented
# type template-parameter for each 'auto' is appended after the explicit list, so when that list
# ends in a pack the invented sits past it.  %template binding is positional: leading non-variadic
# parms bind one to one, the pack absorbs the middle args, and trailing args bind to the invented
# parms in declaration order.

# f. Auto + variadic pack.  Ts={int, std::string}, invented=double.
#    Wrapper sig (double x, int y1, std::string y2).  Pack args wrapped in "[" / "]" markers.
swig_check(f_mix_isd(2.5, 7, "Y"), "2.50/[/7/Y/]")

# g. Leading explicit + auto + variadic pack.  T=int, Ts={std::string, double}, invented=std::string.
#    Wrapper sig (int x, std::string y, std::string z1, double z2).
swig_check(g_mix_isds(1, "Y", "Z", 2.5), "1/Y/[/Z/2.50/]")

# h. Constrained auto + variadic pack.  Ts={int, std::string}, invented=double.
#    Wrapper sig (double x, int y1, std::string y2).
swig_check(h_mix_isd(4.0, 7, "Y"), "4.00/[/7/Y/]")

# i. Two autos surrounding a variadic pack.  Ts={int, std::string}, invented1=double, invented2=int.
#    Wrapper sig (double x, int y1, std::string y2, int z).
swig_check(i_mix_isdi(2.5, 7, "Y2", 99), "2.50/[/7/Y2/]/99")

# j. Decorated auto (const auto&) + variadic pack.  Ts={int, std::string}, invented=double.
#    Wrapper sig (const double& x, int y1, std::string y2).
swig_check(j_mix_isd(2.5, 7, "Y"), "2.50/[/7/Y/]")
