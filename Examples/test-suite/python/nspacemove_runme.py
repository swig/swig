from swig_test_utils import swig_assert, swig_check

import nspacemove


Color1 = nspacemove.Ooter.Extra.Inner1.Color
Color2 = nspacemove.Outer.Snner2.Color
swig_assert(Color1 is not Color2, "%nspacemove classes collided")
if hasattr(Color1, "__swig_destroy__"):
    swig_check(Color1.__qualname__, "Ooter.Extra.Inner1.Color")
    swig_check(Color2.__qualname__, "Outer.Snner2.Color")
swig_assert(isinstance(Color1.create(), Color1), "first moved class factory failed")
swig_assert(isinstance(Color2.create(), Color2), "second moved class factory failed")
swig_check(nspacemove.Euter.Extra.Inner1.Specular, 0x10)
swig_check(nspacemove.Outer.Enner2.Specular, 0x30)
swig_check(nspacemove.Euter.Extra.Inner1.Transmission1, 0x11)
swig_check(nspacemove.Outer.Enner2.Transmission2, 0x31)
swig_check(Color1.Specular, 0x20)
swig_check(Color2.Specular, 0x40)
swig_check(Color1.ColorEnumVal2, 0x22)
swig_check(Color2.ColorEnumVal2, 0x33)

color1 = Color1.create()
color2 = Color2.create()
color2.colors(color1, color1, color2, color2, color2)

swig_assert(isinstance(nspacemove.Additional.GlobalClass(), nspacemove.Additional.GlobalClass), "global class move failed")
swig_check(nspacemove.More.aaa, 0)
swig_check(nspacemove.More.bbb, 1)
nspacemove.takeGlobalEnum(nspacemove.More.ccc)
