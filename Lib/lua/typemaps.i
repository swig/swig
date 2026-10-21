/* -----------------------------------------------------------------------------
 * typemaps.swg
 *
 * SWIG Library file containing the main typemap code to support Lua modules.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 *                          Basic inout typemaps
 * ----------------------------------------------------------------------------- */
/*
These provide the basic ability for passing in & out of standard numeric data types
(int,long,float,double, etc)

The basic code looks like this:

%typemap(in,checkfn="lua_isnumber") int *INPUT(int temp), int &INPUT(int temp)
%{ temp = (int)lua_tonumber(L,$input);
   $1 = &temp; %}

%typemap(in, numinputs=0) int *OUTPUT (int temp)
%{ $1 = &temp; %}

%typemap(argout) int *OUTPUT
%{  lua_pushnumber(L, (double) *$1); SWIG_arg++;%}

%typemap(in) int *INOUT = int *INPUT;
%typemap(argout) int *INOUT = int *OUTPUT;

However the code below is a mixture of #defines & such, so nowhere as easy to read

To make you code work correctly it's not just a matter of %including this file
You also have to give SWIG the hints on which to use where

eg
extern int add_pointer(int* a1,int* a2); // a1 & a2 are pointer values to be added
extern void swap(int* s1, int* s2);	// does the swap

You will need to either change the argument names
extern int add_pointer(int* INPUT,int* INPUT);

or provide a %apply statement

%apply int* INOUT{ int *s1, int *s2 };
	// if SWIG sees int* s1, int* s2, assume they are inout params
*/


%define SWIG_NUMBER_TYPEMAP(TYPE)
%typemap(in,checkfn="lua_isnumber")	TYPE *INPUT($*ltype temp), TYPE &INPUT($*ltype temp)
%{ temp = ($*ltype)lua_tonumber(L,$input);
   $1 = &temp; %}
%typemap(in, numinputs=0) TYPE *OUTPUT ($*ltype temp)
%{ $1 = &temp; %}
%typemap(argout) TYPE *OUTPUT
%{  lua_pushnumber(L, (lua_Number) *$1); SWIG_arg++;%}
%typemap(in) TYPE *INOUT = TYPE *INPUT;
%typemap(argout) TYPE *INOUT = TYPE *OUTPUT;
%typemap(in) TYPE &OUTPUT = TYPE *OUTPUT;
%typemap(argout) TYPE &OUTPUT = TYPE *OUTPUT;
%typemap(in) TYPE &INOUT = TYPE *INPUT;
%typemap(argout) TYPE &INOUT = TYPE *OUTPUT;
// const version (the $*ltype is the basic number without ptr or const's)
%typemap(in,checkfn="lua_isnumber")	const TYPE *INPUT($*ltype temp)
%{ temp = ($*ltype)lua_tonumber(L,$input);
   $1 = &temp; %}
%enddef

// now the code
SWIG_NUMBER_TYPEMAP(unsigned char); SWIG_NUMBER_TYPEMAP(signed char);

SWIG_NUMBER_TYPEMAP(short); SWIG_NUMBER_TYPEMAP(unsigned short); SWIG_NUMBER_TYPEMAP(signed short);
SWIG_NUMBER_TYPEMAP(int); SWIG_NUMBER_TYPEMAP(unsigned int); SWIG_NUMBER_TYPEMAP(signed int);
SWIG_NUMBER_TYPEMAP(long); SWIG_NUMBER_TYPEMAP(unsigned long); SWIG_NUMBER_TYPEMAP(signed long);
SWIG_NUMBER_TYPEMAP(float);
SWIG_NUMBER_TYPEMAP(double);
SWIG_NUMBER_TYPEMAP(enum SWIGTYPE);
// also for long longs's
SWIG_NUMBER_TYPEMAP(long long); SWIG_NUMBER_TYPEMAP(unsigned long long); SWIG_NUMBER_TYPEMAP(signed long long);

// note we don't do char, as a char* is probably a string not a ptr to a single char

// similar for booleans
%typemap(in,checkfn="lua_isboolean") bool *INPUT(bool temp), bool &INPUT(bool temp)
%{ temp = (lua_toboolean(L,$input)!=0);
   $1 = &temp; %}

%typemap(in, numinputs=0) bool *OUTPUT (bool temp),bool &OUTPUT (bool temp)
%{ $1 = &temp; %}

%typemap(argout) bool *OUTPUT,bool &OUTPUT
%{  lua_pushboolean(L, (int)((*$1)!=0)); SWIG_arg++;%}

%typemap(in) bool *INOUT = bool *INPUT;
%typemap(argout) bool *INOUT = bool *OUTPUT;
%typemap(in) bool &INOUT = bool &INPUT;
%typemap(argout) bool &INOUT = bool &OUTPUT;

/* -----------------------------------------------------------------------------
 *                          Pointer-Pointer typemaps
 * ----------------------------------------------------------------------------- */
/*
This code is to deal with the issue for pointer-pointer's
In particular for factory methods.

for example take the following code segment:

struct iMath;    // some structure
int Create_Math(iMath** pptr); // its factory (assume it mallocs)

to use it you might have the following C code:

iMath* ptr;
int ok;
ok=Create_Math(&ptr);
// do things with ptr
//...
free(ptr);

With the following SWIG code
%apply SWIGTYPE** OUTPUT{iMath **pptr };

You can get natural wrapping in Lua as follows:
ok,ptr=Create_Math() -- ptr is a iMath* which is returned with the int
ptr=nil -- the iMath* will be GC'ed as normal
*/

%typemap(in,numinputs=0) SWIGTYPE** OUTPUT ($*ltype temp)
%{ temp = ($*ltype)0;
   $1 = &temp; %}
%typemap(argout) SWIGTYPE** OUTPUT
%{SWIG_NewPointerObj(L,*$1,$*descriptor,1); SWIG_arg++; %}

