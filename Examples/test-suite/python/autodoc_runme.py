from autodoc import *
import commentVerifier
import sys


commentVerifier.check(A.__doc__, "Proxy of C++ A class")
commentVerifier.check(A.funk.__doc__, "just a string")
commentVerifier.check(A.func0.__doc__, "func0(self, arg2, hello) -> int")
commentVerifier.check(A.func1.__doc__, "func1(A self, short arg2, Tuple hello) -> int")
commentVerifier.check(A.func2.__doc__,  "\n"
"        func2(self, arg2, hello) -> int\n"
"\n"
"        Parameters:\n"
"            arg2: short\n"
"            hello: int tuple[2]\n"
"\n"
"        "
)
commentVerifier.check(A.func3.__doc__,  "\n"
"        func3(A self, short arg2, Tuple hello) -> int\n"
"\n"
"        Parameters:\n"
"            arg2: short\n"
"            hello: int tuple[2]\n"
"\n"
"        "
)

commentVerifier.check(A.func0default.__doc__, "\n"
"        func0default(self, e, arg3, hello, f=2) -> int\n"
"        func0default(self, e, arg3, hello) -> int\n"
"        "
)
commentVerifier.check(A.func1default.__doc__, "\n"
"        func1default(A self, A e, short arg3, Tuple hello, double f=2) -> int\n"
"        func1default(A self, A e, short arg3, Tuple hello) -> int\n"
"        "
)
commentVerifier.check(A.func2default.__doc__,  "\n"
"        func2default(self, e, arg3, hello, f=2) -> int\n"
"\n"
"        Parameters:\n"
"            e: A *\n"
"            arg3: short\n"
"            hello: int tuple[2]\n"
"            f: double\n"
"\n"
"        func2default(self, e, arg3, hello) -> int\n"
"\n"
"        Parameters:\n"
"            e: A *\n"
"            arg3: short\n"
"            hello: int tuple[2]\n"
"\n"
"        "
)
commentVerifier.check(A.func3default.__doc__,  "\n"
"        func3default(A self, A e, short arg3, Tuple hello, double f=2) -> int\n"
"\n"
"        Parameters:\n"
"            e: A *\n"
"            arg3: short\n"
"            hello: int tuple[2]\n"
"            f: double\n"
"\n"
"        func3default(A self, A e, short arg3, Tuple hello) -> int\n"
"\n"
"        Parameters:\n"
"            e: A *\n"
"            arg3: short\n"
"            hello: int tuple[2]\n"
"\n"
"        "
)

commentVerifier.check(A.func0static.__doc__, "\n"
"        func0static(e, arg2, hello, f=2) -> int\n"
"        func0static(e, arg2, hello) -> int\n"
"        "
)
commentVerifier.check(A.func1static.__doc__, "\n"
"        func1static(A e, short arg2, Tuple hello, double f=2) -> int\n"
"        func1static(A e, short arg2, Tuple hello) -> int\n"
"        "
)
commentVerifier.check(A.func2static.__doc__,  "\n"
"        func2static(e, arg2, hello, f=2) -> int\n"
"\n"
"        Parameters:\n"
"            e: A *\n"
"            arg2: short\n"
"            hello: int tuple[2]\n"
"            f: double\n"
"\n"
"        func2static(e, arg2, hello) -> int\n"
"\n"
"        Parameters:\n"
"            e: A *\n"
"            arg2: short\n"
"            hello: int tuple[2]\n"
"\n"
"        "
)
commentVerifier.check(A.func3static.__doc__,  "\n"
"        func3static(A e, short arg2, Tuple hello, double f=2) -> int\n"
"\n"
"        Parameters:\n"
"            e: A *\n"
"            arg2: short\n"
"            hello: int tuple[2]\n"
"            f: double\n"
"\n"
"        func3static(A e, short arg2, Tuple hello) -> int\n"
"\n"
"        Parameters:\n"
"            e: A *\n"
"            arg2: short\n"
"            hello: int tuple[2]\n"
"\n"
"        "
)

if sys.version_info[0:2] > (2, 4):
  # Python 2.4 does not seem to work
  commentVerifier.check(A.variable_a.__doc__, "A_variable_a_get(self) -> int")
  commentVerifier.check(A.variable_b.__doc__, "A_variable_b_get(A self) -> int")
  commentVerifier.check(A.variable_c.__doc__,
  "A_variable_c_get(self) -> int\n"
  "\n"
  "Parameters:\n"
  "    self: A *\n"
  )
  commentVerifier.check(A.variable_d.__doc__,
  "A_variable_d_get(A self) -> int\n"
  "\n"
  "Parameters:\n"
  "    self: A *\n"
  )

commentVerifier.check(B.__doc__, "Proxy of C++ B class")
commentVerifier.check(C.__init__.__doc__, "__init__(self, a, b, h) -> C")
commentVerifier.check(D.__init__.__doc__, "__init__(D self, int a, int b, Hola h) -> D")
commentVerifier.check(E.__init__.__doc__, "\n"
"        __init__(self, a, b, h) -> E\n"
"\n"
"        Parameters:\n"
"            a: special comment for parameter a\n"
"            b: another special comment for parameter b\n"
"            h: enum Hola\n"
"\n"
"        "
)
commentVerifier.check(F.__init__.__doc__, "\n"
"        __init__(F self, int a, int b, Hola h) -> F\n"
"\n"
"        Parameters:\n"
"            a: special comment for parameter a\n"
"            b: another special comment for parameter b\n"
"            h: enum Hola\n"
"\n"
"        "
)

commentVerifier.check(B.funk.__doc__, "funk(B self, int c, int d) -> int")
commentVerifier.check(funk.__doc__, "funk(A e, short arg2, int c, int d) -> int")
commentVerifier.check(funkdefaults.__doc__, "\n"
"    funkdefaults(A e, short arg2, int c, int d, double f=2) -> int\n"
"    funkdefaults(A e, short arg2, int c, int d) -> int\n"
"    "
)

commentVerifier.check(func_input.__doc__, "func_input(int * INPUT) -> int")
commentVerifier.check(func_output.__doc__, "func_output() -> int")
commentVerifier.check(func_inout.__doc__, "func_inout(int * INOUT) -> int")
commentVerifier.check(banana.__doc__, "banana(S a, S b, int c, Integer d)")
