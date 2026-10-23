from cpp17_inheriting_constructors_pack import *
from swig_test_utils import swig_check

# Construct through each base's inherited constructor in turn and read back what was built through the
# shared last_constructed() free function.  Before issue #3481 was fixed the last base's constructor
# was dropped and a spurious Warning 526 was emitted.

# Two-base pack: first and last pack element.
CombinedIS(7)
swig_check(last_constructed(), "int:7")

CombinedIS("hello")
swig_check(last_constructed(), "string:hello")

# Three-base pack: the middle base (StringBase) and a last base (MultiBase) whose constructor has a
# default argument, so MultiBase contributes two overloaded constructors that are inherited alongside
# the IntBase and StringBase constructors.
CombinedISM(7)
swig_check(last_constructed(), "int:7")

CombinedISM("hello")
swig_check(last_constructed(), "string:hello")

CombinedISM(True, "x", 5)
swig_check(last_constructed(), "multi:true:x:5")

CombinedISM(True, "x")   # third argument defaults to 10
swig_check(last_constructed(), "multi:true:x:10")

# Surrounded declares its own constructors either side of the using-declaration.  Both the constructor
# before it and the one after it must survive alongside every inherited constructor.
SurroundedISM(1, 2)
swig_check(last_constructed(), "before:1:2")

SurroundedISM(3, 4, 5)
swig_check(last_constructed(), "after:3:4:5")

SurroundedISM(7)
swig_check(last_constructed(), "int:7")

SurroundedISM("hello")
swig_check(last_constructed(), "string:hello")

SurroundedISM(True, "x", 9)
swig_check(last_constructed(), "multi:true:x:9")

SurroundedISM(True, "x")   # third argument defaults to 10
swig_check(last_constructed(), "multi:true:x:10")
