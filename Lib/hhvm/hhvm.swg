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
                   unsigned long,
                   unsigned char,
                   signed char
                   // enum SWIGTYPE
  "KindOfInt64";

%typemap(consttab) bool
  "KindOfBoolean";

%typemap(consttab) float,
                   double
  "KindOfDouble";

%typemap(consttab) char *,
                   char,
                   const char *,
                   char [],
                   const char []
  "KindOfPersistentString";

%typemap(in)  int,
                    unsigned int,
                    short,
                    unsigned short,
                    long,
                    unsigned long,
                    unsigned char,
                    signed char
                    // enum SWIGTYPE
  "int64_t";

%typemap(in) bool
  "bool";

%typemap(in)  float,
              double
  "double";

%typemap(in) char *,
                   char,
                   const char *,
                   char [],
                   const char []
  "const String&";

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