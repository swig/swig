/* ----------------------------------------------------------------------
 * ruby.swg
 *
 * Ruby configuation file.
 * ---------------------------------------------------------------------- */

%runtime "rubyhead.swg"
%runtime "common.swg"

#ifdef SWIG_NOINCLUDE
%runtime "rubydec.swg"
#else
%runtime "rubydef.swg"
#endif

// Typedef declaration for VALUE.  This is provided to make VALUE typemaps
typedef unsigned long VALUE;

%typemap(ruby,in)  VALUE  "$1 = $input;";
%typemap(ruby,out) VALUE  "$result = $1;";

%typemap(ruby,varin) char * "
  Check_Type($source, T_STRING);
  if ($target) free((char*)$target);
  $target = xmalloc(RSTRING($source)->len + 1);
  strncpy((char*)$target, STR2CSTR($source), RSTRING($source)->len + 1);";


