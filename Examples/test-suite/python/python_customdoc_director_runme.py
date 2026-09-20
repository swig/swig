import python_customdoc_director as m
from swig_test_utils import swig_assert, swig_check


def documentation(cls):
    return (cls.__doc__ or "") + (cls.__init__.__doc__ or "")


for cls, prototypes in (
    (m.EmptyConstructor, ("EmptyConstructor()",)),
    (m.Single, ("Single(int value)",)),
    (m.Defaults, ("Defaults()", "Defaults(int value)")),
    (m.Multiple, ("Multiple(int value)", "Multiple(double value, int extra)")),
):
    doc = documentation(cls)
    swig_assert("PyObject" not in doc, doc)
    for prototype in prototypes:
        swig_assert(prototype in doc, doc)
    if cls is m.EmptyConstructor:
        continue
    try:
        cls(object())
    except TypeError as error:
        message = str(error)
        swig_assert("PyObject" not in message, message)
        for prototype in prototypes:
            swig_assert(prototype in message, message)
    else:
        raise RuntimeError("Expected constructor TypeError")

swig_check(m.EmptyConstructor().method(3), 3)
swig_assert("int self" in m.EmptyConstructor.method.__doc__ or "int arg0" in m.EmptyConstructor.method.__doc__)
swig_check(m.Single(4).method(), 4)
swig_check(m.Defaults().method(), 7)
swig_check(m.Defaults(5).method(), 5)
swig_check(m.Multiple(6).method(), 6)
swig_check(m.Multiple(2.5, 3).method(), 5)


class Derived(m.Single):
    def __init__(self, value):
        m.Single.__init__(self, value)

    def method(self):
        return self.value + 10


swig_check(m.invoke(Derived(8)), 18)


# Callbacks receive wrapper positional arguments, including proxy director self.
import inspect

seen = []
def describe_arguments(*args):
    seen.append(args)
    return "recorded"

m.describe_arguments = describe_arguments
token = object()
for cls in (m.Single, Derived):
    try:
        cls(token)
    except TypeError as error:
        swig_assert("You have: 'recorded'" in str(error))
        swig_assert("PyObject" not in str(error))
    else:
        raise RuntimeError("Expected constructor TypeError")
    received = seen.pop()
    if inspect.isbuiltin(m.Single(1).method):
        swig_check(received, (token,))
    else:
        swig_check(received[1:], (token,))
        if cls is m.Single:
            swig_check(received[0], None)
        else:
            swig_assert(isinstance(received[0], Derived))
