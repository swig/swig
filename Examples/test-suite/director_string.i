%module(directors="1") director_string;
%include stl.i
%include std_vector.i
%include std_string.i

// Using thread unsafe wrapping
%warnfilter(470) A;

%{
#include <vector>
#include <string>
%}

%feature("director") A;
%inline %{

struct A
{
  A(const std::string& first)
    : m_strings(1, first)
  {}
  
  virtual ~A() {}
  
  virtual const std::string& get_first() const
  { return get(0); }
  
  virtual const std::string& get(int n) const
  { return m_strings[n]; }

  std::vector<std::string> m_strings;
 };
 
 %}

%template(StringVector) std::vector<std::string>;
