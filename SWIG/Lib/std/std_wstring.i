%{
#include <cwchar>
%}

%include <std/std_basic_string.i>

/* wide strings */


namespace std
{
  %std_comp_methods(basic_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >);
  typedef basic_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> > wstring;
}

%template(wstring) std::basic_string<wchar_t, std::char_traits<wchar_t>, std::allocator<wchar_t> >;
