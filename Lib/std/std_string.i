%include <std/std_basic_string.i>

/* plain strings */

namespace std
{
  %std_comp_methods(basic_string<char, std::char_traits<char>, std::allocator<char> >);
  typedef basic_string<char, std::char_traits<char>, std::allocator<char> > string;
}


%template(string) std::basic_string<char, std::char_traits<char>, std::allocator<char> >;
