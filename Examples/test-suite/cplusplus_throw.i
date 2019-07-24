/* This interface file checks whether the SWIG parses the throw
   directive in combination with the const directive.  Bug reported by
   Scott B. Drummonds, 08 June 2001.  
*/

%module cplusplus_throw

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

%nodefaultctor;

%inline %{

class Foo { };

class Bar {
public:
  void baz() const { };
  void foo() TESTCASE_THROW1(Foo) { };
  void bazfoo() const TESTCASE_THROW1(int) { };
};

%}

