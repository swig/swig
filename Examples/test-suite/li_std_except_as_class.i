/* File : li_std_except_as_class.i */
%module li_std_except_as_class

/* NOTE: SF bug 1295: 
 *  if there were also functions throwing 'std::logic_error' and 
 *  'std::exception' then the bug would not be fully replicated */

%{
#include <exception>
#include <stdexcept>
void test_domain_error() throw(std::domain_error) 
{ throw std::domain_error("std::domain_error"); }
%}

%include <std_string.i>
#define SWIG_STD_EXCEPTIONS_AS_CLASSES
%include <std_except.i>
void test_domain_error() throw(std::domain_error) 
{ throw std::domain_error("std::domain_error"); }
