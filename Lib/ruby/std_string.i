
%warnfilter(801) std::string;  // wrong class name
%warnfilter(378) std::basic_string::operator!=;


AUTODOC(substr, "Return a portion of the String");

%rename("empty?") std::string::empty;
%rename("empty?") std::basic_string::empty;

%include <typemaps/std_string.swg>

