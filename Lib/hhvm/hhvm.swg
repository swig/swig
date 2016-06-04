/* -----------------------------------------------------------------------------
 * hhvm.swg
 *
 * HHVM configuration file
 * ----------------------------------------------------------------------------- */

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

/* hni_type typemaps */

%typemap(hni_type) int,
                  unsigned int,
                  short,
                  unsigned short,
                  long,
                  unsigned long
                  // enum SWIGTYPE
  "int64_t";

%typemap(hni_type) bool
  "bool";

%typemap(hni_type) float,
                  double
  "double";

%typemap(hni_type)  char *,
                   char,
                   const char *,
                   unsigned char,
                   signed char,
                   char [],
                   const char []
  "const String&";

%typemap(hni_type) void
  "void";

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
  "$result = makeStaticString($1);"

%typemap(out) void ""

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

%typecheck(SWIG_TYPECHECK_INTEGER)
  int, short, long,
  unsigned int, unsigned short, unsigned long,
  signed char, unsigned char,
  long long, unsigned long long,
  const int &, const short &, const long &,
  const unsigned int &, const unsigned short &, const unsigned long &,
  const long long &, const unsigned long long &,
  enum SWIGTYPE
  "int64_t $result;\n _v = $input.isInteger();\n if (_v) $result = $input.toInt64Val();\n"

%typecheck(SWIG_TYPECHECK_DOUBLE)
  float, double,
  const float &, const double &
  "double $result;\n _v = $input.isDouble();\n if (_v) $result = $input.toDouble();\n"

%typecheck(SWIG_TYPECHECK_CHAR) char 
  "String $result;\n _v = ($input.isString() && $input.toString().length() == 1);\n if (_v) $result = $input.toString();\n"

%typecheck(SWIG_TYPECHECK_STRING) char * 
  "String $result;\n _v = $input.isString();\n if (_v) $result = $input.toString();\n"

%typecheck(SWIG_TYPECHECK_BOOL)
bool, const bool &
  "bool $result;\n _v = $input.isBoolean();\n if (_v) $result = $input.toBoolean();\n"