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
};

%}

%{
int StaticMemberTest::static_int;
%}
