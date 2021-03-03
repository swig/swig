%module cpp_parameters

%{
// For Perl
#ifdef Zero
#undef Zero
#endif
%}
%inline %{

// Zero arguments
struct Zero {
  Zero() {}
  int zero() { return 0; }
  static int stat_zero() { return 0; }
};
// One mandatory argument
struct One {
  One(int a) {}
  int one(int a) { return a; }
  static int stat_one(int a) { return a; }
};
// Two mandatory arguments
struct Two {
  Two(int a, int b) {}
  int two(int a, int b) { return a + b; }
  static int stat_two(int a, int b) { return a + b; }
};
// Single optional argument
struct Single {
  Single(int a=0) {}
  int single(int a=0) { return a; }
  static int stat_single(int a=0) { return a; }
};

int global_zero() { return 0; }
int global_one(int a) { return a; }
int global_two(int a, int b) { return a + b; }
int global_single(int a=0) { return a; }

#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
