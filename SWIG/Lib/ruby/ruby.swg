/* ----------------------------------------------------------------------
 * ruby.swg
 *
 * Ruby configuation file.
 * ---------------------------------------------------------------------- */

%runtime "rubyhead.swg"
%runtime "precommon.swg"
%runtime "common.swg"

#ifdef SWIG_NOINCLUDE
%runtime "rubydec.swg"
#else
%runtime "rubydef.swg"
#endif

#define %alias %feature("alias")
#define %freefunc %feature("freefunc")
#define %markfunc %feature("markfunc")
#define %mixin %feature("mixin")
#define %predicate %feature("predicate", "1")

%{
static void SWIG_AsVal(VALUE obj, int *val)
{
    *val = (int) NUM2INT(obj);
}
%}

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
%typemap(in) signed char     "$1 = ($1_ltype) NUM2INT($input);";
%typemap(in) unsigned char   "$1 = ($1_ltype) NUM2INT($input);";
%typemap(in) char            "$1 = NUM2CHR($input);";
%typemap(in) float, double   "$1 = ($1_ltype) NUM2DBL($input);";
%typemap(in) bool            "$1 = RTEST($input);";
%typemap(in) char *          "$1 = StringValuePtr($input);";
%typemap(in) char [ANY]      "$1 = StringValuePtr($input);";
%typemap(in) enum SWIGTYPE   "$1 = ($1_ltype) NUM2INT($input);";

/* Long long */

%typemap(in) long long          "$1 = ($1_ltype) NUM2LL($input);";
%typemap(in) unsigned long long "$1 = ($1_ltype) NUM2ULL($input);";

/* Typemaps for pointers.  Note: the SWIG run-time type checker works
   even if a pointer happens to be mapped to a Ruby class */

%typemap(in) SWIGTYPE *,
             SWIGTYPE []
        "SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 1);"

/* Additional check for null references */
%typemap(in) SWIGTYPE &
        "SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 1); if ($1 == NULL) rb_raise(rb_eTypeError, \"null reference\");"

/* Void pointer.  Accepts any kind of pointer */
%typemap(in) void *
        "SWIG_ConvertPtr($input, (void **) &$1, 0, 1);";

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE {
   $&1_ltype ptr;
   SWIG_ConvertPtr($input, (void **) &ptr, $&1_descriptor, 1);
   if (ptr) $1 = *ptr;
}

/* Pointer to a class member */
%typemap(in) SWIGTYPE (CLASS::*) "SWIG_ConvertPacked($input, (void *) &$1, sizeof($1_type), $1_descriptor, 1);";

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

%typemap(out) int, short, long, signed char, enum SWIGTYPE 
        "$result = INT2NUM($1);";

%typemap(out) unsigned int, unsigned short, unsigned long, unsigned char
        "$result = UINT2NUM($1);";


/* Long long */

%typemap(out) long long  "$result = LL2NUM($1);";
%typemap(out) unsigned long long "$result = ULL2NUM($1);";

/* Floating point output values */
%typemap(out) double, float
        "$result = rb_float_new($1);";

/* Character */
%typemap(out) char
        "$result = rb_str_new(&$1,1);";

/* Boolean */
%typemap(out) bool
        "$result = $1 ? Qtrue : Qfalse;";

/* C string */
%typemap(out) char *
        "$result = rb_str_new2($1);";

/* Pointers, references, and arrays */
%typemap(out) SWIGTYPE*, SWIGTYPE &, SWIGTYPE []
        "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor,$owner);";

/* Dynamic casts */

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
        swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor, (void **) &$1);
        $result = SWIG_NewPointerObj((void *) $1, ty,$owner);
}

/* Member pointer */
%typemap(out) SWIGTYPE (CLASS::*) "$result = SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor);";

/* Void */
%typemap(out) void "$result = Qnil;";

/* Special typemap for character array return values */
%typemap(out) char [ANY], const char [ANY] "$result = rb_str_new2($1);";

/* Primitive types--return by value */
%typemap(out) SWIGTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype(($1_ltype &)$1);
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

%typemap(out) const char &
      "$result = rb_str_new($1, 1);";

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

%typemap(varin) enum SWIGTYPE {
    // $1 = ($1_type) NUM2INT($input);
    if (sizeof(int) != sizeof($1)) {
        rb_raise(rb_eTypeError, "enum variable '$name' can not be set.");
    }
    SWIG_AsVal($input, (int *)(void *) &$1);
}

/* A string */
#ifdef __cplusplus
%typemap(varin) char * {
  char *temp = (char *) StringValuePtr($input);
  if ($1) delete [] $1;
  $1 = ($type) new char[strlen(temp)+1];
  strcpy((char*)$1,temp);
}
%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  char *temp = (char *) StringValuePtr($input);
  $1 = ($type) new char[strlen(temp)+1];
  strcpy((char*)$1,temp);
}
#else
%typemap(varin) char * {
  char *temp = (char *) StringValuePtr($input);
  if ($1) free((char*) $1);
  $1 = ($type) malloc(strlen(temp)+1);
  strcpy((char*)$1,temp);
}
%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  char *temp = (char *) StringValuePtr($input);
  $1 = ($type) malloc(strlen(temp)+1);
  strcpy((char*)$1,temp);
}

#endif

%typemap(varin) SWIGTYPE [ANY] {
  void *temp;
  int ii;
  $1_basetype *b = 0;
  if ((SWIG_ConvertPtr($input,(void **) &temp, $1_descriptor, 0)) == -1) {
    rb_raise(rb_eTypeError, "C variable '$name ($1_ltype)'");
  }
  b = ($1_basetype *) $1;
  for (ii = 0; ii < $1_size; ii++) b[ii] = *(($1_basetype *) temp + ii);
}

/* Special case for string array variables */
%typemap(varin) char[] {
  size_t size = sizeof($1);
  strncpy($1,StringValuePtr($input),size);
}
%typemap(varin) char[ANY]   "strncpy($1,StringValuePtr($input),$1_dim0);";


/* Typemaps for pointers.  Note: the SWIG run-time type checker works
   even if a pointer happens to be mapped to a Ruby class */

%typemap(varin) SWIGTYPE *
        "SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, 1);"

%typemap(varin) SWIGTYPE & {
        void *temp;
        SWIG_ConvertPtr($input, (void **) &temp, $1_descriptor, 1);
        $1 = *($1_ltype) temp;
}

%typemap(varin) void *
        "SWIG_ConvertPtr($input, (void **) &$1, 0, 1);";

%typemap(varin) SWIGTYPE {
   $&1_ltype ptr;
   SWIG_ConvertPtr($input, (void **) &ptr, $&1_descriptor, 1);
   if (ptr) $1 = *ptr;
}

%typemap(varin) SWIGTYPE (CLASS::*) {
    char temp[sizeof($1_type)];
    SWIG_ConvertPacked($input, (void *) temp, sizeof($1_type), $1_descriptor, 1);
    memmove((void *) &$1, temp, sizeof($1_type));
}

/* --- Output typemaps --- */

%typemap(varout) int, short, long, signed char, enum SWIGTYPE 
        "$result = INT2NUM($1);";

%typemap(varout) unsigned int, unsigned short, unsigned long, unsigned char
        "$result = UINT2NUM($1);";

%typemap(varout) long long "$result = LL2NUM($1);";
%typemap(varout) unsigned long long "$result = ULL2NUM($1);";

/* Floats and doubles */
%typemap(varout) double, float
        "$result = rb_float_new($1);";

/* Character */
%typemap(varout) char
        "$result = rb_str_new(&$1,1);";

/* Boolean */
%typemap(varout) bool
        "$result = $1 ? Qtrue : Qfalse;";

/* C string */
%typemap(varout) char *
        "$result = rb_str_new2($1);";

/* Pointers, references, and arrays */
%typemap(varout) SWIGTYPE*, SWIGTYPE []
        "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor,0);";

%typemap(varout) SWIGTYPE &
        "$result = SWIG_NewPointerObj((void *) &$1, $1_descriptor,0);";

/* Void */
%typemap(varout) void "$result = Qnil;";

/* Copy by value */
%typemap(varout) SWIGTYPE "$result = SWIG_NewPointerObj((void *) &$1, $&1_descriptor, 1);";

/* Special typemap for character array return values */
%typemap(varout) char [ANY], const char [ANY] "$result = rb_str_new2($1);";

/* Member pointer */
%typemap(varout) SWIGTYPE (CLASS::*) "$result = SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor);";

/* --- Constants --- */

%typemap(constant) int, short, long, signed char, enum SWIGTYPE 
        "rb_define_const($module,\"$symname\", INT2NUM($1));";

%typemap(constant) unsigned int, unsigned short, unsigned long, unsigned char
        "rb_define_const($module,\"$symname\", UINT2NUM($1));";

%typemap(constant) long long
        "rb_define_const($module,\"$symname\", LL2NUM($1));";        

%typemap(constant) unsigned long long
        "rb_define_const($module,\"$symname\", ULL2NUM($1));";        

%typemap(constant) double, float
        "rb_define_const($module,\"$symname\", rb_float_new($1));";

%typemap(constant) char
        "rb_define_const($module,\"$symname\", rb_str_new(\"$1\",1));";

%typemap(constant) bool
        "rb_define_const($module,\"$symname\", ($1 ? Qtrue : Qfalse));";

%typemap(constant) char *
        "rb_define_const($module,\"$symname\", rb_str_new2(\"$1\"));";

%typemap(constant) SWIGTYPE*, SWIGTYPE &, SWIGTYPE []
        "rb_define_const($module,\"$symname\", SWIG_NewPointerObj((void *) $1, $1_descriptor,0));";

%typemap(constant) SWIGTYPE "rb_define_const($module,\"$symname\", SWIG_NewPointerObj((void *) &$1, $&1_descriptor, 0));";

%typemap(constant) SWIGTYPE (CLASS::*) "rb_define_const($module, \"$symname\", SWIG_NewPackedObj((void *) &$1, sizeof($type), $1_descriptor));";

/*****************************************************************************
 *
 * Inverse argument typemaps are for marshaling C/C++ parameters to call Python
 * methods from C++ proxy wrapper classes.
 *
 *****************************************************************************/

/* directorin typemaps */

/* Primitive datatypes */

%typemap(directorin) int            "$input = INT2NUM($1);";
%typemap(directorin) short          "$input = INT2NUM($1);";
%typemap(directorin) long           "$input = LONG2NUM($1);";
%typemap(directorin) signed char    "$input = INT2NUM($1);";
%typemap(directorin) float          "$input = rb_float_new($1);";
%typemap(directorin) double         "$input = rb_float_new($1);";
%typemap(directorin) char*          "$input = rb_str_new2($1);";
%typemap(directorin) bool           "$input = $1 ? Qtrue : Qfalse;";

%typemap(directorin) unsigned int   "$input = UINT2NUM($1);";
%typemap(directorin) unsigned short "$input = UINT2NUM($1);";
%typemap(directorin) unsigned long  "$input = ULONG2NUM($1);";
%typemap(directorin) unsigned char  "$input = UINT2NUM($1);";
        
%typemap(directorin) VALUE          "$input = $1;";

/*
%typemap(directorin, parse="s") SWIGTYPE  {
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype(($1_ltype &) $1);
  $result = SWIG_NewPointerObj((void *) resultptr, $&1_descriptor, 1);
}
}
*/

/* no can do... see python.cxx
%typemap(directorin) DIRECTORTYPE * {
        {
                SwigDirector::$1_ltype proxy = dynamic_cast<SwigDirector::$1_ltype>($1_name);
                if (!proxy) {
                        $input = SWIG_NewPointerObj((void *) $1_name, $1_descriptor, 0);
                } else {
                        $input = proxy->swig_get_self();
                }
        }
}
%typemap(directorin) SWIGTYPE * {
                $input = SWIG_NewPointerObj((void *) $1_name, $1_descriptor, 0);
}
*/

/*
%typemap(directorin, parse="s") void "0";
*/
/*
%typemap(directorin) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
        $input = SWIG_NewPointerObj((void *) $1_name, $1_descriptor, $owner);
}
*/


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


%typemap(directorout) SWIGTYPE *, 
                      SWIGTYPE &, 
                      SWIGTYPE [] 
       "if ((SWIG_ConvertPtr($input,(void **) &$result, $descriptor,SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";

%typemap(directorout) void * "if ((SWIG_ConvertPtr($input,(void **) &$result, 0, SWIG_POINTER_EXCEPTION | $disown )) == -1) throw Swig::DirectorTypeMismatchException(\"Pointer conversion failed.\");";

/* ---------------------------------------------------------------------
 * typedef & typemaps for VALUE (passed through unmodified and unchecked)
 * --------------------------------------------------------------------- */

typedef unsigned long VALUE;

%typemap(ruby,in)  VALUE  "$1 = $input;";
%typemap(ruby,out) VALUE  "$result = $1;";
%typecheck(SWIG_TYPECHECK_POINTER) VALUE "$1 = 1;";

/* ------------------------------------------------------------
 * String & length
 * ------------------------------------------------------------ */

%typemap(in) (char *STRING, int LENGTH) {
    $1 = ($1_ltype) StringValuePtr($input);
    $2 = ($2_ltype) StringValueLen($input);
}

/* Some ANSI C typemaps */

%apply long { size_t };

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE {
  void *ptr;
  $1 = (NIL_P($input) || (TYPE($input) == T_DATA && SWIG_ConvertPtr($input, &ptr, $&1_descriptor, 0) != -1)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
  void *ptr;
  $1 = (NIL_P($input) || (TYPE($input) == T_DATA && SWIG_ConvertPtr($input, &ptr, $1_descriptor, 0) != -1)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  $1 = (NIL_P($input) || (TYPE($input) == T_DATA && SWIG_ConvertPtr($input, &ptr, 0, 0) != -1)) ? 1 : 0;
}

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
        const long long &, const unsigned long long &,
        enum SWIGTYPE 
{
  $1 = ((TYPE($input) == T_FIXNUM) || (TYPE($input) == T_BIGNUM)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_DOUBLE)
        float, double,
        const float &, const double &
{
  $1 = ((TYPE($input) == T_FLOAT) || (TYPE($input) == T_FIXNUM) || (TYPE($input) == T_BIGNUM)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_CHAR) char {
  $1 = (TYPE($input) == T_STRING && (RSTRING($input)->len == 1)) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  $1 = (TYPE($input) == T_STRING) ? 1 : 0;
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
  rb_exc_raise(rb_exc_new3(rb_eRuntimeError, INT2NUM($1)));
}

%typemap(throws) SWIGTYPE {
  $&1_ltype temp = new $1_ltype($1);
  if ($&1_descriptor->clientdata) {
    rb_exc_raise(rb_exc_new3(((swig_class *) ($&1_descriptor->clientdata))->klass, SWIG_NewPointerObj(temp, $&1_descriptor, 1)));
  } else {
    rb_exc_raise(rb_exc_new3(rb_eRuntimeError, SWIG_NewPointerObj(temp, $&1_descriptor, 1)));
  }
}

%typemap(throws) char * {
  rb_raise(rb_eRuntimeError, $1);
}

/* ------------------------------------------------------------
 * Overloaded operator support
 * ------------------------------------------------------------ */

#ifdef __cplusplus

%rename(__add__)      *::operator+;
%rename(__pos__)      *::operator+();
%rename(__pos__)      *::operator+() const;
%rename(__sub__)      *::operator-;
%rename(__neg__)      *::operator-();
%rename(__neg__)      *::operator-() const;
%rename(__mul__)      *::operator*;
%rename(__div__)      *::operator/;
%rename(__mod__)      *::operator%;
%rename(__lshift__)   *::operator<<;
%rename(__rshift__)   *::operator>>;
%rename(__and__)      *::operator&;
%rename(__or__)       *::operator|;
%rename(__xor__)      *::operator^;
%rename(__invert__)   *::operator~;
%rename(__lt__)       *::operator<;
%rename(__le__)       *::operator<=;
%rename(__gt__)       *::operator>;
%rename(__ge__)       *::operator>=;
%rename(__eq__)       *::operator==;

/* Special cases */
%rename(__call__)     *::operator();

/* Ignored operators */
%ignorewarn("378:operator!= ignored")  operator!=;
%ignorewarn("365:operator+= ignored")  operator+=;
%ignorewarn("366:operator-= ignored")  operator-=;
%ignorewarn("367:operator*= ignored")  operator*=;
%ignorewarn("368:operator/= ignored")  operator/=;
%ignorewarn("369:operator%= ignored")  operator%=;
%ignorewarn("375:operator<<= ignored") operator<<=;
%ignorewarn("376:operator>>= ignored") operator>>=;
%ignorewarn("371:operator&= ignored")  operator&=;
%ignorewarn("372:operator|= ignored")  operator|=;
%ignorewarn("370:operator^= ignored")  operator^=;
%ignorewarn("362:operator= ignored")   operator=;
%ignorewarn("383:operator++ ignored")  operator++;
%ignorewarn("384:operator-- ignored")  operator--;
%ignorewarn("381:operator&& ignored")  operator&&;
%ignorewarn("382:operator|| ignored")  operator||;
// %ignorewarn("387:operator-> ignored")  operator->;
%ignorewarn("386:operator->* ignored") operator->*;
%ignorewarn("389:operator[] ignored (consider using %extend)") operator[];

/* ruby keywords */
/* please test and activate */
// %include "rubykw.swg"

#endif /* __cplusplus */
