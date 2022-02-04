import director_comparison_operators


class PyFoo(director_comparison_operators.Foo):
    pass


a = PyFoo()

if a.test() != "a=1,b=2":
    raise RuntimeError(a.test())
