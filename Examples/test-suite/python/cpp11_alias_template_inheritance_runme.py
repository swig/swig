from cpp11_alias_template_inheritance import *
from swig_test_utils import swig_check

# Member imported through the identity alias template base 'XIdentity<X>'.
swig_check(DerivedX().m(), 11)

# Inherited enum imported through the identity alias template base 'PaletteIdentity<Palette>', and the
# alias used as a function parameter type.  The enumerators wrap as attributes of the Palette proxy.
swig_check(Palette.RED, 0)
swig_check(Palette.GREEN, 1)
swig_check(Palette.BLUE, 2)
swig_check(palette_to_int(Palette.GREEN), 1)

# Overload imported through the alias template base 'AdderAlias<int>' merges with the local overload.
ac = AliasCalcInt()
swig_check(ac.add(5), 105)    # local single-arg overload
swig_check(ac.add(2, 3), 5)   # imported two-arg overload via using through the alias template

# Inherited constructor reached through the identity alias template base 'BaseCIdentity<BaseC>'.
swig_check(DerivedC(42).value, 42)
