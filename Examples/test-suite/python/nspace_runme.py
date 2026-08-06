from swig_test_utils import swig_assert, swig_check

import nspace


Color1 = nspace.Outer.Inner1.Color
Color2 = nspace.Outer.Inner2.Color

swig_assert(Color1 is not Color2, "same-named classes in different namespaces must be distinct")
if hasattr(Color1, "__swig_destroy__"):
    swig_check(Color1.__qualname__, "Outer.Inner1.Color")
    swig_check(Color2.__qualname__, "Outer.Inner2.Color")

color1 = Color1()
color1_copy = Color1(color1)
color1.colorInstanceMethod(20.0)
Color1.colorStaticMethod(20.0)
swig_assert(isinstance(Color1.create(), Color1), "factory returned the wrong namespaced class")

color1_copy.instanceMemberVariable = 123
swig_check(color1_copy.instanceMemberVariable, 123)
Color1.staticMemberVariable = 789
swig_check(Color1.staticMemberVariable, 789)
swig_check(Color1.staticConstMemberVariable, 222)
swig_check(Color1.staticConstEnumMemberVariable, Color1.Transmission)
swig_check(Color1.Specular, 0x20)

Color2.staticMemberVariable = 456
swig_check(Color2.staticMemberVariable, 456)
swig_check(Color2.staticConstMemberVariable, 333)
swig_check(Color2.staticConstEnumMemberVariable, Color2.Transmission)
swig_check(Color2.Specular, 0x40)
swig_assert(Color1.staticConstEnumMemberVariable != Color2.staticConstEnumMemberVariable, "class enum values collided")

color2 = Color2.create()
swig_assert(isinstance(color2, Color2), "second factory returned the wrong namespaced class")
color2.colors(color1, color1, color2, color2, color2)

some_class = nspace.Outer.SomeClass()
swig_check(some_class.GetInner1ColorChannel(), Color1.Transmission)
swig_check(some_class.GetInner2ColorChannel(), Color2.Transmission)
swig_check(some_class.GetInner1Channel(), nspace.Outer.Inner1.Transmission1)
swig_check(some_class.GetInner2Channel(), nspace.Outer.Inner2.Transmission2)
swig_check(nspace.Outer.Inner1.ColorEnumVal2, 0x11)
swig_check(nspace.Outer.Inner2.Specular, 0x30)
swig_check(nspace.Outer.Inner1.ColorEnumVal1, 0)
swig_check(nspace.Outer.Inner1.ColorEnumVal3, 0x12)

nspace.namespaceFunction(color1)
nspace.cvar.namespaceVar = 111
swig_check(nspace.cvar.namespaceVar, 111)

swig_assert(isinstance(nspace.Outer.Inner3.Blue(), Color2), "namespaced base class was not resolved")
swig_assert(isinstance(nspace.Outer.Inner4.Blue(), Color2), "second namespaced base class was not resolved")

swig_assert(hasattr(nspace.Outer, "namespce"), "%nspace class missing")
swig_assert(hasattr(nspace, "NoNSpacePlease"), "%nonspace class was moved")
swig_assert(not hasattr(nspace.Outer.Inner2, "NoNSpacePlease"), "%nonspace class remained namespaced")
swig_check(nspace.NoNSpacePlease.noNspaceStaticFunc(), 10)
swig_check(nspace.NoNSpacePlease.NoNspace1, 1)
swig_check(nspace.NoNSpacePlease.NoNspace2, 10)
swig_check(nspace.NoNSpacePlease.ReallyNoNspace1, 1)
swig_check(nspace.NoNSpacePlease.ReallyNoNspace2, 10)

swig_assert(isinstance(nspace.Outer.MyWorldPart2(), nspace.Outer.MyWorldPart2), "reopened namespace class missing")

global_class = nspace.GlobalClass()
global_class.gmethod()
swig_check(nspace.aaa, 0)
swig_check(nspace.bbb, 1)
nspace.takeGlobalEnum(nspace.ccc)
