#ifdef SWIGTYPESCRIPT

%insert("begin") %{
#define SWIGTYPESCRIPT
%}

/**
 * Typescript typemaps
 *
 * Shared for all JavaScript generators
 */


/**
 * Primitives types
 */
%typemap(ts) char*, std::string, std::string *, std::string & "string";
%typemap(ts) bool "boolean";

#define SIGNS(N) N, unsigned N, signed N
%typemap(ts) SIGNS(short), SIGNS(int), SIGNS(long), SIGNS(long long) "number";

%typemap(ts) float, double "number";

%typemap(ts) SWIGTYPE, SWIGTYPE *, SWIGTYPE & "$jstype";

%typemap(ts) void "void";


/**
 * INPUT, OUTPUT, INOUT
 */

%define INPUT_TMAPS(Type)
%typemap(ts) Type *INPUT "$typemap(ts, Type)";
%typemap(ts) Type &INPUT "$typemap(ts, Type)";
%enddef

%define OUTPUT_TMAPS(Type)
%typemap(tsout) Type *OUTPUT "$typemap(ts, Type)[]";
%typemap(tsout) Type &OUTPUT "$typemap(ts, Type)[]";
%enddef

%define INOUT_TMAPS(Type)
%typemap(ts)    Type *INOUT = Type *INPUT;
%typemap(ts)    Type &INOUT = Type &INPUT;
%typemap(tsout) Type *INOUT = Type *OUTPUT;
%typemap(tsout) Type &INOUT = Type &OUTPUT;
%enddef

%define ALL_TMAPS(Type)
INPUT_TMAPS(Type)
OUTPUT_TMAPS(Type)
INOUT_TMAPS(Type)
%enddef

ALL_TMAPS(bool)
ALL_TMAPS(char)
ALL_TMAPS(unsigned char)
ALL_TMAPS(signed char)
ALL_TMAPS(std::string)
ALL_TMAPS(short)
ALL_TMAPS(unsigned short)
ALL_TMAPS(signed short)
ALL_TMAPS(int)
ALL_TMAPS(signed)
ALL_TMAPS(unsigned)
ALL_TMAPS(long)
ALL_TMAPS(signed long)
ALL_TMAPS(unsigned long)
ALL_TMAPS(long long)
ALL_TMAPS(signed long long)
ALL_TMAPS(unsigned long long)
ALL_TMAPS(float)
ALL_TMAPS(double)


%typemap(tsout) SWIGTYPE *OUTPUT "$jstype";
%typemap(tsout) SWIGTYPE &OUTPUT "$jstype";

%typemap(tsout) SWIGTYPE *INOUT = SWIGTYPE *OUTPUT;
%typemap(tsout) SWIGTYPE &INOUT = SWIGTYPE &OUTPUT;


/**
 * strings
 */

%typemap(ts) (int ARGC, char **ARGV) "string[]";

%typemap(ts) (char *STRING, size_t LENGTH) "string";

%typemap(ts) (Char *STRING, size_t LENGTH),
  (Char *STRING, int LENGTH), (Char *STRING, size_t SIZE), (Char *STRING, int SIZE), 
  (int LENGTH, Char *STRING), (int SIZE, Char *STRING)
  = (char *STRING, size_t LENGTH);

%typemap(ts) (const void *indata, size_t inlen) = (Char *STRING, size_t LENGTH);


/**
 * Engine-specific maps
 */

%include "typescripttypemaps-engine.i";

#endif
