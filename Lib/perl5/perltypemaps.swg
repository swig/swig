/* ------------------------------------------------------------
 *  Typemap specializations for Perl
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

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

/* director support in Perl is experimental */
#ifndef SWIG_DIRECTOR_TYPEMAPS
#define SWIG_DIRECTOR_TYPEMAPS
#endif


/* Perl types */
#define SWIG_Object                      SV *
#define VOID_Object                      &PL_sv_undef

/* Complete overload of the output/constant/exception macros */

/* output */
%define %set_output(obj) $result = sv_2mortal(obj); argvi++ %enddef

/* append output */
%define %append_output(obj) if (argvi >= items) EXTEND(sp,1); %set_output(obj) %enddef

/* variable output */
%define %set_varoutput(obj) sv_setsv($result,obj)  %enddef

/* constant */
%define %set_constant(name, obj) %begin_block
  SV *sv = get_sv((char*) SWIG_prefix name, TRUE | 0x2 | GV_ADDMULTI);
  sv_setsv(sv, obj);
  SvREADONLY_on(sv);
%end_block %enddef

/* raise exception */
%define %raise(obj, type, desc) sv_setsv(get_sv("@", GV_ADD), obj); SWIG_fail %enddef

/* Include the unified typemap library */
%include <typemaps/swigtypemaps.swg>

/*  ------------------------------------------------------------
 *  Perl extra typemaps / typemap overrides
 * ------------------------------------------------------------ */

%typemap(throws,noblock=1) Swig::DirectorException {
  %raise($1.sv, "$type", $&descriptor);
}

%typemap(varout) SWIGTYPE *const = SWIGTYPE *;

