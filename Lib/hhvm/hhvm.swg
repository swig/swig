/* -----------------------------------------------------------------------------
 * hhvm.swg
 *
 * HHVM configuration file
 * ----------------------------------------------------------------------------- */

%runtime "hhvmrun.swg" // runtime functions

/* Fragments */
%fragment("SWIG_PackData", "header") {
/* Pack binary data into a string */
SWIGINTERN char * SWIG_PackData(char *c, void *ptr, size_t sz) {
  static const char hex[17] = "0123456789abcdef";
  const unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu =  u + sz;
  for (; u != eu; ++u) {
    unsigned char uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}
}

%fragment("SWIG_UnPackData", "header") {
/* Unpack binary data from a string */
SWIGINTERN const char * SWIG_UnpackData(const char *c, void *ptr, size_t sz) {
  unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu = u + sz;
  for (; u != eu; ++u) {
    char d = *(c++);
    unsigned char uu;
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    else 
      return (char *) 0;
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    else 
      return (char *) 0;
    *u = uu;
  }
  return c;
}
}

%typemap(consttab) int,
                   unsigned int,
                   short,
                   unsigned short,
                   long,
                   long long,
                   unsigned long long,
                   unsigned long,
                   unsigned char,
                   signed char,
                   enum SWIGTYPE
  "KindOfInt64";

%typemap(consttab) bool
  "KindOfBoolean";

%typemap(consttab) float,
                   double
  "KindOfDouble";

%typemap(consttab) char *,
                   char,
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
                  long long,
                  unsigned long long,
                  unsigned long,
                  unsigned char,
                  signed char,
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
                   char [ANY],
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
                  long long,
                  unsigned long long,
                  unsigned long,
                  unsigned char,
                  signed char,
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
                   char [ANY],
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

%typemap(in) bool,
             short, 
             unsigned short, 
             int, 
             unsigned int, 
             long, 
             unsigned long, 
             long long, 
             unsigned long long, 
             float, 
             double,
             unsigned char,
             signed char,
             enum SWIGTYPE
%{ $1 = ($1_ltype)$input; %}

%typemap(in) char
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
              SWIGTYPE [],
              SWIGTYPE &,
              SWIGTYPE &&
%{$1 = ($1_ltype)HPHP::Native::data<_wrap_$hhclassname>($input.toObject())->_obj_ptr;%}

%typemap(in) SWIGTYPE ($&1_type argp)
%{
  argp = ($&1_ltype)HPHP::Native::data<_wrap_$&hhclassname>($input)->_obj_ptr;
  $1 = *argp;
%} 

%typemap(in, fragment="SWIG_UnPackData") SWIGTYPE (CLASS::*) %{
  const char *temp = HPHP::Native::data<_wrap_$hhclassname>($input.toObject())->_obj_ptr.c_str(); 
  SWIG_UnpackData(temp, (void *)&$1, sizeof($1));
%}
/* out typemaps */

%typemap(out) int,
              unsigned int,
              short,
              unsigned short,
              long,
              long long,
              unsigned long long,
              unsigned long,
              unsigned char,
              signed char, 
              enum SWIGTYPE
  "$result = (int64_t)$1;"

%typemap(out) bool
  "$result = (bool)$1;"

%typemap(out) float,
              double
  "$result = (double)$1;"

%typemap(out) char
  "$result = HPHP::String::FromChar($1);"

%typemap(out) char *,
              const char *,
              char [ANY],
              char [],
              const char []
  "$result = HPHP::String($1, HPHP::CopyString);"

%typemap(out) void ""

%typemap(out) SWIGTYPE *,
              SWIGTYPE [],
              SWIGTYPE &,
              SWIGTYPE &&
%{
  $result = HPHP::Object(_wrap_$hhclassname::getClass());
  auto wrap_$1 = HPHP::Native::data<_wrap_$hhclassname>($result.toObject());
  wrap_$1->_obj_ptr = (void *)$1;
  wrap_$1->isRef = true;
%} 

%typemap(out, fragment="SWIG_PackData") SWIGTYPE (CLASS::*) %{
  auto cls = HPHP::Unit::lookupClass(HPHP::makeStaticString("$&hhclassname"));
  $result = HPHP::Object(cls);
  auto wrap_$1 = HPHP::Native::data<_wrap_$&hhclassname>($result.toObject());
  char buf[128];
  char *data = SWIG_PackData(buf, (void *)&$1, sizeof($1));
  *data = '\0';
  wrap_$1->_obj_ptr = HPHP::String::FromCStr(buf);
%}

%typemap(out) SWIGTYPE
%{
  auto cls = HPHP::Unit::lookupClass(HPHP::makeStaticString("$&hhclassname"));
  $result = HPHP::Object(cls);
  auto wrap_$1 = HPHP::Native::data<_wrap_$&hhclassname>($result);
  wrap_$1->_obj_ptr = new $1_ltype((const $1_ltype &) $1);
%} 

/* php types */

%typemap(php_type)  int,
                    unsigned int,
                    short,
                    unsigned short,
                    long,
                    long long,
                    unsigned long long,
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
                    SWIGTYPE [],
                    SWIGTYPE &,
                    SWIGTYPE &&
  "mixed&";

%typemap(php_type) SWIGTYPE
  "$&hhclassname";

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
    _v = $input.isInteger();
  }

%typecheck(SWIG_TYPECHECK_DOUBLE, noblock = 1)
  float, double,
  const float &, const double &
  {
    _v = $input.isDouble();
  }

%typecheck(SWIG_TYPECHECK_CHAR, noblock = 1) char 
  {
    _v = ($input.isString() && $input.toString().length() == 1);
  }

%typecheck(SWIG_TYPECHECK_STRING, noblock = 1) char * 
  {
    _v = $input.isString();
  }

%typecheck(SWIG_TYPECHECK_BOOL, noblock = 1)
bool, const bool &
  {
    _v = $input.isBoolean();
  }

%typecheck(SWIG_TYPECHECK_POINTER, noblock = 1)
  SWIGTYPE *,
  SWIGTYPE []
  {
    _v = $input.isObject();
  }
 
%typemap(variant_out) int,
                  unsigned int,
                  short,
                  unsigned short,
                  long,
                  long long,
                  unsigned long long,
                  unsigned long,
                  unsigned char,
                  signed char,
                  enum SWIGTYPE
  ".toInt64Val()";

%typemap(variant_out) bool
  ".toBooleanVal()";

%typemap(variant_out) float,
                  double
  ".toDoubleVal()";

%typemap(variant_out)  char *,
                   char,
                   const char *,
                   char [ANY],
                   char [],
                   const char []
  ".toString()";

%typemap(variant_out) SWIGTYPE
  ".toObject()";

%typemap(variant_out) SWIGTYPE *,
                      SWIGTYPE [],
                      SWIGTYPE &,
                      SWIGTYPE &&
  "";

%typemap(hhwrapclass) SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [] %{

class _wrap_$hhclassname {
public:
  static HPHP::Class* getClass();
  void sweep() {
    _obj_ptr = nullptr;
  }
  ~_wrap_$hhclassname() { sweep(); }

  static HPHP::Class* s_class;
  static const HPHP::StaticString s_className;
  void* _obj_ptr{nullptr};
  bool isRef{false};
};

HPHP::Class* _wrap_$hhclassname::s_class = nullptr;
const HPHP::StaticString _wrap_$hhclassname::s_className("$hhclassname");

IMPLEMENT_GET_CLASS(_wrap_$hhclassname)

%}

%typemap(hhwrapclass) SWIGTYPE (CLASS::*) %{

class _wrap_$hhclassname {
public:
  static HPHP::Class* getClass();
  void sweep() {
    _obj_ptr.clear();
  }
  ~_wrap_$hhclassname() { sweep(); }

  static HPHP::Class* s_class;
  static const HPHP::StaticString s_className;
  HPHP::String _obj_ptr;
  bool isRef{false};
};

HPHP::Class* _wrap_$hhclassname::s_class = nullptr;
const HPHP::StaticString _wrap_$hhclassname::s_className("$hhclassname");

IMPLEMENT_GET_CLASS(_wrap_$hhclassname)

%}                       