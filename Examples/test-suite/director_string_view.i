%module(directors="1") director_string_view;

#if defined SWIGCSHARP || defined SWIGJAVA || defined SWIGLUA || defined SWIGPHP

%include std_string.i
%include std_string_view.i

// Using thread unsafe wrapping
%warnfilter(SWIGWARN_TYPEMAP_THREAD_UNSAFE,SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) A;

%{
#include <vector>
#include <string>
#include <string_view>
%}

%feature("director") A;
%inline %{

struct A
{
  A(const std::string& first)
    : m_strings(1, first)
  {}

  virtual ~A() {}

  virtual std::string_view get_first() const
  { return get(0); }

  virtual std::string_view get(int n) const
  { return m_strings[n]; }

  virtual std::string_view call_get_first() const
  { return get_first(); }

  virtual std::string_view call_get(int n) const
  { return get(n); }

  virtual int string_length(std::string_view s) const
  { return (int)s.size(); }


  virtual void process_text(const char *text)
  {
  }

  void call_process_func() { process_text("hello"); }

private:
  std::vector<std::string> m_strings;
};

%}

#endif
