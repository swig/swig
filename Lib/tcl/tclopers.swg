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

/* Ignored operators */
%ignorewarn("378:operator!= ignored")  operator!=;
%ignorewarn("365:operator+= ignored")  operator+=;
%ignorewarn("366:operator-= ignored")  operator-=;
%ignorewarn("367:operator*= ignored")  operator*=;
%ignorewarn("368:operator/= ignored")  operator/=;
%ignorewarn("369:operator%= ignored")  operator%=;
%ignorewarn("375:operator<<= ignored") operator<<=;
%ignorewarn("376:operator>>= ignored") operator>>=;
%ignorewarn("371:operator&= ignored")  operator&=;
%ignorewarn("372:operator|= ignored")  operator|=;
%ignorewarn("370:operator^= ignored")  operator^=;

#endif
