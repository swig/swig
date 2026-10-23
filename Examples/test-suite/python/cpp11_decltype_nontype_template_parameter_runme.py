from cpp11_decltype_nontype_template_parameter import *
from swig_test_utils import swig_check, swig_assert

i = IntParm3()
swig_check(i.get(), 3)
swig_check(i.member, 3)
swig_check(i.typedefed(), 3)
swig_check(i.twice(4), 8)
swig_check(ConstLongParm4().get(), 4)
swig_check(CharParmX().get(), "x")
swig_check(int_function5(), 5)
swig_check(MemberTemplateInt().get6(), 6)
h = HolderParm7()
h.held.t = 7
swig_check(h.held.t, 7)
swig_assert(Undeduced8().successor() is not None, "successor")
