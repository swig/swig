from autodoc import *
import commentVerifier
import inspect
import sys

def check(got, expected, expected_builtin=None, skip=False):
    if not skip:
        expect = expected
        if is_python_builtin() and expected_builtin != None:
            expect = expected_builtin
        commentVerifier.check(got, expect)

def is_new_style_class(cls):
    return hasattr(cls, "__class__")

def is_fastproxy(module):
    return "new_instancemethod" in module

if not is_new_style_class(A):
    # Missing static methods make this hard to test... skip if -classic is
    # used!
    sys.exit(0)

if is_fastproxy(dir()):
    # Detect when -fastproxy is specified and skip test as it changes the function names making it
    # hard to test... skip until the number of options are reduced in SWIG-3.1 and autodoc is improved
    sys.exit(0)

# skip builtin check - the autodoc is missing, but it probably should not be
skip = True

check(inspect.getdoc(A), "Proxy of C++ A class.", "::A")
check(inspect.getdoc(A.funk), "just a string.")
check(inspect.getdoc(A.func0),
      "func0(self, arg2, hello) -> int")
check(inspect.getdoc(A.func1),
      "func1(A self, short arg2, Tuple hello) -> int")
check(inspect.getdoc(A.func2),
      "func2(self, arg2, hello) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "arg2: short\n"
      "hello: int tuple[2]")
check(inspect.getdoc(A.func3),
      "func3(A self, short arg2, Tuple hello) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "arg2: short\n"
      "hello: int tuple[2]")

check(inspect.getdoc(A.func0default),
      "func0default(self, e, arg3, hello, f=2) -> int\n"
      "func0default(self, e, arg3, hello) -> int")
check(inspect.getdoc(A.func1default),
      "func1default(A self, A e, short arg3, Tuple hello, double f=2) -> int\n"
      "func1default(A self, A e, short arg3, Tuple hello) -> int")
check(inspect.getdoc(A.func2default),
      "func2default(self, e, arg3, hello, f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg3: short\n"
      "hello: int tuple[2]\n"
      "f: double\n"
      "\n"
      "func2default(self, e, arg3, hello) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg3: short\n"
      "hello: int tuple[2]")
check(inspect.getdoc(A.func3default),
      "func3default(A self, A e, short arg3, Tuple hello, double f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg3: short\n"
      "hello: int tuple[2]\n"
      "f: double\n"
      "\n"
      "func3default(A self, A e, short arg3, Tuple hello) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg3: short\n"
      "hello: int tuple[2]")

check(inspect.getdoc(A.func0static),
      "func0static(e, arg2, hello, f=2) -> int\n"
      "func0static(e, arg2, hello) -> int")
check(inspect.getdoc(A.func1static),
      "func1static(A e, short arg2, Tuple hello, double f=2) -> int\n"
      "func1static(A e, short arg2, Tuple hello) -> int")
check(inspect.getdoc(A.func2static),
      "func2static(e, arg2, hello, f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]\n"
      "f: double\n"
      "\n"
      "func2static(e, arg2, hello) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]")
check(inspect.getdoc(A.func3static),
      "func3static(A e, short arg2, Tuple hello, double f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]\n"
      "f: double\n"
      "\n"
      "func3static(A e, short arg2, Tuple hello) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]")

if sys.version_info[0:2] > (2, 4):
    # Python 2.4 does not seem to work
    check(inspect.getdoc(A.variable_a),
          "A_variable_a_get(self) -> int",
          "A.variable_a"
          )
    check(inspect.getdoc(A.variable_b),
          "A_variable_b_get(A self) -> int",
          "A.variable_b"
          )
    check(inspect.getdoc(A.variable_c),
          "A_variable_c_get(self) -> int\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "self: A *",
          "A.variable_c"
        )
    check(inspect.getdoc(A.variable_d),
          "A_variable_d_get(A self) -> int\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "self: A *",
          "A.variable_d"
        )

check(inspect.getdoc(B),
      "Proxy of C++ B class.",
      "::B"
      )
check(inspect.getdoc(C.__init__), "__init__(self, a, b, h) -> C", None, skip)
check(inspect.getdoc(D.__init__),
      "__init__(D self, int a, int b, Hola h) -> D", None, skip)
check(inspect.getdoc(E.__init__),
      "__init__(self, a, b, h) -> E\n"
      "\n"
      "__init__(self, a, b, h) -> E\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "a: special comment for parameter a\n"
      "b: another special comment for parameter b\n"
      "h: enum Hola", None, skip
      )
check(inspect.getdoc(F.__init__),
      "__init__(F self, int a, int b, Hola h) -> F\n"
      "\n"
      "__init__(F self, int a, int b, Hola h) -> F\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "a: special comment for parameter a\n"
      "b: another special comment for parameter b\n"
      "h: enum Hola", None, skip
      )

check(inspect.getdoc(B.funk),
      "funk(B self, int c, int d) -> int")
check(inspect.getdoc(funk), "funk(A e, short arg2, int c, int d) -> int")
check(inspect.getdoc(funkdefaults),
      "funkdefaults(A e, short arg2, int c, int d, double f=2) -> int\n"
      "funkdefaults(A e, short arg2, int c, int d) -> int")

check(inspect.getdoc(func_input), "func_input(int * INPUT) -> int")
check(inspect.getdoc(func_output), "func_output() -> int")
check(inspect.getdoc(func_inout), "func_inout(int * INOUT) -> int")
check(inspect.getdoc(func_cb), "func_cb(int c, int d) -> int")
check(inspect.getdoc(banana), "banana(S a, S b, int c, Integer d)")
