%module extern_throws 

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW(TYPES...) throw(TYPES)
%{
#define TESTCASE_THROW(TYPES...)
%}

%inline %{
#include <exception>
extern int get() TESTCASE_THROW(std::exception);

%}

%{
int get() TESTCASE_THROW(std::exception) { return 0; }
%}

