from cpp20_concepts_classes import *

from swig_test_utils import swig_check


# Class template with a prefix requires-clause on the template head.
nb = NumericBoxInt(7)
swig_check(nb.get(), 7)
nb.set(9)
swig_check(nb.get(), 9)
swig_check(nb.cube(), 729)

ndb = NumericBoxDouble(2.0)
swig_check(ndb.get(), 2.0)
swig_check(ndb.cube(), 8.0)

# Class template whose ordinary methods carry their own trailing requires-clauses.
hi = HolderInt(5)
swig_check(hi.get(), 5)
swig_check(hi.doubled(), 10)
hi.set(-3)
swig_check(hi.doubled(), -6)

hd = HolderDouble(1.5)
swig_check(hd.doubled(), 3.0)

# Class template with a compound prefix requires-clause joined by '&&'.
sb = SmallBoxInt(42)
swig_check(sb.get(), 42)

# Class template with a constrained constructor.  The constructor's 'requires Numeric<T>' clause means only Numeric T
# values reach this instantiation; 'int' and 'double' both satisfy Numeric.
cb = CheckedBoxInt(11)
swig_check(cb.get(), 11)
cbd = CheckedBoxDouble(2.5)
swig_check(cbd.get(), 2.5)

# Class template whose member function template is defined out of line with a prefix requires-clause.
ob = OutOfLineBoxInt(3)
swig_check(ob.get(), 3)

# Primary class template plus a structural partial specialization (T -> T*) whose template head additionally carries
# a requires-clause.  Primary (kind 1) carries primary_method only; partial spec (kind 2) carries partial_method only.
si = StorageInt()
swig_check(si.kind(), 1)
swig_check(si.primary_method(), 100)
swig_check(hasattr(si, "partial_method"), False)

sp = StorageIntPtr()
swig_check(sp.kind(), 2)
swig_check(sp.partial_method(), 200)
swig_check(hasattr(sp, "primary_method"), False)

# Concept constrained CRTP - View<Drawable> inherits from Drawable, render() calls the inherited draw()
# twice through 'this->'.
v = ViewDrawable()
swig_check(isinstance(v, Drawable), True)
swig_check(v.counter, 0)
v.render()
swig_check(v.counter, 2)
v.draw()
swig_check(v.counter, 3)
