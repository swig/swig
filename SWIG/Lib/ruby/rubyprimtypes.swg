/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* --- Input Values --- */

%typemap(in) int             "$1 = NUM2INT($input);";
%typemap(in) unsigned int    "$1 = NUM2UINT($input);";
%typemap(in) short           "$1 = NUM2SHRT($input);";
%typemap(in) unsigned short  "$1 = NUM2USHRT($input);";
%typemap(in) long            "$1 = NUM2LONG($input);";
%typemap(in) unsigned long   "$1 = NUM2ULONG($input);";
%typemap(in) signed char     "$1 = ($1_ltype) NUM2INT($input);";
%typemap(in) unsigned char   "$1 = ($1_ltype) NUM2INT($input);";
%typemap(in) char            "$1 = NUM2CHR($input);";
%typemap(in) float, double   "$1 = ($1_ltype) NUM2DBL($input);";
%typemap(in) bool            "$1 = RTEST($input);";

/* Long long */

%typemap(in) long long          "$1 = ($1_ltype) NUM2LL($input);";
%typemap(in) unsigned long long "$1 = ($1_ltype) NUM2ULL($input);";

/* Const primitive references.  Passed by value */

%typemap(in) const int & (int temp),
             const signed char & (signed char temp),
             const unsigned char & (unsigned char temp)
        "temp = ($*1_ltype) NUM2INT($input);
         $1 = &temp;";

%typemap(in) const short & (short temp)
        "temp = ($*1_ltype) NUM2SHRT($input);
         $1 = &temp;";

%typemap(in) const long & (long temp)
        "temp = ($*1_ltype) NUM2LONG($input);
         $1 = &temp;";

%typemap(in) const unsigned int & (unsigned int temp)
        "temp = ($*1_ltype) NUM2UINT($input);
         $1 = &temp;";

%typemap(in) const unsigned short & (unsigned short temp)
        "temp = ($*1_ltype) NUM2USHRT($input);
         $1 = &temp;";

%typemap(in) const unsigned long & (unsigned long temp)
        "temp = ($*1_ltype) NUM2ULONG($input);
         $1 = &temp;";

%typemap(in) const bool & (bool temp)
        "temp = ($*1_ltype) RTEST($input);
         $1 = &temp;";

%typemap(in) const float & (float temp),
             const double & (double temp)
        "temp = ($*1_ltype) NUM2DBL($input);
         $1 = &temp;";

%typemap(in) const long long & ($*1_ltype temp)
        "temp = ($*1_ltype) NUM2LL($input);
         $1 = &temp;";

%typemap(in) const unsigned long long & ($*1_ltype temp)
        "temp = ($*1_ltype) NUM2ULL($input);
         $1 = &temp;";

%typemap(in) const char &(char temp) {
        char *stemp = StringValuePtr($input);
        temp = *stemp;
        $1 = &temp;
}

/* --- Output typemaps --- */

%typemap(out) int, short, long, signed char
        "$result = INT2NUM($1);";

%typemap(out) unsigned int, unsigned short, unsigned long, unsigned char
        "$result = UINT2NUM($1);";

/* Long long */

%typemap(out) long long  "$result = LL2NUM($1);";
%typemap(out) unsigned long long "$result = ULL2NUM($1);";

/* Floating point output values */
%typemap(out) double, float
        "$result = rb_float_new($1);";

/* Boolean */
%typemap(out) bool
        "$result = $1 ? Qtrue : Qfalse;";

/* References to primitive types.  Return by value */

%typemap(out) const int &,
              const short &,
              const long &,
              const signed char &
      "$result = INT2NUM((long) *($1));";

%typemap(out) const unsigned int &,
              const unsigned short &,
              const unsigned long &,
              const unsigned char &
      "$result = UINT2NUM((unsigned long) *($1));";

%typemap(out) const bool &
      "$result = *($1) ? Qtrue : Qfalse;";

%typemap(out) const float &, const double &
      "$result = rb_float_new((double) *($1));";

%typemap(out) const long long &
      "$result = LL2NUM(*($1));";

%typemap(out) const unsigned long long &
      "$result = ULL2NUM(*($1));";

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

%typemap(varin) long long       "$1 = NUM2LL($input);";
%typemap(varin) unsigned long long "$1 = NUM2ULL($input);";

/* --- Variable Output --- */

%typemap(varout) int, short, long, signed char
        "$result = INT2NUM($1);";

%typemap(varout) unsigned int, unsigned short, unsigned long, unsigned char
        "$result = UINT2NUM($1);";

%typemap(varout) long long "$result = LL2NUM($1);";
%typemap(varout) unsigned long long "$result = ULL2NUM($1);";

/* Floats and doubles */
%typemap(varout) double, float
        "$result = rb_float_new($1);";

/* Boolean */
%typemap(varout) bool
        "$result = $1 ? Qtrue : Qfalse;";

/* --- Constants --- */

%typemap(constant) int, short, long, signed char
        "rb_define_const($module,\"$symname\", INT2NUM($1));";

%typemap(constant) unsigned int, unsigned short, unsigned long, unsigned char
        "rb_define_const($module,\"$symname\", UINT2NUM($1));";

%typemap(constant) long long
        "rb_define_const($module,\"$symname\", LL2NUM($1));";

%typemap(constant) unsigned long long
        "rb_define_const($module,\"$symname\", ULL2NUM($1));";

%typemap(constant) double, float
        "rb_define_const($module,\"$symname\", rb_float_new($1));";

%typemap(constant) bool
        "rb_define_const($module,\"$symname\", ($1 ? Qtrue : Qfalse));";

/* directorin typemaps */

%typemap(directorin) int            "$input = INT2NUM($1);";
%typemap(directorin) short          "$input = INT2NUM($1);";
%typemap(directorin) long           "$input = LONG2NUM($1);";
%typemap(directorin) signed char    "$input = INT2NUM($1);";
%typemap(directorin) float          "$input = rb_float_new($1);";
%typemap(directorin) double         "$input = rb_float_new($1);";
%typemap(directorin) bool           "$input = $1 ? Qtrue : Qfalse;";

%typemap(directorin) unsigned int   "$input = UINT2NUM($1);";
%typemap(directorin) unsigned short "$input = UINT2NUM($1);";
%typemap(directorin) unsigned long  "$input = ULONG2NUM($1);";
%typemap(directorin) unsigned char  "$input = UINT2NUM($1);";

/* --- directorout typemaps --- */

%define DIRECTOROUT_TYPEMAP(type, converter)
%typemap(directorargout) type *DIRECTOROUT "*$result = (type) converter($input);";
%typemap(directorout) type "$result = (type) converter($input);";
%typemap(directorout) type &DIRECTOROUT = type
%enddef

DIRECTOROUT_TYPEMAP(char, NUM2INT);
DIRECTOROUT_TYPEMAP(unsigned char, NUM2UINT);
DIRECTOROUT_TYPEMAP(short, NUM2INT);
DIRECTOROUT_TYPEMAP(unsigned short, NUM2INT);
DIRECTOROUT_TYPEMAP(int, NUM2INT);
DIRECTOROUT_TYPEMAP(unsigned int, NUM2INT);
DIRECTOROUT_TYPEMAP(long, NUM2INT);
DIRECTOROUT_TYPEMAP(unsigned long, NUM2INT);
DIRECTOROUT_TYPEMAP(long long, NUM2INT);
DIRECTOROUT_TYPEMAP(unsigned long long, NUM2INT);
DIRECTOROUT_TYPEMAP(float, NUM2DBL);
DIRECTOROUT_TYPEMAP(double, NUM2DBL);
DIRECTOROUT_TYPEMAP(bool, RTEST);

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_BOOL) bool {
  $1 = ($input == Qtrue || $input == Qfalse) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INTEGER)
         int, short, long,
         unsigned int, unsigned short, unsigned long,
         signed char, unsigned char,
         long long, unsigned long long,
         const int &, const short &, const long &,
        const unsigned int &, const unsigned short &, const unsigned long &,
        const long long &, const unsigned long long &
{
  $1 = ((TYPE($input) == T_FIXNUM) || (TYPE($input) == T_BIGNUM)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_DOUBLE)
        float, double,
        const float &, const double &
{
  $1 = ((TYPE($input) == T_FLOAT) || (TYPE($input) == T_FIXNUM) || (TYPE($input) == T_BIGNUM)) ? 1 : 0;
}

/* ------------------------------------------------------------
 * Exception handling
 * ------------------------------------------------------------ */

%typemap(throws) int,
                  long,
                  short,
                  unsigned int,
                  unsigned long,
                  unsigned short {
  rb_exc_raise(rb_exc_new3(rb_eRuntimeError, rb_obj_as_string(INT2NUM($1))));
}

