import nspace
from swig_test_utils import *

# Constructors
color1 = nspace.Outer_Inner1_Color()
color2 = nspace.Outer_Inner1_Color.create()
color3 = nspace.Outer_Inner2_Color.create()
color4 = nspace.Outer_Inner2_Color.create()
color5 = nspace.Outer_Inner2_Color(color3)

# Class methods
color1.colorInstanceMethod(20.0)
nspace.Outer_Inner1_Color.colorStaticMethod(30.0)
color3.colorInstanceMethod(40.0)
nspace.Outer_Inner2_Color.colorStaticMethod(50.0)
color3.colors(color1, color1, color3, color4, color5)

# Class enums
swig_check(nspace.Outer_Inner1_Color.Specular, 0x20)
swig_check(nspace.Outer_Inner2_Color.Specular, 0x40)

# Anonymous class enums
swig_check(nspace.Outer_Inner1_Color.ColorEnumVal1, 0)
swig_check(nspace.Outer_Inner1_Color.ColorEnumVal2, 0x22)
swig_check(nspace.Outer_Inner2_Color.ColorEnumVal2, 0x33)

# Instance member variables
color1.instanceMemberVariable = 123
swig_check(color1.instanceMemberVariable, 123)
color3.instanceMemberVariable = 456
swig_check(color3.instanceMemberVariable, 456)

# Static member variables (accessed via cvar in non-builtin mode)
swig_check(nspace.cvar.Outer_Inner1_Color_staticMemberVariable, 0)
swig_check(nspace.cvar.Outer_Inner2_Color_staticMemberVariable, 0)
nspace.cvar.Outer_Inner1_Color_staticMemberVariable = 9
nspace.cvar.Outer_Inner2_Color_staticMemberVariable = 11
swig_check(nspace.cvar.Outer_Inner1_Color_staticMemberVariable, 9)
swig_check(nspace.cvar.Outer_Inner2_Color_staticMemberVariable, 11)

# Static const member variables
swig_check(nspace.Outer_Inner1_Color.staticConstMemberVariable, 222)
swig_check(nspace.Outer_Inner2_Color.staticConstMemberVariable, 333)

# Global enums (with nspace prefix)
swig_check(nspace.Outer_Inner1_Diffuse, 0)
swig_check(nspace.Outer_Inner1_Specular, 0x10)
swig_check(nspace.Outer_Inner1_Transmission1, 0x11)
swig_check(nspace.Outer_Inner2_Diffuse, 0)
swig_check(nspace.Outer_Inner2_Specular, 0x30)
swig_check(nspace.Outer_Inner2_Transmission2, 0x31)

# SomeClass with methods returning enum values
someClass = nspace.Outer_SomeClass()
swig_assert(someClass.GetInner1ColorChannel() != someClass.GetInner2ColorChannel())
swig_assert(someClass.GetInner1Channel() != someClass.GetInner2Channel())

# Derived classes
blue3 = nspace.Outer_Inner3_Blue()
blue3.blueInstanceMethod()
blue4 = nspace.Outer_Inner4_Blue()
blue4.blueInstanceMethod()

# %nonspace class - should NOT have nspace prefix
nons = nspace.NoNSpacePlease()
swig_check(nspace.NoNSpacePlease.noNspaceStaticFunc(), 10)

# Global functions and classes without nspace
gc = nspace.GlobalClass()
gc.gmethod()
nspace.takeGlobalEnum(nspace.aaa)
