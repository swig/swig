/* C++ overloaded operators.

   These declarations define how SWIG is going to rename C++
   overloaded operators in Tcl.  Since Tcl allows identifiers
   to be essentially any valid string, we'll just use the
   normal operator names */

#ifdef __cplusplus
%rename("+")         *::operator+;
//%rename("u+")        *::operator+();     // Unary +
//%rename("u+")        *::operator+() const;     // Unary +
%rename("-")         *::operator-;
//%rename("u-")        *::operator-();     // Unary -
//%rename("u-")        *::operator-() const;     // Unary -
%rename("*")         *::operator*;
%rename("/")         *::operator/;
%rename("<<")        *::operator<<;
%rename(">>")        *::operator>>;
%rename("&")         *::operator&;
%rename("|")         *::operator|;
%rename("^")         *::operator^;
%rename("%")         *::operator%;
%rename("=")         *::operator=;
#endif
