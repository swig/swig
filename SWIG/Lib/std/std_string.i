%include <std/std_basic_string.i>

/* plain strings */

namespace std
{
  %std_comp_methods(basic_string<char>);
  typedef basic_string<char> string;
}
