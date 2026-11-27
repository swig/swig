%typemap(pytyping) std::basic_string<char> str, std::basic_string<wchar_t> str "__builtin__.str"

%include <std/std_sstream.i>
