%include <std/std_except.i>
%include <std_string.i>

%{
#include <stdexcept>
%}

namespace std {
  /* Mark all of them as exception classes */
  %feature("exceptionclass")  exception;  
  %feature("exceptionclass")  bad_exception;
  %feature("exceptionclass")  logic_error;
  %feature("exceptionclass")  domain_error;
  %feature("exceptionclass")  invalid_argument;
  %feature("exceptionclass")  length_error;
  %feature("exceptionclass")  out_of_range;
  %feature("exceptionclass")  runtime_error;
  %feature("exceptionclass")  range_error;
  %feature("exceptionclass")  overflow_error;
  %feature("exceptionclass")  underflow_error;
}

namespace std {
  struct exception 
  {
    virtual ~exception() throw();
    virtual const char* what() const throw();
  };

  struct bad_exception : exception 
  {
  };

  struct logic_error : exception 
  {
    logic_error(const string& msg);
  };

  struct domain_error : logic_error 
  {
    domain_error(const string& msg);
  };

  struct invalid_argument : logic_error 
  {
    invalid_argument(const string& msg);
  };

  struct length_error : logic_error 
  {
    length_error(const string& msg);
  };

  struct out_of_range : logic_error 
  {
    out_of_range(const string& msg);
  };

  struct runtime_error : exception 
  {
    runtime_error(const string& msg);
  };

  struct range_error : runtime_error 
  {
    range_error(const string& msg);
  };

  struct overflow_error : runtime_error 
  {
    overflow_error(const string& msg);
  };

  struct underflow_error : runtime_error 
  {
    underflow_error(const string& msg);
  };
}

