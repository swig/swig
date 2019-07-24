/* File : li_std_except_as_class.i */
%module li_std_except_as_class

/* NOTE: SF bug 1295: 
 *  if there were also functions throwing 'std::logic_error' and 
 *  'std::exception' then the bug would not be fully replicated */

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW2(T1, T2) throw(T1, T2)
%{
#define TESTCASE_THROW2(T1, T2)
%}

%{
#include <exception>
#include <stdexcept>
void test_domain_error() TESTCASE_THROW2(std::domain_error, int)
{ throw std::domain_error("std::domain_error"); }
%}

%include <std_string.i>
#define SWIG_STD_EXCEPTIONS_AS_CLASSES
%include <std_except.i>
void test_domain_error() TESTCASE_THROW2(std::domain_error, int)
{ throw std::domain_error("std::domain_error"); }

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}

