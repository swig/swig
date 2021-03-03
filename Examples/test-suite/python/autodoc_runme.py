from autodoc import *
import _autodoc
import comment_verifier
import inspect
import sys

def check(got, expected, expected_builtin=None, skip=False):
    if is_python_builtin() and skip:
        # Only skip for builtins
        pass
    else:
        expect = expected
        if is_python_builtin() and expected_builtin != None:
            expect = expected_builtin
        comment_verifier.check(got, expect)

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
      "func0default(self, e, arg3, hello, f=2) -> int")
check(inspect.getdoc(A.func1default),
      "func1default(A self, A e, short arg3, Tuple hello, double f=2) -> int")
check(inspect.getdoc(A.func2default),
      "func2default(self, e, arg3, hello, f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg3: short\n"
      "hello: int tuple[2]\n"
      "f: double")
check(inspect.getdoc(A.func3default),
      "func3default(A self, A e, short arg3, Tuple hello, double f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg3: short\n"
      "hello: int tuple[2]\n"
      "f: double")

check(inspect.getdoc(A.func0static),
      "func0static(e, arg2, hello, f=2) -> int")
check(inspect.getdoc(_autodoc.A_func0static),
      "A_func0static(e, arg2, hello, f=2) -> int")
check(inspect.getdoc(A_func0static),
      "A_func0static(e, arg2, hello, f=2) -> int")
check(inspect.getdoc(A.func1static),
      "func1static(A e, short arg2, Tuple hello, double f=2) -> int")
check(inspect.getdoc(_autodoc.A_func1static),
      "A_func1static(A e, short arg2, Tuple hello, double f=2) -> int")
check(inspect.getdoc(A_func1static),
      "A_func1static(A e, short arg2, Tuple hello, double f=2) -> int")
check(inspect.getdoc(A.func2static),
      "func2static(e, arg2, hello, f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]\n"
      "f: double")
check(inspect.getdoc(_autodoc.A_func2static),
      "A_func2static(e, arg2, hello, f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]\n"
      "f: double")
check(inspect.getdoc(A_func2static),
      "A_func2static(e, arg2, hello, f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]\n"
      "f: double")
check(inspect.getdoc(A.func3static),
      "func3static(A e, short arg2, Tuple hello, double f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]\n"
      "f: double")
check(inspect.getdoc(_autodoc.A_func3static),
      "A_func3static(A e, short arg2, Tuple hello, double f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]\n"
      "f: double")
check(inspect.getdoc(A_func3static),
      "A_func3static(A e, short arg2, Tuple hello, double f=2) -> int\n"
      "\n"
      "Parameters\n"
      "----------\n"
      "e: A *\n"
      "arg2: short\n"
      "hello: int tuple[2]\n"
      "f: double")

check(inspect.getdoc(A.variable_a),
      "variable_a"
      )
check(inspect.getdoc(A.variable_b),
      "variable_b : int"
      )
check(inspect.getdoc(A.variable_c),
      "variable_c"
      )
check(inspect.getdoc(A.variable_d),
      "variable_d : int"
      )

# Check the low-level functions (not present when using -builtin except for the static ones)
if not is_python_builtin():
    check(inspect.getdoc(_autodoc.A_funk), "just a string.")
    check(inspect.getdoc(_autodoc.A_func0),
          "A_func0(self, arg2, hello) -> int")
    check(inspect.getdoc(_autodoc.A_func1),
          "A_func1(A self, short arg2, Tuple hello) -> int")
    check(inspect.getdoc(_autodoc.A_func2),
          "A_func2(self, arg2, hello) -> int\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "arg2: short\n"
          "hello: int tuple[2]")
    check(inspect.getdoc(_autodoc.A_func3),
          "A_func3(A self, short arg2, Tuple hello) -> int\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "arg2: short\n"
          "hello: int tuple[2]")
    check(inspect.getdoc(_autodoc.A_func0default),
          "A_func0default(self, e, arg3, hello, f=2) -> int")
    check(inspect.getdoc(_autodoc.A_func1default),
          "A_func1default(A self, A e, short arg3, Tuple hello, double f=2) -> int")
    check(inspect.getdoc(_autodoc.A_func2default),
          "A_func2default(self, e, arg3, hello, f=2) -> int\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "e: A *\n"
          "arg3: short\n"
          "hello: int tuple[2]\n"
          "f: double")
    check(inspect.getdoc(_autodoc.A_func3default),
          "A_func3default(A self, A e, short arg3, Tuple hello, double f=2) -> int\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "e: A *\n"
          "arg3: short\n"
          "hello: int tuple[2]\n"
          "f: double")
    check(inspect.getdoc(_autodoc.A_variable_a_set), "A_variable_a_set(self, variable_a)")
    check(inspect.getdoc(_autodoc.A_variable_a_get), "A_variable_a_get(self) -> int" )
    check(inspect.getdoc(_autodoc.A_variable_b_set), "A_variable_b_set(A self, int variable_b)")
    check(inspect.getdoc(_autodoc.A_variable_b_get), "A_variable_b_get(A self) -> int")
    check(inspect.getdoc(_autodoc.A_variable_c_set),
          "A_variable_c_set(self, variable_c)\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "variable_c: int"
          )
    check(inspect.getdoc(_autodoc.A_variable_c_get), "A_variable_c_get(self) -> int")
    check(inspect.getdoc(_autodoc.A_variable_d_set),
          "A_variable_d_set(A self, int variable_d)\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "variable_d: int"
          )
    check(inspect.getdoc(_autodoc.A_variable_d_get), "A_variable_d_get(A self) -> int")
    check(inspect.getdoc(_autodoc.new_C), "new_C(a, b, h) -> C")
    check(inspect.getdoc(_autodoc.delete_C), "delete_C(self)")
    check(inspect.getdoc(_autodoc.new_D), "new_D(int a, int b, Hola h) -> D")
    check(inspect.getdoc(_autodoc.delete_D), "delete_D(D self)")
    check(inspect.getdoc(_autodoc.new_E),
          "new_E(a, b, h) -> E\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "a: special comment for parameter a\n"
          "b: another special comment for parameter b\n"
          "h: enum Hola"
          )
    check(inspect.getdoc(_autodoc.delete_E), "delete_E(self)")
    check(inspect.getdoc(_autodoc.new_F),
          "new_F(int a, int b, Hola h) -> F\n"
          "\n"
          "Parameters\n"
          "----------\n"
          "a: special comment for parameter a\n"
          "b: another special comment for parameter b\n"
          "h: enum Hola"
          )
    check(inspect.getdoc(_autodoc.delete_F), "delete_F(F self)")
    check(inspect.getdoc(_autodoc.B_funk), "B_funk(B self, int c, int d) -> int")
    check(inspect.getdoc(_autodoc.TInteger_inout), "TInteger_inout(TInteger self, TInteger t) -> TInteger")

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
      "Parameters\n"
      "----------\n"
      "a: special comment for parameter a\n"
      "b: another special comment for parameter b\n"
      "h: enum Hola", None, skip
      )
check(inspect.getdoc(F.__init__),
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
      "funkdefaults(A e, short arg2, int c, int d, double f=2) -> int")

check(inspect.getdoc(func_input), "func_input(int * INPUT) -> int")
check(inspect.getdoc(func_output), "func_output() -> int")
check(inspect.getdoc(func_inout), "func_inout(int * INOUT) -> int")
check(inspect.getdoc(func_cb), "func_cb(int c, int d) -> int")
check(inspect.getdoc(banana), "banana(S a, S b, int c, Integer d)")

check(inspect.getdoc(TInteger), "Proxy of C++ T< int > class.", "::T< int >")
check(inspect.getdoc(TInteger.__init__), "__init__(TInteger self) -> TInteger", None, skip)
check(inspect.getdoc(TInteger.inout), "inout(TInteger self, TInteger t) -> TInteger")

check(inspect.getdoc(process), "process(int _from, int _in, int var) -> int")
check(inspect.getdoc(process2), "process2(int _from=0, int _in=1, int var=2) -> int")
check(inspect.getdoc(process3), "process3(int _from, int _in, int var) -> int")
check(inspect.getdoc(process4), "process4(int _from=0, int _in=1, int var=2) -> int")

check(inspect.getdoc(process_complex_defval), "process_complex_defval(val=PROCESS_DEFAULT_VALUE, factor=some_type(-1)) -> int")

check(inspect.getdoc(a_structure.__init__), "__init__(a_structure self) -> a_structure", None, skip)
