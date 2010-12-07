/*
Testcase to test c++ static member variables and static functions.
Tests Sourceforge bug #444748.
*/

%module cpp_static

%inline %{

class StaticMemberTest {
public:
  static int static_int;
};

class StaticFunctionTest {
public:
  static void static_func() {};
  static void static_func_2(int param_1) {};
  static void static_func_3(int param_1, int param_2) {};
};

%}

%{
int StaticMemberTest::static_int;
%}
