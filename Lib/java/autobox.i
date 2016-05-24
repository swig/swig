// Java typemaps for autoboxing in return types of generics
%define AUTOBOX(CTYPE, JTYPE)
%typemap(autobox) CTYPE, const CTYPE& "JTYPE"
%enddef
AUTOBOX(double, Double)
AUTOBOX(float, Float)
AUTOBOX(boolean, Boolean)
AUTOBOX(signed char, Byte)
AUTOBOX(short, Short)
AUTOBOX(int, Integer)
AUTOBOX(long, Long)
AUTOBOX(SWIGTYPE, $typemap(jstype,$1_basetype))
