from swig_test_utils import swig_check
import cpp11_template_using_base as m

d = m.DerivedInt()
swig_check(d.call(7), "Int:7")

# Inheriting constructor: using I::I; brings IntCase(int) into DerivedInt
d10 = m.DerivedInt(10)
swig_check(d10.call(7), "Int:17")

# Inheriting constructor through a typedef-name for a template-instance base (issue #2951)
swig_check(m.TypedefMixin().call(7), "Int:7")
swig_check(m.TypedefMixin(10).call(7), "Int:17")

# As above but through a typedef of a typedef (issue #2951)
swig_check(m.TypedefChainMixin().call(7), "Int:7")
swig_check(m.TypedefChainMixin(10).call(7), "Int:17")

# Multiple bases plus a typedef of a typedef naming the base (issue #2951)
tcmb = m.TypedefChainMultiBase()
swig_check(tcmb.call(7), "Int:7")
swig_check(tcmb.call(7.5), "Double:7.500000")
swig_check(m.TypedefChainMultiBase(10).call(7), "Int:17")

# Multiple bases where the base is named through a typedef-argument typedef (issue #2951)
tamb = m.TypedefArgMultiBase()
swig_check(tamb.call(7), "Int:7")
swig_check(tamb.call(7.5), "Double:7.500000")
swig_check(m.TypedefArgMultiBase(10).call(7), "Int:17")

# Base named through a scope-qualified qualifier: using ns2951::QualBase::QualBase (issue #2951)
swig_check(m.QualifiedBaseUsing().call(7), "Int:7")
swig_check(m.QualifiedBaseUsing(10).call(7), "Int:17")

# Same immediate base named through a non-fully-qualified qualifier: using QualBase::QualBase (issue #2951)
swig_check(m.SemiQualifiedBaseUsing().call(7), "Int:7")
swig_check(m.SemiQualifiedBaseUsing(10).call(7), "Int:17")

# Base reached through a typedef of a typedef whose intermediate lives in a namespace (issue #2951)
swig_check(m.NsChainUsing().call(7), "Int:7")
swig_check(m.NsChainUsing(10).call(7), "Int:17")

o = m.OverloadedIntDouble()
swig_check(o.call(7), "Int:7")
swig_check(o.call(7.5), "Double:7.500000")
