//
// string_view
//


%include <typemaps/std_strings.swg>

%fragment("<string_view>");

namespace std
{
  %naturalvar string_view;
  class string_view;
}

%typemaps_std_string_view(std::string_view, char, SWIG_AsCharPtrAndSize, SWIG_FromCharPtrAndSize, %checkcode(STRINGVIEW));
