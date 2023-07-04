from cpp11_using_constructor import *


# Public base constructors
a = PublicDerived1(0, "hi").meth()
a = PublicDerived2().meth()
a = PublicDerived2(0, "hi").meth()
a = PublicDerived3().meth()
a = PublicDerived3(0, "hi").meth()
a = PublicDerived4().meth()

# Protected base constructors
# Cannot test these as the constructors are protected
