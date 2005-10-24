/* -----------------------------------------------------------------------------
 *  Typemap specializations
 * ----------------------------------------------------------------------------- */

/* no director supported in Perl */
#ifdef SWIG_DIRECTOR_TYPEMAPS
#undef SWIG_DIRECTOR_TYPEMAPS
#endif


/* -----------------------------------------------------------------------------
 *  Basic definitions
 *
 * ----------------------------------------------------------------------------- */

#define %newpointer_flags                $shadow
#define %newinstance_flags               $shadow

#define SWIG_Object                      SV *
#define VOID_Object                      $result; argvi=0

#define %set_output(obj)                 $result = obj; argvi++
#define %append_output(obj)              if (argvi >= items) EXTEND(sp,1); %set_output(obj)
#define %set_varoutput(obj)              sv_setsv($result,obj);
#define %raise(obj, type, desc)          sv_setsv(perl_get_sv("@", TRUE), obj); croak(Nullch)
%define %set_constant(name, obj)         {
  SV *sv = get_sv((char*) SWIG_prefix name, TRUE | 0x2);
  sv_setsv(sv, obj); 
  SvREADONLY_on(sv);
}
%enddef


/* -----------------------------------------------------------------------------
 *  All the typemaps
 * ----------------------------------------------------------------------------- */


%include <perlprimtypes.swg>
%include <perlstrings.swg>

%include <typemaps/swigtypemaps.swg>


