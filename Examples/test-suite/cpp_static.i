/*
Testcase to test c++ static member variables and static functions.
Tests Sourceforge bug #444748.
*/

%module cpp_static

%inline %{

class StaticMemberTest {
public:
  static int static_int;
  static int grab_int() { return static_int; }
};

class StaticFunctionTest {
public:
  static void static_func() {};
  static void static_func_2(int param_1) {};
  static void static_func_3(int param_1, int param_2) {};
};

%}

%{
int StaticMemberTest::static_int = 99;
%}

%inline %{
struct StaticBase {
  static int statty;
  static int grab_statty_base() { return statty; }
  virtual ~StaticBase() {}
};
struct StaticDerived : StaticBase {
  static int statty;
  static int grab_statty_derived() { return statty; }
};
%}

%{
int StaticBase::statty = 11;
int StaticDerived::statty = 111;
%}

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
