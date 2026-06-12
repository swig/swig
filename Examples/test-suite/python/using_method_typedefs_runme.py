from swig_test_utils import swig_check
import using_method_typedefs as m

# A protected base method brought into the derived public interface via a using declaration whose
# qualifier names the base through various typedef forms (issue #2951 typedef coverage, for members).
swig_check(m.UseDirect().testmethod("5"), "Base:5")
swig_check(m.UseTypedef().testmethod("5"), "Base:5")
swig_check(m.UseTypedefChain().testmethod("5"), "Base:5")
swig_check(m.UseTemplateTypedef().testmethod("5"), "TBase:5")
swig_check(m.UseTemplateArgTypedef().testmethod("5"), "TBase:5")
swig_check(m.UseQualified().testmethod("5"), "Ns:5")
swig_check(m.UseNsChain().testmethod("5"), "Ns:5")

# The base has a constructor of its own.  The typedef qualifier must still resolve to the base class.
swig_check(m.UseCtorTypedef().testmethod("5"), "Ctor:5")

# The base lives in a namespace and the typedef names it without the namespace qualifier (the base
# class name is visible from the derived class as the injected class name).
swig_check(m.UseNsQualified().testmethod("5"), "Constructor:5")
swig_check(m.UseNsCtorTypedef().testmethod("5"), "Constructor:5")
swig_check(m.UseNsPlainTypedef().plainmethod("5"), "Plain:5")
