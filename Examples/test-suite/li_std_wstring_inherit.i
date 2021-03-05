%module li_std_wstring_inherit
%include <std_basic_string.i>
%include <std_wstring.i>


%inline %{

struct A : std::wstring 
{
  A(const std::wstring& s) : std::wstring(s)
  {
  }
};

struct B 
{
  B(const std::wstring& s) : cname(0), name(s), a(s)
  {
  }
  
  char *cname;
  std::wstring name;
  A a;

};
 
std::wstring test_value(std::wstring x) {
   return x;
}

#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif

%}


