%include <std/std_basic_string.i>

/* wide strings */

namespace std
{
  %std_comp_methods(basic_string<wchar_t>);
  typedef basic_string<wchar_t> wstring;
}
