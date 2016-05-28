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