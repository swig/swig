/* -----------------------------------------------------------------------------
 * tcl8.swg
 *
 * Tcl8 configuration module.
 * ----------------------------------------------------------------------------- */

%runtime "swigrun.swg"       // Common C API type-checking code
%runtime "swigtcl8.swg"

/* -----------------------------------------------------------------------------
 *                     --- standard typemaps ---
 * ----------------------------------------------------------------------------- */

/* Input arguments */

/* For primitive types, the Tcl module uses a special function

   SWIG_GetArgs(Tcl_Interp *, int objc, Tcl_Obj *CONST objv[], const char *fmt, ...)

   The fmt field contains special conversion characters i,h,l,b,f,d,c,p, and o
   that are used to marshal different types.   The parse codes below correspond
   to these special codes */

%typemap(in,parse="i") int, unsigned int "";
%typemap(in,parse="h") short, unsigned short "";
%typemap(in,parse="l") long, unsigned long "";
%typemap(in,parse="b") signed char, unsigned char "";
%typemap(in,parse="f") float "";
%typemap(in,parse="d") double "";
%typemap(in,parse="c") char "";
%typemap(in,parse="s") char *, char [ANY] "";

/* Pointers */
%typemap(in) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] 
  "if ((SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor,SWIG_POINTER_EXCEPTION | $disown) != TCL_OK)) SWIG_fail;";

%typemap(in) void *
  "if ((SWIG_ConvertPtr($input, (void **) &$1, 0,SWIG_POINTER_EXCEPTION | $disown) != TCL_OK)) SWIG_fail;";

/* For bools, we first convert to an integer and then to a bool.  There
   is no guarantee that a bool is the same size as an int so we have to do this */

%typemap(in) bool (int tempb) "if (Tcl_GetIntFromObj(interp,$input,&tempb) == TCL_ERROR) SWIG_fail;
                               $1 = tempb ? true : false;";

/* These will pass an integer as an unsigned long.  However, the implementation is crippled due
   to limited precision in Tcl */

%typemap(in) long long "$1 = ($1_ltype) strtoll(Tcl_GetStringFromObj($input,NULL),0,0);";
%typemap(in) unsigned long long "$1 = ($1_ltype) strtoull(Tcl_GetStringFromObj($input,NULL), 0, 0);";

/* Enum parsing.  Note: internally SWIG converts enums to/from integers so it's okay to use
   the "i" parse code here */

%typemap(in,parse="i") enum SWIGTYPE "";

/* Unknown type.  We convert from a pointer */
%typemap(in) SWIGTYPE ($&1_ltype argp) 
  "if ((SWIG_ConvertPtr($input, (void **) &argp, $&1_descriptor,SWIG_POINTER_EXCEPTION ) != TCL_OK)) SWIG_fail;
  $1 = *argp; ";

/* Member pointer */
%typemap(in) SWIGTYPE (CLASS::*) "if ((SWIG_ConvertPacked($input, (void *) &$1, sizeof($1_type), $1_descriptor, SWIG_POINTER_EXCEPTION)) != TCL_OK) SWIG_fail;";

/* Special constant variations.   These typemaps can be used to parse objects that are both constants
   or values. A Hash table lookup will occur. */

%typemap(in,parse="I") int CONSTANT, unsigned int CONSTANT "";
%typemap(in,parse="H") short CONSTANT, unsigned short CONSTANT "";
%typemap(in,parse="L") long CONSTANT, unsigned long CONSTANT "";
%typemap(in,parse="B") signed char CONSTANT, unsigned char CONSTANT "";
%typemap(in,parse="F") float CONSTANT "";
%typemap(in,parse="D") double CONSTANT "";
%typemap(in,parse="C") char CONSTANT "";
%typemap(in,parse="S") char * CONSTANT "";
%typemap(in,parse="P") SWIGTYPE *CONSTANT, SWIGTYPE &CONSTANT, SWIGTYPE CONSTANT [] "";
%typemap(in,parse="I") enum SWIGTYPE CONSTANT "";

/* Constant references. Passed by value */
/* Const primitive references.  Passed by value */

%typemap(in) const int & ($*1_ltype temp),
	     const short & ($*1_ltype temp),
             const long  & ($*1_ltype temp),
             const unsigned int & ($*1_ltype temp),
             const unsigned short & ($*1_ltype temp),
             const unsigned long & ($*1_ltype temp),
             const signed char & ($*1_ltype temp),
             const unsigned char & ($*1_ltype temp),
             const enum SWIGTYPE & ($*1_ltype temp)
{
  long ltemp;
  if (Tcl_GetLongFromObj(interp, $input, &ltemp) != TCL_OK) {
    SWIG_fail;
  }
  temp = ($*1_ltype) ltemp;
  $1 = &temp;
}

%typemap(in) const bool & (bool temp)
{
  long ltemp;
  if (Tcl_GetLongFromObj(interp, $input, &ltemp) != TCL_OK) {
    SWIG_fail;
  }
  temp = ltemp ? true : false;
  $1 = &temp;
}


%typemap(in) const float & (float temp),
	     const double & (double temp)
{
  double dtemp;
  if (Tcl_GetDoubleFromObj(interp, $input, &dtemp) != TCL_OK) {
    SWIG_fail;
  }
  temp = ($*1_ltype) dtemp;
  $1 = &temp;
}

%typemap(in) const long long & ($*1_ltype temp) 
     "temp = ($*1_ltype) strtoll(Tcl_GetStringFromObj($input,NULL),0,0);
      $1 = &temp;";

%typemap(in) const unsigned long long & ($*1_ltype temp) 
        "temp = ($*1_ltype) strtoull(Tcl_GetStringFromObj($input,NULL),0,0);
         $1 = &temp;";

%typemap(in) const char &(char temp) {
        char *stemp = Tcl_GetStringFromObj($input,NULL);
        temp = *stemp;
        $1 = &temp;
}

/* Output values */

%typemap(out) bool, int, unsigned int, short, unsigned short, long, unsigned long, signed char, unsigned char, enum SWIGTYPE
     "Tcl_SetObjResult(interp,Tcl_NewIntObj((long) $1));";

%typemap(out) long long {
  char temp[256]; 
  sprintf(temp,"%lld", (long long) $1);
  Tcl_SetObjResult(interp,Tcl_NewStringObj(temp,-1));
}

%typemap(out) unsigned long long {
  char temp[256]; 
  sprintf(temp,"%llu", (unsigned long long) $1);
  Tcl_SetObjResult(interp,Tcl_NewStringObj(temp,-1));
}

%typemap(out) char 
     "Tcl_SetObjResult(interp,Tcl_NewStringObj(&$1,1));";

%typemap(out) float, double
     "Tcl_SetObjResult(interp,Tcl_NewDoubleObj((double) $1));";

%typemap(out) char *
     "Tcl_SetObjResult(interp,Tcl_NewStringObj($1,-1));";

%typemap(out) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] 
     "Tcl_SetObjResult(interp,SWIG_NewPointerObj((void *) $1, $1_descriptor,0));";

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
     swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor,(void **) &$1);
     Tcl_SetObjResult(interp,SWIG_NewPointerObj((void *) $1, ty,0));
}

%typemap(out) SWIGTYPE *INSTANCE, SWIGTYPE &INSTANCE, SWIGTYPE INSTANCE[]
     "Tcl_SetObjResult(interp,SWIG_NewInstanceObj((void *) $1, $1_descriptor,0));";

%typemap(out) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
     "Tcl_SetObjResult(interp,SWIG_NewInstanceObj((void *) $1, $1_descriptor,0));";

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
     swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor,(void **) &$1);
     Tcl_SetObjResult(interp,SWIG_NewInstanceObj((void *) $1, ty,0));
}

%typemap(out) SWIGTYPE (CLASS::*) 
    "Tcl_SetObjResult(interp, SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor, 0));";

%typemap(out) void "";

/* Primitive types--return by value */
%typemap(out) SWIGTYPE NOINSTANCE
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype(($1_ltype &) $1);
  Tcl_SetObjResult(interp,SWIG_NewPointerObj((void*) resultptr, $&1_descriptor,0));
}
#else
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  Tcl_SetObjResult(interp,SWIG_NewPointerObj((void*) resultptr, $&1_descriptor,0));
}
#endif

/* Primitive types--return by value */
%typemap(out) SWIGTYPE INSTANCE
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype(($1_ltype &) $1);
  Tcl_SetObjResult(interp,SWIG_NewInstanceObj((void*) resultptr, $&1_descriptor,1));
}
#else
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  Tcl_SetObjResult(interp,SWIG_NewInstanceObj((void*) resultptr, $&1_descriptor,1));
}
#endif

%typemap(out) SWIGTYPE = SWIGTYPE INSTANCE;

/* Special typemap for character array returns */
%typemap(out) char [ANY] "Tcl_SetObjResult(interp,Tcl_NewStringObj($1,-1));"


/* Primitive references */

%typemap(out) const int &, const unsigned int &,
              const short &, const unsigned short &,
              const long &, const unsigned long &,
              const signed char &, const unsigned char &,
              const bool &,
              const enum SWIGTYPE &
    "Tcl_SetObjResult(interp,Tcl_NewIntObj((long) *($1)));";

%typemap(out) const float &, const double & 
    "Tcl_SetObjResult(interp,Tcl_NewDoubleObj((double) *($1)));";

%typemap(out) const long long & {
  char temp[256];
  sprintf(temp,"%lld", (long long)*($1));
  Tcl_SetObjResult(interp,Tcl_NewStringObj(temp,-1));
}

%typemap(out) const unsigned long long &
{
  char temp[256];
  sprintf(temp,"%llu", (unsigned long long)*($1));
  Tcl_SetObjResult(interp,Tcl_NewStringObj(temp,-1));
}

%typemap(out) const char &
   "Tcl_SetObjResult(interp,Tcl_NewStringObj($1,1));";


/* --- Variable output --- */

%typemap(varout) int, unsigned int, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE 
    "$result = Tcl_NewIntObj((long) $1);";

%typemap(varout) long long {
      char temp[256]; 
      sprintf(temp,"%lld", (long long)$1);
      $result = Tcl_NewStringObj(temp,-1);
}

%typemap(varout) unsigned long long {
      char temp[256];
      sprintf(temp,"%llu", (unsigned long long)$1);
      $result = Tcl_NewStringObj(temp,-1);
}

%typemap(varout) double,float "$result = Tcl_NewDoubleObj((double) $1);";
%typemap(varout) char * "$result = Tcl_NewStringObj((char*) $1,-1);";
%typemap(varout) char [ANY] "$result = Tcl_NewStringObj((char *) $1,-1);";
%typemap(varout) char "$result = Tcl_NewStringObj(&$1,1);";
%typemap(varout) SWIGTYPE *, SWIGTYPE []  "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor,0);";
%typemap(varout) SWIGTYPE & "$result = SWIG_NewPointerObj((void *) &$1, $1_descriptor,0);";

%typemap(varout) SWIGTYPE *INSTANCE, SWIGTYPE INSTANCE[]
    "$result = SWIG_NewInstanceObj((void *) $1, $1_descriptor,0);";

%typemap(varout) SWIGTYPE &INSTANCE
    "$result = SWIG_NewInstanceObj((void *) &$1, $1_descriptor,0);";

%typemap(varout) SWIGTYPE INSTANCE "$result = SWIG_NewInstanceObj((void *) &$1, $&1_descriptor,0);";
%typemap(varout) SWIGTYPE "$result = SWIG_NewInstanceObj((void *) &$1, $&1_descriptor,0);";
%typemap(varout) SWIGTYPE (CLASS::*) "$result = SWIG_NewPackedObj((void *) &$1, sizeof($1_type), $1_descriptor, 0);";

/* -- Variable input --- */

%typemap(varin) int, unsigned int, short, unsigned short, long, unsigned long, signed char, unsigned char
{
  long temp;
  if (Tcl_GetLongFromObj(interp, $input, &temp) != TCL_OK) {
    return (char*) "Type error. expected an integer";
  }
  $1 = ($1_type) temp;
}

%typemap(varin) enum SWIGTYPE
{
  int temp;
  if (Tcl_GetIntFromObj(interp, $input, &temp) != TCL_OK) {
    return (char*) "Type error. expected an integer";
  }
  if (sizeof(int) != sizeof($1)) {
    return (char*) "enum variable '$name' can not be set.";
  }
  *(int *)(void *)&($1) = temp;
}

%typemap(varin) bool
{
  long temp;
  if (Tcl_GetLongFromObj(interp, $input, &temp) != TCL_OK) {
    return (char*) "Type error. expected an integer";
  }
  $1 = temp ? true : false;
}

%typemap(varin) long long "$1 = ($1_ltype) strtoll(Tcl_GetStringFromObj($input,NULL),0,0);";
%typemap(varin) unsigned long long "$1 = ($1_ltype) strtoull(Tcl_GetStringFromObj($input,NULL),0,0);";

%typemap(varin) double, float {
  double temp;
  if (Tcl_GetDoubleFromObj(interp, $input, &temp) != TCL_OK) {
    return (char*) "Type error. expected a double.";
  }
  $1 = ($1_type) temp;
}

%typemap(varin) char *
#ifdef __cplusplus
{
  char  *temp = Tcl_GetStringFromObj($input,NULL);
  if ($1) delete [] $1;
  $1 = ($1_type) new char[strlen(temp)+1];
  strcpy((char *) $1,temp);
}
#else
{
  char  *temp = Tcl_GetStringFromObj($input,NULL);
  if ($1) free((char*)$1);
  $1 = ($1_type) malloc(strlen(temp)+1);
  strcpy((char *) $1,temp);
}
#endif

%typemap(varin,warning="451:Setting const char * variable may leak memory") const char *
#ifdef __cplusplus
{
  char  *temp = Tcl_GetStringFromObj($input,NULL);
  $1 = ($1_type) new char[strlen(temp)+1];
  strcpy((char *) $1,temp);
}
#else
{
  char  *temp = Tcl_GetStringFromObj($input,NULL);
  $1 = ($1_type) malloc(strlen(temp)+1);
  strcpy((char *) $1,temp);
}
#endif

%typemap(varin) char [ANY] {
  char *temp = Tcl_GetStringFromObj($input,NULL);
  strncpy((char*)$1,temp,$1_dim0);
}

%typemap(varin,warning="462: Unable to set variable of type char []") char [] {
  return (char*)"Variable $symname is read-only.";
}

%typemap(varin) char 
{
  char *temp = Tcl_GetStringFromObj($input,NULL);
  $1 = *temp;
}

%typemap(varin) SWIGTYPE * {
  if (SWIG_ConvertPtr($input,(void **)&$1,$1_descriptor, SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN) != TCL_OK) {
    return (char*)"Type error. Expected $1_ltype";
  }
}

%typemap(varin,warning="462: Unable to set dimensionless array variable") SWIGTYPE [] {
  return (char*)"Variable $symname is read-only.";
}

%typemap(varin) void * {
  void *temp;
  if (SWIG_ConvertPtr($input,&temp,0, SWIG_POINTER_EXCEPTION | SWIG_POINTER_DISOWN) != TCL_OK) {
    return (char*)"Type error. Expected $1_ltype";
  }
  $1 = ($1_type) temp;
}

%typemap(varin) SWIGTYPE & {
  void *temp;
  if (SWIG_ConvertPtr($input,&temp,$1_descriptor, SWIG_POINTER_EXCEPTION) != TCL_OK) {
    return (char*)"Type error. Expected $1_ltype";
  }
  $1 = *($1_ltype) temp;
}

%typemap(varin) SWIGTYPE {
  void *temp;
  if (SWIG_ConvertPtr($input,&temp,$&1_descriptor, SWIG_POINTER_EXCEPTION) != TCL_OK) {
    return (char*)"Type error. Expected $&1_ltype";
  }
  $1 = *(($&1_type) temp);
}

%typemap(varin) SWIGTYPE [ANY] {
   void *temp;
   if (SWIG_ConvertPtr($input,&temp,$1_descriptor, SWIG_POINTER_EXCEPTION) != TCL_OK) {
      return (char *)"Type error. Expected $1_ltype";
   }
   memmove((void *) $1,temp,$1_size*sizeof($1_basetype));
}

%typemap(varin) SWIGTYPE (CLASS::*) {
   char  temp[sizeof($1_type)];
   if (SWIG_ConvertPacked($input, temp, sizeof($1_type), $1_descriptor, SWIG_POINTER_EXCEPTION) != TCL_OK) {
       return (char *) "Type error. Expected $1_ltype";
   }
   memmove((void *) &$1, temp, sizeof($1_type));
}
   
/* --- Constants --- */

%typemap(consttab) int, unsigned int, short, unsigned short, long, unsigned long, unsigned char, signed char, bool, enum SWIGTYPE
       { SWIG_TCL_INT,     (char *)"$nsname", (long) $value, 0, 0, 0}

%typemap(consttab) float, double
       { SWIG_TCL_FLOAT,   (char*)"$nsname", 0, (double) $value, 0, 0}

%typemap(consttab) char, char *
       { SWIG_TCL_STRING,  (char*)"$nsname", 0, 0, (void *)"$value", 0}

%typemap(consttab) long long, unsigned long long 
       { SWIG_TCL_STRING, (char *) "$nsname", 0, 0, (void *)"$value", 0}

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
       { SWIG_TCL_POINTER, (char*)"$nsname", 0, 0, (void *)$value, &$1_descriptor}

%typemap(consttab) SWIGTYPE (CLASS::*) 
       { SWIG_TCL_BINARY,  (char *)"$nsname", sizeof($type), 0, (void *)&$value, &$1_descriptor}




/* ------------------------------------------------------------
 * String & length
 * ------------------------------------------------------------ */

%typemap(in) (char *STRING, int LENGTH) {
    int temp;
    $1 = ($1_ltype) Tcl_GetStringFromObj($input,&temp);
    $2 = ($2_ltype) temp;
}

/* ------------------------------------------------------------
 * ANSI C typemaps 
 * ------------------------------------------------------------ */

%types(size_t);
%apply unsigned long { size_t };
%apply const unsigned long& { const size_t& };

%types(ptrdiff_t);
%apply long { ptrdiff_t };
%apply const long& { const ptrdiff_t& };


/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(SWIG_TYPECHECK_INTEGER)
	 int, short, long,
 	 unsigned int, unsigned short, unsigned long,
	 signed char, unsigned char,
	 const int &, const short &, const long &,
 	 const unsigned int &, const unsigned short &, const unsigned long &,
	 enum SWIGTYPE, const enum SWIGTYPE &,
	 bool, const bool & 
{
  long tmp;
  if (Tcl_GetLongFromObj(NULL,$input,&tmp) == TCL_ERROR) $1 = 0;
  else $1 = 1;
}

%typecheck(SWIG_TYPECHECK_INTEGER)
	 long long, unsigned long long,
	 const long long &, const unsigned long long &
{
  Tcl_WideInt tmp;
  if (Tcl_GetWideIntFromObj(NULL,$input,&tmp) == TCL_ERROR) $1 = 0;
  else $1 = 1;
}

%typecheck(SWIG_TYPECHECK_DOUBLE)
	float, double,
	const float &, const double &
{
  double tmp;
  if (Tcl_GetDoubleFromObj(NULL,$input,&tmp) == TCL_ERROR) $1 = 0;
  else $1 = 1;
}

%typecheck(SWIG_TYPECHECK_CHAR) char {
  char *tmp;
  int   len;
  tmp = Tcl_GetStringFromObj($input,&len);
  $1 = (len == 1) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  $1 = 1;
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
  void *ptr;
  if (SWIG_ConvertPtr($input, (void **) &ptr, $1_descriptor, 0) == TCL_ERROR) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE {
  void *ptr;
  if (SWIG_ConvertPtr($input, (void **) &ptr, $&1_descriptor, 0) == TCL_ERROR) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(SWIG_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  if (SWIG_ConvertPtr($input, (void **) &ptr, 0, 0) == TCL_ERROR) {
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
  Tcl_SetObjResult(interp, Tcl_NewIntObj((long) $1));
  SWIG_fail;
}

%typemap(throws) SWIGTYPE CLASS {
  $&1_ltype temp = new $1_ltype($1);
  Tcl_SetObjResult(interp, SWIG_NewInstanceObj((void *) temp, $&1_descriptor, 1));
  SWIG_fail;
}

%typemap(throws) SWIGTYPE {
  Tcl_SetObjResult(interp, Tcl_NewStringObj((char*) "$1_type", -1));
  SWIG_fail;
}

%typemap(throws) SWIGTYPE, SWIGTYPE &, SWIGTYPE *, SWIGTYPE [ANY] {
  Tcl_SetObjResult(interp, Tcl_NewStringObj((char*) "$1_type", -1));
  SWIG_fail;
}

%typemap(throws) enum SWIGTYPE {
  Tcl_SetObjResult(interp, Tcl_NewStringObj((char*) "$1_type", -1));
  SWIG_fail;
}

%typemap(throws) char * {
  Tcl_SetObjResult(interp, Tcl_NewStringObj((char*) $1, -1));
  SWIG_fail;
}

// Some special reserved words in classes
%include "tcl8kw.swg"

/* C++ overloaded operators.

   These declarations define how SWIG is going to rename C++
   overloaded operators in Tcl.  Since Tcl allows identifiers
   to be essentially any valid string, we'll just use the
   normal operator names */

#ifdef __cplusplus
%rename("+")         *::operator+;
//%rename("u+")        *::operator+();     // Unary +
//%rename("u+")        *::operator+() const;     // Unary +
%rename("-")         *::operator-;
//%rename("u-")        *::operator-();     // Unary -
//%rename("u-")        *::operator-() const;     // Unary -
%rename("*")         *::operator*;
%rename("/")         *::operator/;
%rename("<<")        *::operator<<;
%rename(">>")        *::operator>>;
%rename("&")         *::operator&;
%rename("|")         *::operator|;
%rename("^")         *::operator^;
%rename("%")         *::operator%;
%rename("=")         *::operator=;
#endif


/* This initialization code exports the module initialization function */

%header %{

#ifdef __cplusplus
extern "C" {
#endif
#ifdef MAC_TCL
#pragma export on
#endif
SWIGEXPORT int SWIG_init(Tcl_Interp *);
#ifdef MAC_TCL
#pragma export off
#endif
#ifdef __cplusplus
}
#endif

%}

/* Start the initialization function */

%insert(init) "swiginit.swg"

%init %{
SWIGEXPORT int SWIG_init(Tcl_Interp *interp) {
    int i;
    if (interp == 0) return TCL_ERROR;
#ifdef USE_TCL_STUBS
    if (Tcl_InitStubs(interp, (char*)"8.1", 0) == NULL) {
      return TCL_ERROR;
    }
#endif

    Tcl_PkgProvide(interp, (char*)SWIG_name, (char*)SWIG_version);

#ifdef SWIG_namespace
    Tcl_Eval(interp, "namespace eval " SWIG_namespace " { }");
#endif

    SWIG_InitializeModule((void *) interp);
    SWIG_PropagateClientData();

    for (i = 0; swig_commands[i].name; i++) {
      Tcl_CreateObjCommand(interp, (char *) swig_commands[i].name, (swig_wrapper_func) swig_commands[i].wrapper, swig_commands[i].clientdata, NULL);
    }
    for (i = 0; swig_variables[i].name; i++) {
      Tcl_SetVar(interp, (char *) swig_variables[i].name, (char *) "", TCL_GLOBAL_ONLY);
      Tcl_TraceVar(interp, (char *) swig_variables[i].name, TCL_TRACE_READS | TCL_GLOBAL_ONLY, (Tcl_VarTraceProc *) swig_variables[i].get, (ClientData) swig_variables[i].addr);
      Tcl_TraceVar(interp, (char *) swig_variables[i].name, TCL_TRACE_WRITES | TCL_GLOBAL_ONLY, (Tcl_VarTraceProc *) swig_variables[i].set, (ClientData) swig_variables[i].addr);
    }
    SWIG_InstallConstants(interp, swig_constants);
%}

/* Note: the initialization function is closed after all code is generated */
