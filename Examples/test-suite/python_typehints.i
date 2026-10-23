%module python_typehints

// Tests the -typehints option, which enables PEP 484 type hints for the whole interface as if %feature("python:annotations", "typing") were set globally.
//
// This interface deliberately does not use the python:annotations feature globally: all the generated type hints come from the command
// line option alone. The feature is used below only to override the option for individual symbols.
//
// A Python type checker also checks the generated wrapper; see PYREFLY in the Python test suite Makefile. The C/C++ type annotation mode
// %feature("python:annotations", "c") is not used here because it generates C/C++ types rather than the PEP 484 types required by a type checker.

%include <std_string.i>
%include <typemaps.i>

// Multiple output values are returned in a list and so are annotated as one
%apply int *OUTPUT { int *quotient, int *remainder };

// Type hints turned off for one function and one member variable
%feature("python:annotations", "0") no_typehints;
%feature("python:annotations", "0") member_variable_no_typehints;

// Variable annotations turned off, function annotations left on
%feature("python:annotations:novar") member_variable_novar;
%feature("python:annotations:novar") A_CONSTANT_NOVAR;

%inline %{
struct Widget {
  Widget(int id) : id(id) {}
  int getId() const { return id; }
  std::string describe(const std::string &prefix) const { return prefix + "widget"; }
  static Widget *create(int id) { return new Widget(id); }
  int id;
  int member_variable_no_typehints;
  int member_variable_novar;
};

double scale(double value, int factor) { return value * factor; }
std::string join(const std::string &a, const char *b) { return a + b; }
bool is_valid(const Widget &w) { return w.getId() != 0; }
Widget *make_widget(int id) { return new Widget(id); }
void no_return_value(int i) { (void)i; }

int no_typehints(int i, const char *c) { (void)c; return i; }

// Two output values, so the wrapper returns a list
void divide(int numerator, int denominator, int *quotient, int *remainder) {
  *quotient = numerator / denominator;
  *remainder = numerator % denominator;
}

// A return value as well as two output values, all returned in the one list
bool divide_checked(int numerator, int denominator, int *quotient, int *remainder) {
  if (denominator == 0)
    return false;
  *quotient = numerator / denominator;
  *remainder = numerator % denominator;
  return true;
}

enum Colour { RED, GREEN, BLUE };
Colour next_colour(Colour c) { return c; }
%}

%constant int A_CONSTANT = 10;
%constant int A_CONSTANT_NOVAR = 20;

%inline %{
#ifdef SWIGPYTHON_BUILTIN
int is_python_builtin() { return 1; }
#else
int is_python_builtin() { return 0; }
#endif

#if defined SWIGPYTHON_FASTPROXY
int is_python_fastproxy() { return 1; }
#else
int is_python_fastproxy() { return 0; }
#endif

// -typehints defines SWIGPYTHON_TYPEHINTS
#ifdef SWIGPYTHON_TYPEHINTS
int is_typehints() { return 1; }
#else
int is_typehints() { return 0; }
#endif
%}
