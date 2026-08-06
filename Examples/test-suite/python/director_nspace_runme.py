from swig_test_utils import swig_check

import director_nspace


class PythonFoo(director_nspace.TopLevel.Bar.Foo):
    def ping(self):
        return "PythonFoo.ping();"


foo = PythonFoo()
swig_check(foo.ping(), "PythonFoo.ping();")
swig_check(foo.pong(), "Bar::Foo::pong();PythonFoo.ping();")
swig_check(foo.fooBar(director_nspace.TopLevel.Bar.FooBar()), "Bar::Foo2::Foo2Bar()")
swig_check(type(foo.makeFoo()), director_nspace.TopLevel.Bar.Foo)
