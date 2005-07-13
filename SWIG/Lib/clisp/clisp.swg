/* Define a C preprocessor symbol that can be used in interface files
   to distinguish between the SWIG language modules. */ 

#define SWIG_CLISP

/* Typespecs for basic types. */

%typemap(ffitype) void "NIL";
%typemap(ffitype) void * "(ffi:c-pointer NIL)";
%typemap(ffitype) char "character";
%typemap(ffitype) char * "ffi:c-string";
%typemap(ffitype) unsigned char "ffi:uchar";
%typemap(ffitype) signed char "ffi:char";
%typemap(ffitype) short "ffi:short";
%typemap(ffitype) signed short "ffi:short";
%typemap(ffitype) unsigned short "ffi:ushort";
%typemap(ffitype) int "ffi:int";
%typemap(ffitype) int * "(ffi:c-pointer ffi:int)";
%typemap(ffitype) signed int "ffi:int";
%typemap(ffitype) unsigned int "ffi:uint";
%typemap(ffitype) long "ffi:long";
%typemap(ffitype) signed long "ffi:long";
%typemap(ffitype) unsigned long "ffi:ulong";
%typemap(ffitype) float "SINGLE-FLOAT";
%typemap(ffitype) float * "(ffi:c-pointer SINGLE-FLOAT)";
%typemap(ffitype) double "DOUBLE_FLOAT";
%typemap(ffitype) double * "(ffi:c-pointer DOUBLE-FLOAT)";

