%include <std_string.i>
%include <exception.i>

%{
#include <stdexcept>
%}

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
    explicit  logic_error(const string& msg);
  };

  struct domain_error : logic_error 
  {
    explicit domain_error(const string& msg);
  };

  struct invalid_argument : logic_error 
  {
    explicit invalid_argument(const string& msg);
  };

  struct length_error : logic_error 
  {
    explicit length_error(const string& msg);
  };

  struct out_of_range : logic_error 
  {
    explicit out_of_range(const string& msg);
  };

  struct runtime_error : exception 
  {
    explicit runtime_error(const string& msg);
  };

  struct range_error : runtime_error 
  {
    explicit range_error(const string& msg);
  };

  struct overflow_error : runtime_error 
  {
    explicit overflow_error(const string& msg);
  };

  struct underflow_error : runtime_error 
  {
    explicit underflow_error(const string& msg);
  };
}
