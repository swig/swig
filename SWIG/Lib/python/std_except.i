%include <std/std_except.i>
%include <std_string.i>

%{
#include <stdexcept>
%}



namespace std {
  /* 
     Mark all of std exception classes as "exception classes" via
     the "exceptionclass" feature.
     
     If needed, you can disable it by using %noexceptionclass.
  */
  %exceptionclass  exception;  
  %exceptionclass  bad_exception;
  %exceptionclass  logic_error;
  %exceptionclass  domain_error;
  %exceptionclass  invalid_argument;
  %exceptionclass  length_error;
  %exceptionclass  out_of_range;
  %exceptionclass  runtime_error;
  %exceptionclass  range_error;
  %exceptionclass  overflow_error;
  %exceptionclass  underflow_error;
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

