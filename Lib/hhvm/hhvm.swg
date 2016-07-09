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
                   unsigned long
                   // enum SWIGTYPE
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
                   char [],
                   const char []
  "KindOfPersistentString";

/* hni_parmtype typemaps */

%typemap(hni_parmtype) int,
                  unsigned int,
                  short,
                  unsigned short,
                  long,
                  unsigned long
                  // enum SWIGTYPE
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
                   char [],
                   const char []
  "const HPHP::String&";

%typemap(hni_parmtype)  SWIGTYPE *,
                        SWIGTYPE [],
                        SWIGTYPE &,
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
                  unsigned long
                  // enum SWIGTYPE
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
                   char [],
                   const char []
  "HPHP::String";

%typemap(hni_rttype) void
  "void";

%typemap(hni_rttype)  SWIGTYPE *,
                      SWIGTYPE [],
                      SWIGTYPE &,
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
             double
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

%typemap(in)  SWIGTYPE *,
              SWIGTYPE [],
              SWIGTYPE &,
              SWIGTYPE &&
%{$1 = HPHP::Native::data<_wrap_$*1_ltype>($input.toObject())->_obj_ptr;%}

%typemap(in) SWIGTYPE
%{$1 = *(HPHP::Native::data<_wrap_$1_ltype>($input)->_obj_ptr);%} 

/* out typemaps */

%typemap(out) int,
              unsigned int,
              short,
              unsigned short,
              long,
              unsigned long 
              // enum SWIGTYPE
  "$result = $1;"

%typemap(out) bool
  "$result = $1;"

%typemap(out) float,
              double
  "$result = $1;"

%typemap(out) char *,
              char,
              const char *,
              char [],
              const char []
  "$result = HPHP::makeStaticString($1);"

%typemap(out) void ""

%typemap(out) SWIGTYPE *,
              SWIGTYPE [],
              SWIGTYPE &,
              SWIGTYPE &&
%{
  auto cls = HPHP::Unit::lookupClass(HPHP::makeStaticString("_wrap_$*1_ltype"));
  $result = HPHP::Object(HPHP::ObjectData::newInstance(cls));
  HPHP::TypedValue dummy;
  HPHP::g_context->invokeFunc(&dummy, cls->getCtor(), HPHP::Array::Create(), $result.get());
  auto wrap_$1 = HPHP::Native::data<_wrap_$*1_ltype>($result);
  wrap_$1->_obj_ptr = $1;
%} 

%typemap(out) SWIGTYPE
%{
  auto cls = HPHP::Unit::lookupClass(HPHP::makeStaticString("_wrap_$1_ltype"));
  auto data = (HPHP::ObjectData::newInstance(cls));
  $result = HPHP::Object(data);
  data->incRefCount();
  auto wrap_$1 = HPHP::Native::data<_wrap_$1_ltype>($result);
  wrap_$1->_obj_ptr = new $1_ltype((const $1_ltype &) $1);
%} 

/* php types */

%typemap(php_type)  int,
                    unsigned int,
                    short,
                    unsigned short,
                    long,
                    unsigned long,
                    unsigned char,
                    signed char
                    // enum SWIGTYPE
  "int";

%typemap(php_type) bool
  "bool";

%typemap(php_type)  float,
                    double
  "float";

%typemap(php_type) char *,
                   char,
                   const char *,
                   char [],
                   const char []
  "string";

%typemap(php_type) void
  "void";

%typemap(php_type)  SWIGTYPE *,
                    SWIGTYPE [],
                    SWIGTYPE &,
                    SWIGTYPE &&
  "mixed&";

%typemap(php_type) SWIGTYPE
  "object";

%typemap(argout) SWIGTYPE &,
                 SWIGTYPE &&
%{//$result.assignIfRef(*$1);%} 


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