%module extern_throws 

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

%inline %{
#include <exception>
extern int get() TESTCASE_THROW1(std::exception);

%}

%{
int get() TESTCASE_THROW1(std::exception) { return 0; }
%}

