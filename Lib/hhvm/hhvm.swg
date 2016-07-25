/* -----------------------------------------------------------------------------
 * hhvm.swg
 *
 * HHVM configuration file
 * ----------------------------------------------------------------------------- */
%runtime "swigrun.swg"  // Common C API type-checking code
%runtime "hhvmrun.swg" // PHP runtime functions

%typemap(consttab) int,
                   unsigned int,
                   short,
                   unsigned short,
                   long,
                   unsigned long,
                   enum SWIGTYPE
  "KindOfInt64";

%typemap(consttab) bool
  "KindOfBoolean";

%typemap(consttab) float,
                   double
  "KindOfDouble";

%typemap(consttab) char *,
                   char,
                   unsigned char,
                   signed char,
                   const char *,
                   char [ANY],
                   char [],
                   const char []
  "KindOfPersistentString";

/* hni_parmtype typemaps */

%typemap(hni_parmtype) int,
                  unsigned int,
                  short,
                  unsigned short,
                  long,
                  unsigned long,
                  enum SWIGTYPE
  "int64_t";

%typemap(hni_parmtype) bool
  "bool";

%typemap(hni_parmtype) float,
                  double
  "double";

%typemap(hni_parmtype)  char *,
                   char,
                   const char *,
                   unsigned char,
                   signed char,
                   char [ANY],
                   char [],
                   const char []
  "const HPHP::String&";

%typemap(hni_parmtype)  SWIGTYPE *,
                        SWIGTYPE []
  "const HPHP::Resource&";                        

%typemap(hni_parmtype)  SWIGTYPE &,
                        SWIGTYPE &&
  "HPHP::VRefParam";

%typemap(hni_parmtype) SWIGTYPE
  "const HPHP::Object&";

/* hni_rttype typemaps */

%typemap(hni_rttype) int,
                  unsigned int,
                  short,
                  unsigned short,
                  long,
                  unsigned long,
                  enum SWIGTYPE
  "int64_t";

%typemap(hni_rttype) bool
  "bool";

%typemap(hni_rttype) float,
                  double
  "double";

%typemap(hni_rttype)  char *,
                   char,
                   const char *,
                   unsigned char,
                   signed char,
                   char [ANY],
                   char [],
                   const char []
  "HPHP::String";

%typemap(hni_rttype) void
  "void";

%typemap(hni_rttype)  SWIGTYPE *,
                      SWIGTYPE []
 "HPHP::Resource";

%typemap(hni_rttype)  SWIGTYPE &,
                      SWIGTYPE &&
  "HPHP::Variant";

%typemap(hni_rttype) SWIGTYPE
  "HPHP::Object";

/* in typemap */

%typemap(in) short, 
             unsigned short, 
             int, 
             unsigned int, 
             long, 
             unsigned long, 
             long long, 
             unsigned long long, 
             float, 
             double,
             enum SWIGTYPE
%{ $1 = ($1_ltype)$input; %}

%typemap(in) char, 
             signed char, 
             unsigned char 
{
  if ($input.length() != 1) {
    throw std::runtime_error("Expecting a string of length 1.\n");
  }
  $1 = $input[0];
}

%typemap(in) char *, 
             char [ANY],
             char []
%{$1 = (char *)$input.c_str();%}

%typemap(in)  SWIGTYPE *,
              SWIGTYPE []
%{ $1 = HPHP::dyn_cast_or_null<HPHP::SWIG_Ptr<$*1_ltype>>($input)->get(); %}

%typemap(in)  SWIGTYPE &,
              SWIGTYPE &&
%{
  auto Res$1 = HPHP::Native::data<_wrap_$*1_ltype>($input.toObject())->_obj_ptr;
  $1 = HPHP::dyn_cast_or_null<HPHP::SWIG_Ptr<$*1_ltype>>(Res$1)->get();
%}

%typemap(in) SWIGTYPE
%{
  auto Res$1 = HPHP::Native::data<_wrap_$1_ltype>($input)->_obj_ptr;
  $1 = *(HPHP::dyn_cast_or_null<HPHP::SWIG_Ptr<$1_ltype>>(Res$1)->get());
%} 

/* out typemaps */

%typemap(out) int,
              unsigned int,
              short,
              unsigned short,
              long,
              unsigned long, 
              enum SWIGTYPE
  "$result = $1;"

%typemap(out) bool
  "$result = $1;"

%typemap(out) float,
              double
  "$result = $1;"

%typemap(out) char *,
              char,
              signed char,
              unsigned char,
              const char *,
              char [ANY],
              char [],
              const char []
  "$result = HPHP::String($1, HPHP::CopyString);"

%typemap(out) void ""

%typemap(out) SWIGTYPE *,
              SWIGTYPE []
%{ $result = HPHP::Resource(HPHP::req::make<HPHP::SWIG_Ptr<$*1_ltype>>($1)); %}              

%typemap(out) SWIGTYPE &,
              SWIGTYPE &&
%{
  auto $1_cls = HPHP::Unit::lookupClass(HPHP::makeStaticString("$*1_ltype"));
  $result = HPHP::Object($1_cls);
  auto wrap_$1 = HPHP::Native::data<_wrap_$*1_ltype>($result.toObject());
  wrap_$1->_obj_ptr = HPHP::Resource(HPHP::req::make<HPHP::SWIG_Ptr<$*1_ltype>>($1));
  wrap_$1->isRef = true;
%} 

%typemap(out) SWIGTYPE
%{
  auto cls = HPHP::Unit::lookupClass(HPHP::makeStaticString("$1_ltype"));
  $result = HPHP::Object(cls);
  auto wrap_$1 = HPHP::Native::data<_wrap_$1_ltype>($result);
  auto ptr_$1 = new $1_ltype((const $1_ltype &) $1);
  wrap_$1->_obj_ptr = HPHP::Resource(HPHP::req::make<HPHP::SWIG_Ptr<$1_ltype>>(ptr_$1));
%} 

/* Ref for basic types */
%define as_ref(TYPE)
%typemap(in)  TYPE &,
              TYPE &&
%{
  $*1_ltype ref$1 = ($*1_ltype)$input;
  $1 = &ref$1;
%}

%typemap(out) TYPE &,
              TYPE &&
%{$result = ($1_ltype)$1;%} 

%typemap(argout) TYPE &,
                 TYPE &&
%{$result.assignIfRef(*$1);%}
%enddef
as_ref(short); 
as_ref(unsigned short); 
as_ref(int); 
as_ref(unsigned int); 
as_ref(long); 
as_ref(unsigned long); 
as_ref(long long); 
as_ref(unsigned long long); 
as_ref(float); 
as_ref(double);
as_ref(enum SWIGTYPE)

/* php types */

%typemap(php_type)  int,
                    unsigned int,
                    short,
                    unsigned short,
                    long,
                    unsigned long,
                    unsigned char,
                    signed char,
                    enum SWIGTYPE
  "int";

%typemap(php_type) bool
  "bool";

%typemap(php_type)  float,
                    double
  "float";

%typemap(php_type) char *,
                   char,
                   const char *,
                   char [ANY],
                   char [],
                   const char []
  "string";

%typemap(php_type) void
  "void";

%typemap(php_type)  SWIGTYPE *,
                    SWIGTYPE []
  "resource"

%typemap(php_type)  SWIGTYPE &,
                    SWIGTYPE &&
  "mixed&";

%typemap(php_type) SWIGTYPE
  "object"; 

%typecheck(SWIG_TYPECHECK_INTEGER, noblock = 1)
  int, short, long,
  unsigned int, unsigned short, unsigned long,
  signed char, unsigned char,
  long long, unsigned long long,
  const int &, const short &, const long &,
  const unsigned int &, const unsigned short &, const unsigned long &,
  const long long &, const unsigned long long &,
  enum SWIGTYPE
  {
    int64_t $result;
    _v = $input.isInteger();
    if (_v) $result = $input.toInt64Val();
  }

%typecheck(SWIG_TYPECHECK_DOUBLE, noblock = 1)
  float, double,
  const float &, const double &
  {
    double $result;
    _v = $input.isDouble();
    if (_v) $result = $input.toDouble();
  }

%typecheck(SWIG_TYPECHECK_CHAR, noblock = 1) char 
  {
    HPHP::String $result;
    _v = ($input.isString() && $input.toString().length() == 1);
    if (_v) $result = $input.toString();
  }

%typecheck(SWIG_TYPECHECK_STRING, noblock = 1) char * 
  {
    HPHP::String $result;
    _v = $input.isString();
    if (_v) $result = $input.toString();
  }

%typecheck(SWIG_TYPECHECK_BOOL, noblock = 1)
bool, const bool &
  {
    bool $result;
    _v = $input.isBoolean();
    if (_v) $result = $input.toBoolean();
  }

%typecheck(SWIG_TYPECHECK_POINTER, noblock = 1)
  SWIGTYPE *,
  SWIGTYPE []
  {
    HPHP::Resource $result;
    _v = $input.isResource();
    if (_v) $result = $input.toResource();
  }
 
%typemap(variant_out) int,
                  unsigned int,
                  short,
                  unsigned short,
                  long,
                  unsigned long,
                  enum SWIGTYPE
  "toInt64Val";

%typemap(variant_out) bool
  "toBooleanVal";

%typemap(variant_out) float,
                  double
  "toDoubleVal";

%typemap(variant_out)  char *,
                   char,
                   const char *,
                   unsigned char,
                   signed char,
                   char [ANY],
                   char [],
                   const char []
  "toString";

%typemap(variant_out) SWIGTYPE
  "toObject";

%typemap(variant_out) SWIGTYPE *,
                      SWIGTYPE []
  "toResource";                    