// Exercises a module-wide %feature("kwargs") combined with per-symbol
// %nokwargs opt-outs. Covers constructors, instance methods, static methods,
// and global functions. KwargsClass inherits the global default and accepts
// keyword arguments; NoKwargsClass marks its constructor and methods with
// %nokwargs and must reject them.

%module python_nokwargs_feature

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}

%feature("kwargs");

%nokwargs NoKwargsClass::NoKwargsClass;
%nokwargs NoKwargsClass::instance_method;
%nokwargs NoKwargsClass::static_method;
%nokwargs no_kw_global;

%inline %{
struct KwargsClass {
  int value;
  KwargsClass(int a = 10, int b = 20) : value(1000 * a + b) {}
  int instance_method(int a = 1, int b = 2) { return 10 * a + b; }
  static int static_method(int a = 1, int b = 2) { return 100 * a + b; }
};

struct NoKwargsClass {
  int value;
  NoKwargsClass(int a = 10, int b = 20) : value(1000 * a + b) {}
  int instance_method(int a = 1, int b = 2) { return 10 * a + b; }
  static int static_method(int a = 1, int b = 2) { return 100 * a + b; }
};

int kw_global(int a = 1, int b = 2)    { return 10000 * a + b; }
int no_kw_global(int a = 1, int b = 2) { return 10000 * a + b; }
%}
