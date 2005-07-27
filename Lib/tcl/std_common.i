//
// SWIG typemaps for STL - common utilities
// Luigi Ballabio
// Aug 17, 2003
//
// Tcl implementation

%include <std/std_except.i>

%types(std::size_t);
%apply size_t { std::size_t };
%apply const unsigned long& { const std::size_t& };

%types(std::ptrdiff_t);
%apply long { std::ptrdiff_t };
%apply const long& { const std::ptrdiff_t& };


