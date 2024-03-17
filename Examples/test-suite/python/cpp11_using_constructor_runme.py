from cpp11_using_constructor import *


# Public base constructors
a = PublicDerived1(0, "hi").meth()
a = PublicDerived2().meth()
a = PublicDerived2(0, "hi").meth()
a = PublicDerived3().meth()
a = PublicDerived3(0, "hi").meth()
a = PublicDerived4().meth()
a = PublicDerived5().meth()

# Protected base constructors
# Cannot test most of these as the constructors are protected
ProtectedDerived5()

# Mix of public and overloaded constructors
MixedDerived1a(0, "hi").meth()
MixedDerived1a().meth()
MixedDerived1b(0, "hi").meth()
MixedDerived1b().meth()

MixedDerived2a(0, "hi").meth()
MixedDerived2a().meth()
MixedDerived2b(0, "hi").meth()
MixedDerived2b().meth()

MixedDerived2c(0, "hi").meth()
MixedDerived2c().meth()
MixedDerived2c(0).meth()

MixedDerived2d(0, "hi").meth()
MixedDerived2d().meth()
MixedDerived2d(0).meth()

MixedDerived3a(0, "hi").meth()
MixedDerived3a().meth()
MixedDerived3b(0, "hi").meth()
MixedDerived3b().meth()

MixedDerived3c(0, "hi").meth()
MixedDerived3c().meth()
MixedDerived3c(0).meth()

MixedDerived3d(0, "hi").meth()
MixedDerived3d().meth()
MixedDerived3d(0).meth()

MixedDerived4a(0, "hi").meth()
MixedDerived4a().meth()
MixedDerived4b(0, "hi").meth()
MixedDerived4b().meth()

MixedDerived4c().meth()
MixedDerived4c(0).meth()

MixedDerived4d().meth()
MixedDerived4d(0).meth()

MixedDerived4e().meth()

MixedDerived4f().meth()

# Mix of protected base constructors and overloading
ProotDerived1a().meth()

ProotDerived1b(0, "hi").meth()
ProotDerived1b().meth()

ProotDerived1c(0, "hi").meth()
ProotDerived1c().meth()

ProotDerived1d(0).meth()
ProotDerived1d().meth()

ProotDerived1e(0).meth()
ProotDerived1e().meth()

ProotDerived2a(0, "hi").meth()

ProotDerived2b(0, "hi").meth()

ProotDerived2c(0, "hi").meth()
ProotDerived2c().meth()

ProotDerived2d(0, "hi").meth()
ProotDerived2d().meth()

ProotDerived2e(0, "hi").meth()
ProotDerived2e().meth()

ProotDerived2f(0, "hi").meth()
ProotDerived2f().meth()
ProotDerived2f(0).meth()

# Deeper inheritance chain
db3 = DeepBase3(11)
db3 = DeepBase3(11, 22)
db3 = DeepBase3(11, 22, 33)
dbp3 = DeepProtectedBase3(11, 22, 33)

# Missing base
HiddenDerived1()

# Templates and public base constructors (derive from non-template)
TemplatePublicDerived1Int(0, "hi").meth()
TemplatePublicDerived2Int().meth()
TemplatePublicDerived2Int(0, "hi").meth()
TemplatePublicDerived3Int().meth()
TemplatePublicDerived3Int(0, "hi").meth()
TemplatePublicDerived4Int().meth()
TemplatePublicDerived5Int().meth()

# Templates and public base constructors (derive from template)
TemplPublicDerived1Int(0, "hi").meth()
TemplPublicDerived2Int().meth()
TemplPublicDerived2Int(0, "hi").meth()
TemplPublicDerived3Int().meth()
TemplPublicDerived3Int(0, "hi").meth()
TemplPublicDerived4Int().meth()
TemplPublicDerived5Int().meth()
TemplPublicDerived6Int(0, "hi").meth()
TemplPublicDerived6Int().meth()

# Templated constructors (public)
tcb = TemplateConstructor1Base(0, "hi")
tcb = TemplateConstructor1Base("hi", "hi")
tcb = TemplateConstructor1Base(11.1, "hi")
tcb.normal_method()
tcb.template_method(0, "hi")
tcb.template_method("hey", "ho")

tcd1 = TemplateConstructor1Derived(0, "hi")
tcd1 = TemplateConstructor1Derived("hi", "hi")
tcd1 = TemplateConstructor1Derived(11.1, "hi")
# Not the best test as these are also in the base class, (should use introspection to check)
tcd1.normal_method()
tcd1.template_method(0, "hi")
tcd1.template_method("hey", "ho")

# Templated constructors (protected)
tcd2 = TemplateConstructor2Derived()
tcd2.normal_method()
tcd2.template_method(0, "hi")
tcd2.template_method("hey", "ho")
