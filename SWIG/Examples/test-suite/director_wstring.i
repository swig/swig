%module(directors="1") director_wstring;
%include stl.i
%include std_vector.i
%include std_wstring.i

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
  A(const std::wstring& first)
    : m_strings(1, first)
  {}
  
  virtual ~A() {}
  
  virtual const std::wstring& get_first() const
  { return get(0); }
  
  virtual const std::wstring& get(int n) const
  { return m_strings[n]; }

  virtual const std::wstring& call_get_first() const
  { return get_first(); }

  virtual const std::wstring& call_get(int n) const
  { return get(n); }

  std::vector<std::wstring> m_strings;


  virtual void process_text(const wchar_t *text) 
  {
  }

  void call_process_func() { process_text(L"hello"); }
 };
 
 %}

%template(StringVector) std::vector<std::wstring>;
