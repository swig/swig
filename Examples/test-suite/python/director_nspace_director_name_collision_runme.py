from swig_test_utils import swig_check

import director_nspace_director_name_collision as nspace


class FooA(nspace.TopLevel.A.Foo):
    def ping(self):
        return "FooA.ping()"


class FooB(nspace.TopLevel.B.Foo):
    def ping(self):
        return "FooB.ping()"


swig_check(FooA().ping(), "FooA.ping()")
swig_check(FooB().ping(), "FooB.ping()")
