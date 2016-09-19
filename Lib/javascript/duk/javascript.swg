/* -----------------------------------------------------------------------------
 * javascript.swg
 *
 * SWIG Configuration File for Duktape.
 * This file is parsed by SWIG before reading any other interface file.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 *                          includes
 * ----------------------------------------------------------------------------- */

%include <javascripttypemaps.swg>         /* The typemaps */
%include <javascriptruntime.swg>          /* The runtime stuff */
%include <javascriptkw.swg>               /* Warnings for JS keywords */
%include <javascriptcode.swg>
%include <javascriptinit.swg>

/* -----------------------------------------------------------------------------
 *                          constants typemaps
 * ----------------------------------------------------------------------------- */
// this basically adds to a table of constants
%typemap(consttab) int, unsigned int, short, unsigned short, long, unsigned long, unsigned char, signed char, bool, enum SWIGTYPE
       {SWIG_DUK_CONSTTAB_INT("$symname", $value)}

%typemap(consttab) float, double
       {SWIG_DUK_CONSTTAB_FLOAT("$symname", $value)}

%typemap(consttab) long long, unsigned long long, signed long long
       {SWIG_DUK_CONSTTAB_FLOAT("$symname", $value)}

%typemap(consttab) const long long&, const unsigned long long&, const signed long long&
       {SWIG_DUK_CONSTTAB_FLOAT("$symname", *$value)}

%typemap(consttab) char *, const char *, char [], const char []
       {SWIG_DUK_CONSTTAB_STRING("$symname", $value)}

// note: char is treated as a seperate special type
// signed char & unsigned char are numbers
%typemap(consttab) char
       {SWIG_DUK_CONSTTAB_CHAR("$symname", $value)}

%typemap(consttab) long long, unsigned long long
       {SWIG_DUK_CONSTTAB_STRING("$symname", "$value")}

%typemap(consttab) SWIGTYPE *, SWIGTYPE *const, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE []
       { SWIG_DUK_CONSTTAB_POINTER("$symname",$value, $1_descriptor) }

%typemap(consttab) SWIGTYPE
       { SWIG_DUK_CONSTTAB_POINTER("$symname",&$value, $&1_descriptor) }

// member function pointers
%typemap(consttab) SWIGTYPE (CLASS::*)
       { SWIG_DUK_CONSTTAB_BINARY("$symname", sizeof($type),&$value, $1_descriptor) }

/* ------------------------------------------------------------
 *                              Exceptions
 * ------------------------------------------------------------ */
/* Confession: I don't really like C++ exceptions

Therefore currently its just enough to get a few test cases running ok

note: if you wish to throw anything related to std::exception
use %include <std_except.i> instead
*/

// number as number+error
%typemap(throws) int,unsigned int,signed int,
				long,unsigned long,signed long,
				short,unsigned short,signed short,
				float,double,
				long long,unsigned long long,
				unsigned char, signed char,
                int&,unsigned int&,signed int&,
				long&,unsigned long&,signed long&,
				short&,unsigned short&,signed short&,
				float&,double&,
				long long&,unsigned long long&,
				unsigned char&, signed char&
%{
  duk_push_number(ctx,$1);
  goto fail;
%}

%typemap(throws) bool,bool& 
%{
  duk_push_boolean(ctx,(int)($1==true));
  goto fail;
%}

// enum as number+error
%typemap(throws) enum SWIGTYPE
%{
  duk_push_number(ctx,$1);
  goto fail;
%}

// strings are just sent as errors
%typemap(throws) char *, const char *
%{
  duk_push_string(ctx,$1);
  goto fail;
%}

// char is changed to a string
%typemap(throws) char
%{
  duk_push_lstring(ctx,&$1,1);
  goto fail;
%}

/*
Throwing object is a serious problem:
Assuming some code throws a 'FooBar'
There are a few options:
- return a pointer to it: but its unclear how long this will last for.
- return a copy of it: but not all objects are copyable
	(see exception_partial_info in the test suite for a case where you cannot do this)
- convert to a string & throw that
	it's not so useful, but it works (this is more lua like).
The third option (though not nice) is used
For a more useful solution: see std_except for more details
*/

// basic typemap for structs, classes, pointers & references
// convert to string and error
%typemap(throws) SWIGTYPE
%{
  (void)$1; /* ignore it */
  duk_push_sprintf(ctx,"object exception:%s",SWIG_TypePrettyName($1_descriptor));
  goto fail;
%}

// code to make a copy of the object and return this
// if you have a function which throws a FooBar & you want SWIG to return a copy of the object as its error
// then use one of the below
//	%apply SWIGTYPE EXCEPTION_BY_VAL {FooBar};
//	%apply SWIGTYPE& EXCEPTION_BY_VAL {FooBar&}; // note: need & twice
%typemap(throws) SWIGTYPE EXCEPTION_BY_VAL
%{
  SWIG_NewPointerObj(ctx,(void *)new $1_ltype(($1_ltype &) $1),$&1_descriptor,1);
  goto fail;
%}

// similar for object reference
// note: swig typemaps seem a little confused around here, therefore we use $basetype
%typemap(throws) SWIGTYPE& EXCEPTION_BY_VAL
%{
  SWIG_NewPointerObj(ctx,(void *)new $basetype($1),$1_descriptor,1);
  goto fail;
%}

// note: no support for object pointers
// its not clear how long the pointer is valid for, therefore not supporting it
// TODO: Duktape 2.x may support pinning.

/* ------------------------------ end javascript.swg  ------------------------------ */
