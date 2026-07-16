from swig_test_utils import swig_assert

import nspace_extend


Color1 = nspace_extend.Outer.Inner1.Color
Color2 = nspace_extend.Outer.Inner2.Color
color1 = Color1()
color2 = Color2.create()
color1.colorInstanceMethod(1.0)
Color2.colorStaticMethod(2.0)
color2.colors(color1, color1, color2, color2, color2)
swig_assert(isinstance(Color1(color1), Color1), "%extend copy constructor failed")
