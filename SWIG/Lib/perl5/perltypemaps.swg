/* ------------------------------------------------------------
 *  Typemap specializations for Perl
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

/*
  in Perl we need to pass the CPerlObj value, sometimes, so, we define
  the decl/call macros as needed.
*/

#define SWIG_AS_DECL_ARGS SWIG_PERL_DECL_ARGS_2
#define SWIG_AS_CALL_ARGS SWIG_PERL_CALL_ARGS_2

#define SWIG_FROM_DECL_ARGS  SWIG_PERL_DECL_ARGS_1
#define SWIG_FROM_CALL_ARGS  SWIG_PERL_CALL_ARGS_1


/* Include fundamental fragemt definitions */
%include <typemaps/fragments.swg>

/* Look for user fragments file. */
%include <perlfragments.swg>

/* Perl fragments for primitive types */
%include <perlprimtypes.swg>

/* Perl fragments for char* strings */
%include <perlstrings.swg>


/* ------------------------------------------------------------
 *  Unified typemap section
 * ------------------------------------------------------------ */

/* No director supported in Perl */
#ifdef SWIG_DIRECTOR_TYPEMAPS
#undef SWIG_DIRECTOR_TYPEMAPS
#endif

#ifndef SWIG_INOUT_NODEF
#define SWIG_INOUT_NODEF
#endif


/* Perl types */
#define SWIG_Object                      SV *

/* Perl $shadow flag */
#define %newpointer_flags                $shadow
#define %newinstance_flags               $shadow


/* Complete overload of the output/constant/exception macros */

/* output */
%define %set_output(obj) 
  $result = obj;
  argvi++ %enddef

/* append output */
%define %append_output(obj)              
  if (argvi >= items) {
    EXTEND(sp,1);
  }
  %set_output(obj) %enddef

/* variable output */
%define %set_varoutput(obj) sv_setsv($result,obj)  %enddef

/* constant */
%define %set_constant(name, obj) %begin_block
  SV *_obj = obj;
  SV *sv = get_sv((char*) SWIG_prefix name, TRUE | 0x2);
  sv_setsv(sv, _obj);
  SvREADONLY_on(sv);
%end_block %enddef

/* raise exception */
%define %raise(obj, type, desc)
  sv_setsv(perl_get_sv("@", TRUE), obj); 
  croak(Nullch);
  SWIG_fail %enddef

/* Include the unified typemap library */
%include <typemaps/swigtypemaps.swg>

