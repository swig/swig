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


/* ----------------------------------------------------------------------
 *                         Standard Typemaps
 * ---------------------------------------------------------------------- */

/* --- Input Values --- */

%typemap(in) int             "$1 = NUM2INT($input);";
%typemap(in) unsigned int    "$1 = NUM2UINT($input);";
%typemap(in) short           "$1 = NUM2SHRT($input);";
%typemap(in) unsigned short  "$1 = NUM2USHRT($input);";
%typemap(in) long            "$1 = NUM2LONG($input);"; 
%typemap(in) unsigned long   "$1 = NUM2ULONG($input);"; 
%typemap(in) signed char     "$1 = (signed char) NUM2INT($input);";
%typemap(in) unsigned char   "$1 = (unsigned char) NUM2INT($input);";
%typemap(in) char            "$1 = NUM2CHR($input);";
%typemap(in) float, double   "$1 = ($1_ltype) NUM2DBL($input);";
%typemap(in) bool            "$1 = RTEST($input);";
%typemap(in) char *          "$1 = STR2CSTR($input);";
%typemap(in) char [ANY]      "$1 = STR2CSTR($input);";
%typemap(in) enum SWIGTYPE   "$1 = ($1_ltype) NUM2INT($input);";

/* Typemaps for pointers.  Note: the SWIG run-time type checker works
   even if a pointer happens to be mapped to a Ruby class */

%typemap(in) SWIGTYPE *,
             SWIGTYPE &,
             SWIGTYPE []
	"$1 = ($1_ltype) SWIG_ConvertPtr($input, $1_descriptor);"

%typemap(in) void *
        "$1 = (void *) SWIG_ConvertPtr($input, 0);";

%typemap(in) SWIGTYPE {
   $&1_ltype ptr = ($&1_ltype) SWIG_ConvertPtr($input,$&1_descriptor);
   if (ptr) $1 = *ptr;
}

/* --- Output typemaps --- */

%typemap(out) int, short, long, signed char, enum SWIGTYPE 
	"$result = INT2NUM($1);";

%typemap(out) unsigned int, unsigned short, unsigned long, unsigned char
	"$result = UINT2NUM($1);";

%typemap(out) double, float
	"$result = rb_float_new($1);";

%typemap(out) char
	"$result = rb_str_new(&$1,1);";

%typemap(out) bool
	"$result = $1 ? Qtrue : Qfalse;";

%typemap(out) char *
	"$result = rb_str_new2($1);";

%typemap(out) SWIGTYPE*, SWIGTYPE &, SWIGTYPE []
        "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor,0);";

%typemap(out) void "";

/* Primitive types--return by value */
%typemap(out) SWIGTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype($1);
  $result = SWIG_NewPointerObj((void *) resultptr, $&1_descriptor, 1);
}
#else
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  $result = SWIG_NewPointerObj((void *) resultptr, $&1_descriptor, 1);
}
#endif

%typemap(out) char [ANY] "$result = rb_str_new2($1);";

/* --- Variable Input --- */

%typemap(varin) int             "$1 = NUM2INT($input);";
%typemap(varin) unsigned int    "$1 = NUM2UINT($input);";
%typemap(varin) short           "$1 = NUM2SHRT($input);";
%typemap(varin) unsigned short  "$1 = NUM2USHRT($input);";
%typemap(varin) long            "$1 = NUM2LONG($input);"; 
%typemap(varin) unsigned long   "$1 = NUM2ULONG($input);"; 
%typemap(varin) signed char     "$1 = (signed char) NUM2INT($input);";
%typemap(varin) unsigned char   "$1 = (unsigned char) NUM2INT($input);";
%typemap(varin) char            "$1 = NUM2CHR($input);";
%typemap(varin) float, double   "$1 = ($1_ltype) NUM2DBL($input);";
%typemap(varin) bool            "$1 = RTEST($input);";

/* A string */
#ifdef __cplusplus
%typemap(varin) char * {
  char *temp = (char *) STR2CSTR($input);
  if ($1) delete [] $1;
  $1 = ($type) new char[strlen(temp)+1];
  strcpy((char*)$1,temp);
}
#else
%typemap(varin) char * {
  char *temp = (char *) STR2CSTR($input);
  if ($1) free((char*) $1);
  $1 = ($type) malloc(strlen(temp)+1);
  strcpy((char*)$1,temp);
}
#endif

%typemap(varin) char [ANY]      "strncpy($1,STR2CSTR($input),$1_dim0);";


%typemap(varin) enum SWIGTYPE   "$1 = ($1_ltype) NUM2INT($input);";

/* Typemaps for pointers.  Note: the SWIG run-time type checker works
   even if a pointer happens to be mapped to a Ruby class */

%typemap(varin) SWIGTYPE *,
             SWIGTYPE &,
             SWIGTYPE []
	"$1 = ($1_ltype) SWIG_ConvertPtr($input, $1_descriptor);"

%typemap(varin) void *
        "$1 = (void *) SWIG_ConvertPtr($input, 0);";

%typemap(varin) SWIGTYPE {
   $&1_ltype ptr = SWIG_ConvertPtr($input,$&1_descriptor);
   if (ptr) $1 = *ptr;
}

/* --- Output typemaps --- */

%typemap(varout) int, short, long, signed char, enum SWIGTYPE 
	"$result = INT2NUM($1);";

%typemap(varout) unsigned int, unsigned short, unsigned long, unsigned char
	"$result = UINT2NUM($1);";

%typemap(varout) double, float
	"$result = rb_float_new($1);";

%typemap(varout) char
	"$result = rb_str_new(&$1,1);";

%typemap(varout) bool
	"$result = $1 ? Qtrue : Qfalse;";

%typemap(varout) char *
	"$result = rb_str_new2($1);";

%typemap(varout) SWIGTYPE*, SWIGTYPE &, SWIGTYPE []
        "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor,0);";

%typemap(varout) void "";

%typemap(varout) SWIGTYPE "$result = SWIG_NewPointerObj((void *) &$1, $&1_descriptor, 1);";

%typemap(varout) char [ANY] "$result = rb_str_new2($1);";


// Typedef declaration for VALUE.  This is provided to make VALUE typemaps
typedef unsigned long VALUE;

%typemap(ruby,in)  VALUE  "$1 = $input;";
%typemap(ruby,out) VALUE  "$result = $1;";

//%typemap(ruby,varin) char * "
//  Check_Type($source, T_STRING);
//  if ($target) free((char*)$target);
//  $target = xmalloc(RSTRING($source)->len + 1);
//  strncpy((char*)$target, STR2CSTR($source), RSTRING($source)->len + 1);";


