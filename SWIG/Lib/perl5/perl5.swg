/* -----------------------------------------------------------------------------
 * perl5.swg
 *
 * Perl 5 configuration file
 * ----------------------------------------------------------------------------- */

%runtime "swigrun.swg"        // Common C API type-checking code
%runtime "perlrun.swg"        // Perl runtime functions
%runtime "noembed.h"          // undefine Perl5 macros

#define %perlcode  %insert("perl")

/* Typemaps for input parameters */

%typemap(in)  int, short, long, signed char, enum SWIGTYPE
       "$1 = ($1_ltype) SvIV($input);";

%typemap(in)  bool
       "$1 = SvIV($input) ? true : false;";

%typemap(in) unsigned int, unsigned short, unsigned long, unsigned char
	"$1 = ($1_ltype) SvUV($input);";

%typemap(in)  char
       "$1 = ($1_ltype) *SvPV($input,PL_na);";

%typemap(in)  float, double 
       "$1 = ($1_ltype) SvNV($input);\n";

%typemap(in)  long long "$1 = ($1_ltype) strtoll(SvPV($input, PL_na), 0, 0);";
%typemap(in)  unsigned long long "$1 = ($1_ltype) strtoull(SvPV($input, PL_na), 0, 0);";

%typemap(in) char *
       "if (!SvOK((SV*) $input)) $1 = 0;
        else $1 = ($1_ltype) SvPV($input, PL_na);";

%typemap(in) char [ANY] 
       "$1 = SvPV($input,PL_na);\n"; 

%typemap(in) SWIGTYPE *, SWIGTYPE [], SWIGTYPE & {
	if (SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor,0) < 0) {
            SWIG_croak("Type error in argument $argnum of $symname. Expected $1_mangle");
        }
}

%typemap(in) void * {
	if (SWIG_ConvertPtr($input, (void **) &$1, 0,0) < 0) {
            SWIG_croak("Type error in argument $argnum of $symname. Expected $1_mangle");
        }
}

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE {
    $&1_ltype argp;
    if (SWIG_ConvertPtr($input,(void **) &argp, $&1_descriptor,0) < 0) {
            SWIG_croak("Type error in argument $argnum of $symname. Expected $&1_mangle");
    }
    $1 = *argp;
}

/* Pointer to a class member */
%typemap(in) SWIGTYPE (CLASS::*) {
     if ((SWIG_ConvertPacked($input, (void *) &$1, sizeof($1_type), $1_descriptor,0)) < 0) {
            SWIG_croak("Type error in argument $argnum of $symname. Expected $&1_mangle");
     }          
}

/* Const primitive references.  Passed by value */

%typemap(in) const int & (int temp),
	     const short & (short temp),
             const long  & (long temp),
             const signed char & (signed char temp),
             const enum SWIGTYPE & ($*1_ltype temp)
	"temp = ($*1_ltype) SvIV($input);
         $1 = &temp;";

%typemap(in) const bool & (bool temp)
	"temp = SvIV($input) ? true : false;
         $1 = &temp;";

%typemap(in) const unsigned int & (unsigned int temp),
             const unsigned short & (unsigned short temp),
             const unsigned long & (unsigned long temp),
             const unsigned char & (unsigned char temp)
	"temp = ($*1_ltype) SvUV($input);
         $1 = &temp;";

%typemap(in) const float & (float temp),
	     const double & (double temp)
	"temp = ($*1_ltype) SvNV($input);
         $1 = &temp;";

%typemap(in) const long long & ($*1_ltype temp) 
        "temp = ($*1_ltype) strtoll(SvPV($input,PL_na),0,0);
         $1 = &temp;";

%typemap(in) const unsigned long long & ($*1_ltype temp) 
        "temp = ($*1_ltype) strtoull(SvPV($input, PL_na),0,0);
         $1 = &temp;";

%typemap(in) const char &(char temp) {
        temp = *SvPV($input,PL_na);
        $1 = &temp;
}

/* Typemap for output values */

%typemap(out) int, short, long, signed char, bool, enum SWIGTYPE 
    "ST(argvi) = sv_newmortal();
     sv_setiv(ST(argvi++), (IV) $1);";

%typemap(out) unsigned int, unsigned short, unsigned long, unsigned char
    "ST(argvi) = sv_newmortal();
     sv_setuv(ST(argvi++), (UV) $1);";

%typemap(out) float, double
    "ST(argvi) = sv_newmortal();
     sv_setnv(ST(argvi++), (double) $1);";

%typemap(out) char 
    "ST(argvi) = sv_newmortal();
     sv_setpvn((SV*)ST(argvi++), &$1, 1);";

%typemap(out) char *
    "ST(argvi) = sv_newmortal();
     if ($1) {
        sv_setpv((SV*)ST(argvi++), (char *) $1);
     } else {
        sv_setsv((SV*)ST(argvi++), &PL_sv_undef);
     }";

%typemap(out) long long {
    char temp[256];
    sprintf(temp,"%lld", (long long) $1);
    ST(argvi) = sv_newmortal();
    sv_setpv((SV*)ST(argvi++), temp);
}

%typemap(out) unsigned long long {
    char temp[256];
    sprintf(temp,"%llu", (unsigned long long) $1);
    ST(argvi) = sv_newmortal();
    sv_setpv((SV*)ST(argvi++), temp);
}

%typemap(out) SWIGTYPE *, SWIGTYPE [], SWIGTYPE & 
    "ST(argvi) = sv_newmortal();
     SWIG_MakePtr(ST(argvi++), (void *) $1, $1_descriptor, $shadow|$owner);";


%typemap(out) SWIGTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultobj = new $1_ltype(($1_ltype &)$1);
  ST(argvi) = sv_newmortal();
  SWIG_MakePtr(ST(argvi++), (void *) resultobj, $&1_descriptor, $shadow|SWIG_OWNER);
}
#else
{
  $&1_ltype resultobj = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultobj, &$1, sizeof($1_type));
  ST(argvi) = sv_newmortal();
  SWIG_MakePtr(ST(argvi++), (void *) resultobj, $&1_descriptor, $shadow|SWIG_OWNER);
}
#endif

/* Dynamic casts */

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
  swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor, (void **) &$1);
  ST(argvi) = sv_newmortal();
  SWIG_MakePtr(ST(argvi++), (void *) $1, ty, $shadow|$owner);
}

/* Member pointer */
%typemap(out) SWIGTYPE (CLASS::*) {
  ST(argvi) = sv_newmortal();
  SWIG_MakePackedObj(ST(argvi), (void *) &$1, sizeof($1_type), $1_descriptor);
  argvi++;
}

%typemap(out) void "";

/* Typemap for character array returns */

%typemap(out) char [ANY] 
     "ST(argvi) = sv_newmortal();
      sv_setpv((SV*)ST(argvi++),(char *) $1);";



/* References to primitive types.  Return by value */

%typemap(out) const int &, 
              const short &,
              const long &,
              const signed char &,
              const bool &,
              const enum SWIGTYPE &
      "ST(argvi) = sv_newmortal();
       sv_setiv(ST(argvi++), (IV) *($1));";

%typemap(out) const unsigned int &,
              const unsigned short &,
              const unsigned long &,
              const unsigned char &
      "ST(argvi) = sv_newmortal();
       sv_setuv(ST(argvi++), (UV) *($1));";

%typemap(out) const float &, const double & 
      "ST(argvi) = sv_newmortal();
       sv_setnv(ST(argvi++), (double) *($1));";

%typemap(out) const long long & {
  char temp[256];
  sprintf(temp,"%lld", (long long)*($1));
  ST(argvi) = sv_newmortal();
  sv_setpv((SV*)ST(argvi++), temp);
}

%typemap(out) const unsigned long long & {
  char temp[256];
  sprintf(temp,"%llu", (unsigned long long)*($1));
  ST(argvi) = sv_newmortal();
  sv_setpv((SV*)ST(argvi++), temp);
}

%typemap(out) const char &
  "ST(argvi) = sv_newmortal();
   sv_setpvn((SV*)ST(argvi++), $1, 1);";


/* Variable input */

%typemap(varin)  int, short, long, signed char
       "$1 = ($1_ltype) SvIV($input);";

%typemap(varin)  bool
       "$1 = SvIV($input) ? true : false;";

%typemap(varin) unsigned int, unsigned short, unsigned long, unsigned char
	"$1 = ($1_ltype) SvUV($input);";

%typemap(varin)  char
       "$1 = ($1_ltype) *SvPV($input,PL_na);";

%typemap(varin)  float, double 
       "$1 = ($1_ltype) SvNV($input);\n";

%typemap(varin)  long long "$1 = ($1_ltype) strtoll(SvPV($input, PL_na), 0, 0);";
%typemap(varin)  unsigned long long "$1 = ($1_ltype) strtoull(SvPV($input, PL_na), 0, 0);";

%typemap(varin) SWIGTYPE * {
        void *temp;
        if (SWIG_ConvertPtr($input, &temp, $1_descriptor,0) < 0) {
            croak("Type error in argument $argnum of $symname. Expected $1_mangle");
        }
        $1 = ($1_ltype) temp;
}

%typemap(varin) SWIGTYPE [ANY] {
	int  i;
        $1_basetype *temp;
        $1_basetype *b = ($1_basetype *) $1;
        if (SWIG_ConvertPtr($input, (void **) &temp, $1_descriptor,0) < 0) {
            croak("Type error in argument $argnum of $symname. Expected $1_mangle");
        }
        for (i = 0; i < $1_size; i++) b[i] = temp[i];
}

%typemap(varin,warning="462:Unable to set dimensionless array variable") SWIGTYPE []
{
  croak("C/C++ variable '$name' is read-only");
}

%typemap(varin) SWIGTYPE & {
        void *temp;
        if (SWIG_ConvertPtr($input, &temp, $1_descriptor,0) < 0) {
            croak("Type error in argument $argnum of $symname. Expected $1_mangle");
        }
        $1 = *($1_ltype) temp;
}

%typemap(varin) void * {
        void *temp;
	if (SWIG_ConvertPtr($input, &temp, 0,0) < 0) {
            croak("Type error in argument $argnum of $symname. Expected $1_mangle");
        }
	$1 = temp;
}

/* Object passed by value. Convert to a pointer */
%typemap(varin) SWIGTYPE {
    $&1_ltype temp;
    if (SWIG_ConvertPtr($input,(void **) &temp, $&1_descriptor,0) < 0) {
            croak("Type error in argument $argnum of $symname. Expected $&1_mangle");
    }
    $1 = *temp;
}

/* Member pointer */
%typemap(varin) SWIGTYPE (CLASS::*) {
  char temp[sizeof($1_type)];
  if (SWIG_ConvertPacked($input, (void *) temp, sizeof($1_type), $1_descriptor, 0) < 0) {
            croak("Type error in argument $argnum of $symname. Expected $&1_mangle");
  }
  memmove((void *) &$1, temp, sizeof($1_type));
}

/* Const primitive references.  Passed by value */

%typemap(varin) const int & (int temp),
	     const short & (short temp),
             const long  & (long temp),
             const signed char & (signed char temp),
             const enum SWIGTYPE & ($*1_ltype temp)
	"temp = ($*1_ltype) SvIV($input);
         $1 = &temp;";

%typemap(varin) const bool & (bool temp)
	"temp = SvIV($input) ? true : false;
         $1 = &temp;";

%typemap(varin) const unsigned int & (unsigned int temp),
             const unsigned short & (unsigned short temp),
             const unsigned long & (unsigned long temp),
             const unsigned char & (unsigned char temp)
	"temp = ($*1_ltype) SvUV($input);
         $1 = &temp;";

%typemap(varin) const float & (float temp),
	     const double & (double temp)
	"temp = ($*1_ltype) SvNV($input);
         $1 = &temp;";

%typemap(varin) const long long & ($*1_ltype temp) 
        "temp = ($1_ltype) strtoll(SvPV($input,PL_na),0,0);
         $1 = &temp;";

%typemap(varin) const unsigned long long & ($*1_ltype temp) 
        "temp = ($1_ltype) strtoull(SvPV($input, PL_na),0,0);
         $1 = &temp;";

%typemap(varin) const char &(char temp) {
        temp = *SvPV($input,PL_na);
        $1 = &temp;
}

%typemap(varin) char *
#ifdef __cplusplus
{
  char *_a = (char *) SvPV(sv,PL_na);
  if ($1) delete [] $1;
  $1 = new char[strlen(_a)+1];
  strcpy((char *)$1,_a);
}
#else
{
  char *_a = (char *) SvPV(sv,PL_na);
  if ($1) free((char *) $1);
  $1 = (char *) malloc(strlen(_a)+1);
  strcpy((char *)$1,_a);
}
#endif

%typemap(varin,warning="451:Setting const char * variable may leak memory") const char *
#ifdef __cplusplus
{
  char *_a = (char *) SvPV(sv,PL_na);
  $1 = new char[strlen(_a)+1];
  strcpy((char *)$1,_a);
}
#else
{
  char *_a = (char *) SvPV(sv,PL_na);
  $1 = (char *) malloc(strlen(_a)+1);
  strcpy((char *)$1,_a);
}
#endif

%typemap(varin) char [ANY]
     "strncpy($1, (char *) SvPV(sv,PL_na), $1_dim0);";

%typemap(varin,warning="462: Unable to set variable of type char []") char []
     { croak("Variable $symname is read-only."); }

%typemap(varin)  enum SWIGTYPE {
  if (sizeof(int) != sizeof($1)) {
    croak("enum variable '$name' can not be set.");
  }
  *(int *)(void *)&($1) = SvIV($input);
}

/* --- Typemaps for variable output --- */

%typemap(varout) int, short, long, signed char,  bool, enum SWIGTYPE 
    "sv_setiv($result, (IV) $1);";

%typemap(varout) unsigned int, unsigned short, unsigned long, unsigned char
    "sv_setuv($result, (UV) $1);";

%typemap(varout) float, double
    "sv_setnv($result, (double) $1);";

%typemap(varout) char 
    "sv_setpvn((SV *) $result, &$1, 1);";

%typemap(varout) long long {
  char temp[256];
  sprintf(temp,"%lld",(long long)$1);
  sv_setpv((SV *) $result, temp);
}

%typemap(varout) unsigned long long {
  char temp[256];
  sprintf(temp,"%llu",(unsigned long long)$1);
  sv_setpv((SV *) $result, temp);
}

%typemap(varout) char *, char [ANY]
    "if ($1) {
        sv_setpv((SV*)$result, (char *) $1);
     } else {
        sv_setsv((SV*)$result, &PL_sv_undef);
     }";

//%typemap(varout) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] 
//    "SWIG_MakePtr($result, (void *) $1, $1_descriptor);";

%typemap(varout,type="$1_descriptor") SWIGTYPE *, SWIGTYPE []  
    "sv_setiv(SvRV($result),(IV) $1);"; 

%typemap(varout,type="$1_descriptor") SWIGTYPE &
    "sv_setiv(SvRV($result),(IV) &$1);"; 

//%typemap(varout) SWIGTYPE
//    "SWIG_MakePtr($result, (void *) &$1, $&1_descriptor);";

%typemap(varout,type="$&1_descriptor") SWIGTYPE
    "sv_setiv(SvRV($result), (IV) &$1);";

%typemap(varout,type="$1_descriptor") SWIGTYPE (CLASS::*) {
  SWIG_MakePackedObj($result, (void *) &$1, sizeof($1_type), $1_descriptor);
}

/* --- Typemaps for constants --- *

/* --- Constants --- */

%typemap(consttab) int, unsigned int, short, unsigned short, long, unsigned long, unsigned char, signed char, bool, enum SWIGTYPE
       { SWIG_INT,     (char *) SWIG_prefix "$symname", (long) $value, 0, 0, 0}

%typemap(consttab) float, double
       { SWIG_FLOAT,   (char *) SWIG_prefix "$symname", 0, (double) $value, 0, 0}

%typemap(consttab) char, char *
       { SWIG_STRING,  (char *) SWIG_prefix "$symname", 0, 0, (void *)$value, 0}

%typemap(consttab) long long, unsigned long long
       { SWIG_STRING, (char *) SWIG_prefix "$symname", 0, 0, (void *) "$value", 0}

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
       { SWIG_POINTER, (char *) SWIG_prefix "$symname", 0, 0, (void *)$value, &$1_descriptor}

%typemap(consttab) SWIGTYPE (CLASS::*) 
       { SWIG_BINARY,  (char *) SWIG_prefix "$symname", sizeof($type), 0, (void *)&$value, &$1_descriptor}


/* ------------------------------------------------------------
 * String & length
 * ------------------------------------------------------------ */

%typemap(in) (char *STRING, int LENGTH) {
    STRLEN temp;
    $1 = ($1_ltype) SvPV($input,temp);
    $2 = ($2_ltype) temp;
}

/* ------------------------------------------------------------
 * ANSI C typemaps
 * ------------------------------------------------------------ */

%apply unsigned long { size_t };

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_INTEGER)
	int, short, long,
 	unsigned int, unsigned short, unsigned long,
	signed char, unsigned char,
	long long, unsigned long long,
	const int &, const short &, const long &,
	const unsigned int &, const unsigned short &, const unsigned long &,
	const long long &, const unsigned long long &,
	enum SWIGTYPE, const enum SWIGTYPE &,
	bool, const bool & 
{
  $1 = SvIOK($input) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_DOUBLE)
	float, double,
	const float &, const double &
{
  $1 = SvNIOK($input) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_CHAR) char {
  $1 = SvPOK($input) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  $1 = SvPOK($input) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
  void *tmp;
  if (SWIG_ConvertPtr($input, (void **) &tmp, $1_descriptor, 0) == -1) {
	$1 = 0;
  } else {
        $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE {
  void *tmp;
  if (SWIG_ConvertPtr($input, (void **) &tmp, $&1_descriptor, 0) == -1) {
	$1 = 0;
  } else {
        $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_VOIDPTR) void * {
  void *tmp;
  if (SWIG_ConvertPtr($input, (void **) &tmp, 0, 0) == -1) {
	$1 = 0;
  } else {
        $1 = 1;
  }
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
  SWIG_SetErrorf("%d", $1); SWIG_fail;
}

/* throws real objects */
%typemap(throws) SWIGTYPE 
{
  SV *esv=sv_newmortal();
  $&1_ltype copy = new $1_ltype(($1_ltype &)$1);
  SWIG_MakePtr(esv, (void *) copy,
	       $&1_descriptor, SWIG_OWNER);
  SWIG_croakSV(esv);
}

%typemap(throws) SWIGTYPE, SWIGTYPE &, SWIGTYPE *, SWIGTYPE [ANY] %{
  (void)$1;
  SWIG_croak("C++ $1_type exception thrown");
%}

%typemap(throws) enum SWIGTYPE %{
  (void)$1;
  SWIG_croak("C++ $1_type exception thrown");
%}

%typemap(throws) char * {
  SWIG_croak($1);
}

%include "perlinit.swg"
