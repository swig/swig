/* -----------------------------------------------------------------------------
 * rust.swg
 *
 * Rust support library.
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
%}

%fragment("SWIG_PackData", "header") {
SWIGINTERN char *SWIG_PackData(char *c, void *ptr, size_t sz) {
  static const char hex[17] = "0123456789abcdef";
  const unsigned char *u = (unsigned char *)ptr;
  const unsigned char *eu = u + sz;
  for (; u != eu; ++u) {
    unsigned char uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}
}

%fragment("SWIG_UnPackData", "header") {
SWIGINTERN const char *SWIG_UnpackData(const char *c, void *ptr, size_t sz) {
  unsigned char *u = (unsigned char *)ptr;
  const unsigned char *eu = u + sz;
  for (; u != eu; ++u) {
    char d = *(c++);
    unsigned char uu;
    if ((d >= '0') && (d <= '9'))
      uu = (unsigned char)((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = (unsigned char)((d - ('a' - 10)) << 4);
    else
      return (char *)0;
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (unsigned char)(d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (unsigned char)(d - ('a' - 10));
    else
      return (char *)0;
    *u = uu;
  }
  return c;
}
}

/* Primitive director C ABI types. These mirror the C# director typemap
   structure, but use Rust's libc-compatible primitive names in rust.cxx. */
%typemap(ctype) bool,               const bool &               "bool"
%typemap(ctype) char,               const char &               "char"
%typemap(ctype) signed char,        const signed char &        "signed char"
%typemap(ctype) unsigned char,      const unsigned char &      "unsigned char"
%typemap(ctype) short,              const short &              "short"
%typemap(ctype) unsigned short,     const unsigned short &     "unsigned short"
%typemap(ctype) int,                const int &                "int"
%typemap(ctype) unsigned int,       const unsigned int &       "unsigned int"
%typemap(ctype) long,               const long &               "long"
%typemap(ctype) unsigned long,      const unsigned long &      "unsigned long"
%typemap(ctype) long long,          const long long &          "long long"
%typemap(ctype) unsigned long long, const unsigned long long & "unsigned long long"
%typemap(ctype) float,              const float &              "float"
%typemap(ctype) double,             const double &             "double"
%typemap(ctype) void                                           "void"
%typemap(ctype) size_t,             const size_t &             "size_t"
%typemap(ctype) ptrdiff_t,          const ptrdiff_t &          "ptrdiff_t"

%typemap(ctype) char *, char *&, char[ANY], char[] "char *"
%typemap(ctype) SWIGTYPE                           "void *"
%typemap(ctype) SWIGTYPE []                        "void *"
%typemap(ctype) SWIGTYPE *                         "void *"
%typemap(ctype) SWIGTYPE &                         "void *"
%typemap(ctype) SWIGTYPE &&                        "void *"
%typemap(ctype) SWIGTYPE (CLASS::*)                "char *"
%typemap(ctype) SWIGTYPE *const&                   "void *"

%typemap(imtype) bool,               const bool &               "bool"
%typemap(imtype) char,               const char &               "c_char"
%typemap(imtype) signed char,        const signed char &        "c_schar"
%typemap(imtype) unsigned char,      const unsigned char &      "c_uchar"
%typemap(imtype) short,              const short &              "c_short"
%typemap(imtype) unsigned short,     const unsigned short &     "c_ushort"
%typemap(imtype) int,                const int &                "c_int"
%typemap(imtype) unsigned int,       const unsigned int &       "c_uint"
%typemap(imtype) long,               const long &               "c_long"
%typemap(imtype) unsigned long,      const unsigned long &      "c_ulong"
%typemap(imtype) long long,          const long long &          "c_longlong"
%typemap(imtype) unsigned long long, const unsigned long long & "c_ulonglong"
%typemap(imtype) float,              const float &              "c_float"
%typemap(imtype) double,             const double &             "c_double"
%typemap(imtype) void                                           "()"
%typemap(imtype) size_t,             const size_t &             "usize"
%typemap(imtype) ptrdiff_t,          const ptrdiff_t &          "isize"

%typemap(imtype) char *, char *&, char[ANY], char[] "*mut c_char"
%typemap(imtype) SWIGTYPE                           "*mut c_void"
%typemap(imtype) SWIGTYPE []                        "*mut c_void"
%typemap(imtype) SWIGTYPE *                         "*mut c_void"
%typemap(imtype) SWIGTYPE &                         "*mut c_void"
%typemap(imtype) SWIGTYPE &&                        "*mut c_void"
%typemap(imtype) SWIGTYPE (CLASS::*)                "*mut c_char"
%typemap(imtype) SWIGTYPE *const&                   "*mut c_void"

%typemap(rusttype) bool,               const bool &               "bool"
%typemap(rusttype) char,               const char &               "c_char"
%typemap(rusttype) signed char,        const signed char &        "c_schar"
%typemap(rusttype) unsigned char,      const unsigned char &      "c_uchar"
%typemap(rusttype) short,              const short &              "c_short"
%typemap(rusttype) unsigned short,     const unsigned short &     "c_ushort"
%typemap(rusttype) int,                const int &                "c_int"
%typemap(rusttype) unsigned int,       const unsigned int &       "c_uint"
%typemap(rusttype) long,               const long &               "c_long"
%typemap(rusttype) unsigned long,      const unsigned long &      "c_ulong"
%typemap(rusttype) long long,          const long long &          "c_longlong"
%typemap(rusttype) unsigned long long, const unsigned long long & "c_ulonglong"
%typemap(rusttype) float,              const float &              "c_float"
%typemap(rusttype) double,             const double &             "c_double"
%typemap(rusttype) void                                           "()"
%typemap(rusttype) size_t,             const size_t &             "usize"
%typemap(rusttype) ptrdiff_t,          const ptrdiff_t &          "isize"

%typemap(rusttype) char *, char *&, char[ANY], char[] "*mut c_char"
%typemap(rusttype) SWIGTYPE                           "*mut c_void"
%typemap(rusttype) SWIGTYPE []                        "*mut c_void"
%typemap(rusttype) SWIGTYPE *                         "*mut c_void"
%typemap(rusttype) SWIGTYPE &                         "*mut c_void"
%typemap(rusttype) SWIGTYPE &&                        "*mut c_void"
%typemap(rusttype) SWIGTYPE (CLASS::*)                "*mut c_char"
%typemap(rusttype) SWIGTYPE *const&                   "*mut c_void"

%typemap(in) bool
%{ $1 = $input ? true : false; %}

%typemap(in) char,
             signed char,
             unsigned char,
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
             size_t,
             ptrdiff_t
%{ $1 = ($1_ltype)$input; %}

%typemap(in) const bool & ($*1_ltype temp)
%{ temp = $input ? true : false;
   $1 = &temp; %}

%typemap(in) const char & ($*1_ltype temp),
             const signed char & ($*1_ltype temp),
             const unsigned char & ($*1_ltype temp),
             const short & ($*1_ltype temp),
             const unsigned short & ($*1_ltype temp),
             const int & ($*1_ltype temp),
             const unsigned int & ($*1_ltype temp),
             const long & ($*1_ltype temp),
             const unsigned long & ($*1_ltype temp),
             const long long & ($*1_ltype temp),
             const unsigned long long & ($*1_ltype temp),
             const float & ($*1_ltype temp),
             const double & ($*1_ltype temp),
             const size_t & ($*1_ltype temp),
             const ptrdiff_t & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input;
   $1 = &temp; %}

%typemap(in) char *, char *&, char[ANY], char[] %{ $1 = ($1_ltype)$input; %}
%typemap(in) SWIGTYPE ($&1_type argp)
%{ argp = ($&1_ltype)$input;
   $1 = *argp; %}
%typemap(in, fragment="SWIG_UnPackData") SWIGTYPE (CLASS::*)
%{ SWIG_UnpackData($input, (void *)&$1, sizeof($1)); %}
%typemap(in) SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE *const& %{ $1 = ($1_ltype)$input; %}

%typemap(out) bool               %{ $result = $1; %}
%typemap(out) char               %{ $result = $1; %}
%typemap(out) signed char        %{ $result = $1; %}
%typemap(out) unsigned char      %{ $result = $1; %}
%typemap(out) short              %{ $result = $1; %}
%typemap(out) unsigned short     %{ $result = $1; %}
%typemap(out) int                %{ $result = $1; %}
%typemap(out) unsigned int       %{ $result = $1; %}
%typemap(out) long               %{ $result = $1; %}
%typemap(out) unsigned long      %{ $result = $1; %}
%typemap(out) long long          %{ $result = $1; %}
%typemap(out) unsigned long long %{ $result = $1; %}
%typemap(out) float              %{ $result = $1; %}
%typemap(out) double             %{ $result = $1; %}
%typemap(out) size_t             %{ $result = $1; %}
%typemap(out) ptrdiff_t          %{ $result = $1; %}
%typemap(out) const bool &       %{ $result = *$1; %}
%typemap(out) const char &       %{ $result = *$1; %}
%typemap(out) const signed char & %{ $result = *$1; %}
%typemap(out) const unsigned char & %{ $result = *$1; %}
%typemap(out) const short &      %{ $result = *$1; %}
%typemap(out) const unsigned short & %{ $result = *$1; %}
%typemap(out) const int &        %{ $result = *$1; %}
%typemap(out) const unsigned int & %{ $result = *$1; %}
%typemap(out) const long &       %{ $result = *$1; %}
%typemap(out) const unsigned long & %{ $result = *$1; %}
%typemap(out) const long long &  %{ $result = *$1; %}
%typemap(out) const unsigned long long & %{ $result = *$1; %}
%typemap(out) const float &      %{ $result = *$1; %}
%typemap(out) const double &     %{ $result = *$1; %}
%typemap(out) const size_t &     %{ $result = *$1; %}
%typemap(out) const ptrdiff_t &  %{ $result = *$1; %}
%typemap(out, null="") void      ""
%typemap(out) char *, char *&, char[ANY], char[] %{ $result = (char *)$1; %}
%typemap(out) SWIGTYPE %{ $result = new $1_ltype($1); %}
%typemap(out, fragment="SWIG_PackData") SWIGTYPE (CLASS::*)
%{ $result = (char *)malloc(2 * sizeof($1) + 1);
   *(SWIG_PackData($result, (void *)&$1, sizeof($1))) = '\0'; %}
%typemap(out) SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE *const& %{ $result = (void *)$1; %}

%typemap(rustin) bool,
                 char,
                 signed char,
                 unsigned char,
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
                 size_t,
                 ptrdiff_t,
                 char *,
                 char *&,
                 char[ANY],
                 char[],
                 SWIGTYPE,
                 SWIGTYPE *,
                 SWIGTYPE &,
                 SWIGTYPE &&,
                 SWIGTYPE [],
                 SWIGTYPE *const& "$rustinput"

%typemap(rustout) bool,
                  char,
                  signed char,
                  unsigned char,
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
                  size_t,
                  ptrdiff_t,
                  char *,
                  char *&,
                  char[ANY],
                  char[],
                  SWIGTYPE,
                  SWIGTYPE *,
                  SWIGTYPE &,
                  SWIGTYPE &&,
                  SWIGTYPE [],
                  SWIGTYPE *const& "$imcall"
%typemap(rustout) void "$imcall;"

%typemap(rustvarin) bool,
                    char,
                    signed char,
                    unsigned char,
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
                    size_t,
                    ptrdiff_t,
                    char *,
                    char *&,
                    char[ANY],
                    char[],
                    SWIGTYPE,
                    SWIGTYPE *,
                    SWIGTYPE &,
                    SWIGTYPE &&,
                    SWIGTYPE [],
                    SWIGTYPE *const& "$imcall;"

%typemap(rustvarout) bool,
                     char,
                     signed char,
                     unsigned char,
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
                     size_t,
                     ptrdiff_t,
                     char *,
                     char *&,
                     char[ANY],
                     char[],
                     SWIGTYPE,
                     SWIGTYPE *,
                     SWIGTYPE &,
                     SWIGTYPE &&,
                     SWIGTYPE [],
                     SWIGTYPE *const& "$imcall"

%typemap(rustdirectorin) bool,
                         char,
                         signed char,
                         unsigned char,
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
                         size_t,
                         ptrdiff_t,
                         char *,
                         char *&,
                         char[ANY],
                         char[],
                         SWIGTYPE,
                         SWIGTYPE *,
                         SWIGTYPE &,
                         SWIGTYPE &&,
                         SWIGTYPE [],
                         SWIGTYPE *const& "$iminput"

%typemap(rustdirectorout) bool,
                         char,
                         signed char,
                         unsigned char,
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
                         size_t,
                         ptrdiff_t,
                         char *,
                         char *&,
                         char[ANY],
                         char[],
                         SWIGTYPE,
                         SWIGTYPE *,
                         SWIGTYPE &,
                         SWIGTYPE &&,
                         SWIGTYPE [],
                         SWIGTYPE *const& "$rustcall"

%typemap(rustattributes) SWIGTYPE ""
%typemap(rustderive) SWIGTYPE ""
%typemap(rustbody) SWIGTYPE ""
%typemap(rusttraits) SWIGTYPE ""
%typemap(rustdrop) SWIGTYPE ""

/* Rust keywords */
%include <rustkw.swg>

/* Default enum handling */
%include <enums.swg>

%typemap(directorin) bool               "$input = $1;"
%typemap(directorin) char               "$input = $1;"
%typemap(directorin) signed char        "$input = $1;"
%typemap(directorin) unsigned char      "$input = $1;"
%typemap(directorin) short              "$input = $1;"
%typemap(directorin) unsigned short     "$input = $1;"
%typemap(directorin) int                "$input = $1;"
%typemap(directorin) unsigned int       "$input = $1;"
%typemap(directorin) long               "$input = $1;"
%typemap(directorin) unsigned long      "$input = $1;"
%typemap(directorin) long long          "$input = $1;"
%typemap(directorin) unsigned long long "$input = $1;"
%typemap(directorin) float              "$input = $1;"
%typemap(directorin) double             "$input = $1;"
%typemap(directorin) size_t             "$input = $1;"
%typemap(directorin) ptrdiff_t          "$input = $1;"

%typemap(directorin) const bool &           "$input = $1;"
%typemap(directorin) const char &           "$input = $1;"
%typemap(directorin) const signed char &    "$input = $1;"
%typemap(directorin) const unsigned char &  "$input = $1;"
%typemap(directorin) const short &          "$input = $1;"
%typemap(directorin) const unsigned short & "$input = $1;"
%typemap(directorin) const int &            "$input = $1;"
%typemap(directorin) const unsigned int &   "$input = $1;"
%typemap(directorin) const long &           "$input = $1;"
%typemap(directorin) const unsigned long &  "$input = $1;"
%typemap(directorin) const long long &      "$input = $1;"
%typemap(directorin) const unsigned long long & "$input = $1;"
%typemap(directorin) const float &          "$input = $1;"
%typemap(directorin) const double &         "$input = $1;"
%typemap(directorin) const size_t &         "$input = $1;"
%typemap(directorin) const ptrdiff_t &      "$input = $1;"

%typemap(directorin) char *, char *&, char[ANY], char[] "$input = (char *)$1;"
%typemap(directorin) SWIGTYPE                  "$input = (void *)new $1_ltype(SWIG_STD_MOVE($1));"
%typemap(directorin) SWIGTYPE *, SWIGTYPE (CLASS::*) "$input = (void *)$1;"
%typemap(directorin) SWIGTYPE &, SWIGTYPE &&   "$input = (void *)&$1;"
%typemap(directorin) SWIGTYPE *const&          "$input = (void *)$1;"
%typemap(directorin) void                      ""

%typemap(directorout) bool
%{ $result = $input ? true : false; %}

%typemap(directorout) char,
             signed char,
             unsigned char,
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
             size_t,
             ptrdiff_t
%{ $result = ($1_ltype)$input; %}

%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const bool &
%{ static $*1_ltype temp;
   temp = $input ? true : false;
   $result = &temp; %}

%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const char &,
             const signed char &,
             const unsigned char &,
             const short &,
             const unsigned short &,
             const int &,
             const unsigned int &,
             const long &,
             const unsigned long &,
             const long long &,
             const unsigned long long &,
             const float &,
             const double &,
             const size_t &,
             const ptrdiff_t &
%{ static $*1_ltype temp;
   temp = ($*1_ltype)$input;
   $result = &temp; %}

%typemap(directorout) char *, char[ANY], char[] %{ $result = ($1_ltype)$input; %}
%typemap(directorout) SWIGTYPE
%{ if (!$input) {
     Swig::DirectorTypeMismatchException::raise("Unexpected null return for type $1_type");
   }
   $result = *($&1_ltype)$input; %}
%typemap(directorout) SWIGTYPE *, SWIGTYPE (CLASS::*) %{ $result = ($1_ltype)$input; %}
%typemap(directorout) SWIGTYPE &, SWIGTYPE &&
%{ if (!$input) {
     Swig::DirectorTypeMismatchException::raise("Unexpected null return for type $1_type");
   }
   $result = ($1_ltype)$input; %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) SWIGTYPE *const&
%{ static $*1_ltype temp = 0;
   temp = ($*1_ltype)$input;
   $result = &temp; %}

%typemap(directorargout) bool,
             char,
             signed char,
             unsigned char,
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
             size_t,
             ptrdiff_t,
             SWIGTYPE,
             SWIGTYPE *,
             SWIGTYPE &,
             SWIGTYPE &&,
             SWIGTYPE *const& ""
