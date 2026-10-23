%module doxygen_constructors

%feature("kwargs") ClassKwArg::ClassKwArg;

%inline %{

struct ClassZeroArg {
  /// Zero arg ctor doc.
  ClassZeroArg() {}
};

struct ClassOneArg {
  int a_;
  /// One arg ctor doc.
  ClassOneArg(int a) : a_(a) {}
  int get_a() const { return a_; }
};

struct ClassTwoArg {
  int a_;
  double b_;
  /// Two arg ctor doc.
  ClassTwoArg(int a, double b) : a_(a), b_(b) {}
  int get_a() const { return a_; }
  double get_b() const { return b_; }
};

struct ClassKwArg {
  int a_;
  int b_;
  /// Kwarg ctor doc.
  ClassKwArg(int a, int b) : a_(a), b_(b) {}
  int get_a() const { return a_; }
  int get_b() const { return b_; }
};

// No doxygen comment on this constructor.  Acts as a control in the runme: in
// -builtin mode SWIG only emits the __init__ descriptor override when a doxygen
// docstring was captured, so tp_dict["__init__"] here keeps the wrapper_descriptor
// that PyType_Ready installed for the tp_init slot.
struct ClassNoDoc {
  int a_;
  ClassNoDoc(int a) : a_(a) {}
  int get_a() const { return a_; }
};

%}

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
