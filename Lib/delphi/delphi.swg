/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * delphi.swg
 *
 * delphi typemaps
 * ----------------------------------------------------------------------------- */

%include <delphihead.swg> 

/* The ctype, pasrawtype and paswraptype typemaps work together and so there should be one of each. 
 * The ctype typemap contains the C type used in the signature of C wrappers for C++ functions. 
 * The pasrawtype typemap contains the M3 type used in the raw interface.
 * The pasrawintype typemap contains the M3 type used as function argument.
 * The pasrawrettype typemap contains the M3 type used as return value.
 * The paswraptype typemap contains the M3 type used in the M3 type wrapper classes and module class. */

%typemap(ctype) bool,               const bool &               "bool"
%typemap(ctype) char,               const char &               "char"
%typemap(ctype) signed char,        const signed char &        "signed char"
%typemap(ctype) unsigned char,      const unsigned char &      "unsigned short"
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
%typemap(ctype) int64_t,            const int64_t &            "int64_t"
%typemap(ctype) uint32_t,           const uint32_t &           "uint32_t"
%typemap(ctype) size_t,             const size_t &             "size_t"
%typemap(ctype) char *                                         "char *"
%typemap(ctype) void                                           "void"


%typemap(pasrawtype, import="Classes, SysUtils" ) bool,               const bool &               "LongBool"
%typemap(pasrawtype) char,               const char &               "Char"
%typemap(pasrawtype) signed char,        const signed char &        "ShortInt"
%typemap(pasrawtype) unsigned char,      const unsigned char &      "Byte"
%typemap(pasrawtype) short,              const short &              "Smallint"
%typemap(pasrawtype) unsigned short,     const unsigned short &     "Word"
%typemap(pasrawtype) int,                const int &                "Integer"
%typemap(pasrawtype) unsigned int,       const unsigned int &       "Cardinal"
%typemap(pasrawtype) long,               const long &               "Longint"
%typemap(pasrawtype) unsigned long,      const unsigned long &      "Longword"
%typemap(pasrawtype) long long,          const long long &          "Int64"
%typemap(pasrawtype) int64_t  ,          const int64_t &            "NativeUInt"
%typemap(pasrawtype) uint32_t  ,         const uint32_t &           "NativeUInt"
%typemap(pasrawtype) size_t  ,           const size_t &             "NativeUInt"
%typemap(pasrawtype) unsigned long long, const unsigned long long & "Int64"
%typemap(pasrawtype) float,              const float &              "single"
%typemap(pasrawtype) double,             const double &             "Double"
%typemap(pasrawtype) long double,        const long double &        "Extended"
%typemap(pasrawtype) char *                                         "PChar"
%typemap(pasrawtype) void *                                         "Pointer"
%typemap(pasrawtype) void                                           ""
%typemap(pasrawtype) FILE *                                         "CFILE"

%typemap(pasrawintype)	                  bool &,               bool                 "LongBool"
%typemap(pasrawintype) bool *                                                         "PLongBool"

%typemap(pasrawintype)                       char &,               char               "Char"
%typemap(pasrawintype) char *														 "PChar"

%typemap(pasrawintype)						signed char &,        signed char        "ShortInt"
%typemap(pasrawintype) signed char *											         "PShortInt"

%typemap(pasrawintype)				       unsigned char &,      unsigned char      "Byte"
%typemap(pasrawintype) unsigned char *										         "PByte"


%typemap(pasrawintype)               short &,              short              "Smallint"
%typemap(pasrawintype) short *												"PSmallint"


%typemap(pasrawintype)                       unsigned short &,     unsigned short     "Word"
%typemap(pasrawintype) unsigned short *                                               "PWord"


%typemap(pasrawintype)                 int &,                int                "Integer"
%typemap(pasrawintype) int *               "PInteger"


%typemap(pasrawintype)       unsigned int &,       unsigned int       "Cardinal"
%typemap(pasrawintype) unsigned int *       "PCardinal"


%typemap(pasrawintype)                long &,               long               "Longword"
%typemap(pasrawintype) long *               "PLongword"


%typemap(pasrawintype) unsigned long &,      unsigned long      "Longint"
%typemap(pasrawintype) unsigned long * "PLongint"

%typemap(pasrawintype) long long &,          long long          "Int64"
%typemap(pasrawintype) long long * "PInt64"

%typemap(pasrawintype) unsigned long long &, unsigned long long "Int64"
%typemap(pasrawintype) unsigned long long * "PInt64"

%typemap(pasrawintype)               float &,              float              "single"
%typemap(pasrawintype) float *              "Psingle"

%typemap(pasrawintype)               int64_t &,              int64_t              "NativeUInt"
%typemap(pasrawintype) int64_t *              "PNativeUInt"

%typemap(pasrawintype)               uint32_t &,              uint32_t              "NativeUInt"
%typemap(pasrawintype) uint32_t *              "PNativeUInt"

%typemap(pasrawintype)               size_t &,              size_t              "NativeUInt"
%typemap(pasrawintype) size_t *              "PNativeUInt"


%typemap(pasrawintype)              double &,             double             "Double"
%typemap(pasrawintype)   double *     "PDouble"
//%typemap(pasrawinmode) double *   "var"
%typemap(pasrawinmode)   double &     "var"



%typemap(pasrawintype) long double &,        long double        "Extended"
%typemap(pasrawintype) long double *  "PExtended"


%typemap(pasrawintype) char *                                                         "PChar"
%typemap(pasrawintype) void                                                           ""
%typemap(pasrawintype) void *                                                         "Pointer"
%typemap(pasrawintype) FILE *                                                         "CFILE"


%typemap(pasrawinmode) char *, void *, FILE *  										 ""

%typemap(pasrawrettype) bool,               const bool &               "LongBool"

%typemap(pasrawrettype) char,               const char &               "Char"
%typemap(pasrawrettype) signed char,        const signed char &        "ShortInt"
%typemap(pasrawrettype) unsigned char,      const unsigned char &      "Byte"
%typemap(pasrawrettype) short,              const short &              "Smallint"
%typemap(pasrawrettype) unsigned short,     const unsigned short &     "Word"
%typemap(pasrawrettype) int,                const int &                "Integer"
%typemap(pasrawrettype) unsigned int,       const unsigned int &       "Cardinal"
%typemap(pasrawrettype) long,               const long &               "Longword"
%typemap(pasrawrettype) unsigned long,      const unsigned long &      "Longint"
%typemap(pasrawrettype) long long,          const long long &          "Int64"
%typemap(pasrawrettype) int64_t  ,          const int64_t &            "NativeUInt"
%typemap(pasrawrettype) uint32_t  ,          const uint32_t &            "NativeUInt"
%typemap(pasrawrettype) size_t  ,           const size_t &             "NativeUInt"
%typemap(pasrawrettype) unsigned long long, const unsigned long long & "Int64"
%typemap(pasrawrettype) float,              const float &              "single"
%typemap(pasrawrettype) double,             const double &             "Double"
%typemap(pasrawrettype) long double,        const long double &        "Extended"
%typemap(pasrawrettype) char *                                         "PChar"
%typemap(pasrawrettype) void                                           ""
%typemap(pasrawrettype) void *                                         "Pointer"
%typemap(pasrawrettype) FILE *                                         "CFILE"

%typemap(pasrawrettype) bool *                                         "PLongBool"
%typemap(pasrawrettype) signed char*                                   "PShortInt"
%typemap(pasrawrettype) const unsigned char &, unsigned char &         "PByte"
%typemap(pasrawrettype) unsigned char*                                 "PByte"
%typemap(pasrawrettype) short*                                         "PSmallint"
%typemap(pasrawrettype) unsigned short*                                "PWord"
%typemap(pasrawrettype) const unsigned short &, unsigned short &       "PWord"
%typemap(pasrawrettype) int*                                           "PInteger"
%typemap(pasrawrettype) const int &, int &           		           "PInteger"
%typemap(pasrawrettype) unsigned int*                                  "PCardinal"
%typemap(pasrawrettype) const unsigned int &, unsigned int &           "PCardinal"
%typemap(pasrawrettype) long*                                          "PLongword"
%typemap(pasrawrettype) const unsigned long &, unsigned long &         "PCardinal"

%typemap(pasrawrettype) unsigned long*                                 "PLongint"
%typemap(pasrawrettype) long long*                                     "PInt64"
%typemap(pasrawrettype) int64_t*                                       "PNativeUInt"
%typemap(pasrawrettype) const int64_t &, int64_t &                     "PNativeUInt"
%typemap(pasrawrettype) uint32_t*                                       "PNativeUInt"
%typemap(pasrawrettype) const uint32_t &, uint32_t &                     "PNativeUInt"
%typemap(pasrawrettype) size_t*                                        "PNativeUInt"
%typemap(pasrawrettype) const size_t &, size_t   &                     "PNativeUInt"
%typemap(pasrawrettype) unsigned long long*                            "PInt64"
%typemap(pasrawrettype) float*                                         "PSingle"
%typemap(pasrawrettype) double*                                        "PDouble"
%typemap(pasrawrettype) long double *                                  "Extended"


%typemap("pasrawtype:import")
  char,               const char &,
  signed char,        const signed char &,
  unsigned char,      const unsigned char &,
  short,              const short &,
  unsigned short,     const unsigned short &,
  int,                const int &,
  unsigned int,       const unsigned int &,
  long,               const long &,
  unsigned long,      const unsigned long &,
  long long,          const long long &,
  unsigned long long, const unsigned long long &,
  float,              const float &,
  int64_t,            const int64_t &,
  uint32_t,            const uint32_t &,
  size_t,             const size_t &,
  double,             const double &,
  long double,        const long double &,
  char *
    "Classes, SysUtils"

%typemap("pasrawintype:import")
  char,               const char &,
  signed char,        const signed char &,
  unsigned char,      const unsigned char &,
  short,              const short &,
  unsigned short,     const unsigned short &,
  int,                const int &,
  unsigned int,       const unsigned int &,
  long,               const long &,
  unsigned long,      const unsigned long &,
  long long,          const long long &,
  unsigned long long, const unsigned long long &,
  float,              const float &,
  int64_t,            const int64_t &,
  uint32_t,            const uint32_t &,
  size_t,             const size_t &,
  double,             const double &,
  long double,        const long double &,
  char *
    "Classes, SysUtils"

%typemap("pasrawrettype:import")
  char,               const char &,
  signed char,        const signed char &,
  unsigned char,      const unsigned char &,
  short,              const short &,
  unsigned short,     const unsigned short &,
  int,                const int &,
  unsigned int,       const unsigned int &,
  long,               const long &,
  unsigned long,      const unsigned long &,
  long long,          const long long &,
  unsigned long long, const unsigned long long &,
  float,              const float &,
  int64_t,            const int64_t &,
  uint32_t,            const uint32_t &,
  size_t,             const size_t &,
  double,             const double &,
  long double,        const long double &,
  char *
    "Classes, SysUtils"

%typemap(paswraptype) bool,               const bool &               "LongBool"
%typemap(paswraptype) char,               const char &               "Char"
%typemap(paswraptype) signed char,        const signed char &        "ShortInt"
%typemap(paswraptype) unsigned char,      const unsigned char &      "Byte"
%typemap(paswraptype) short,              const short &              "Smallint"
%typemap(paswraptype) unsigned short,     const unsigned short &     "Word"
%typemap(paswraptype) int,                const int &                "Integer"
%typemap(paswraptype) unsigned int,       const unsigned int &       "Cardinal"
%typemap(paswraptype) long,               const long &               "Longword"
%typemap(paswraptype) unsigned long,      const unsigned long &      "Longint"
%typemap(paswraptype) int64_t  ,          const int64_t &            "NativeUInt"
%typemap(paswraptype) uint32_t  ,          const uint32_t &            "NativeUInt"
%typemap(paswraptype) size_t  ,           const size_t &             "NativeUInt"
%typemap(paswraptype) long long,          const long long &          "Int64"
%typemap(paswraptype) unsigned long long, const unsigned long long & "Int64"
%typemap(paswraptype) float,              const float &              "single"
%typemap(paswraptype) double,             const double &             "Double"
%typemap(paswraptype) long double,        const long double &        "Extended"
%typemap(paswraptype) char *                                         "PChar"
%typemap(paswraptype) void                                           ""
%typemap(paswraptype) int &				  "PInteger"                                           ""


%typemap(paswrapintype) bool,               const bool *,               const bool &               "LongBool"
%typemap(paswrapintype) char,               const char *,               const char &               "Char"
%typemap(paswrapintype) signed char,        const signed char *,        const signed char &        "ShortInt"
%typemap(paswrapintype) unsigned char,      const unsigned char *,      const unsigned char &      "Byte"
%typemap(paswrapintype) short,              const short *,              const short &              "Smallint"
%typemap(paswrapintype) unsigned short,     const unsigned short *,     const unsigned short &     "Word"
%typemap(paswrapintype) int &, int,         const int *,                const int &                "Integer"
%typemap(paswrapintype) unsigned int,       const unsigned int *,       const unsigned int &       "Cardinal"
%typemap(paswrapintype) long,               const long *,               const long &               "Longword"
%typemap(paswrapintype) unsigned long,      const unsigned long *,      const unsigned long &      "Longint"
%typemap(paswrapintype) int64_t &, int64_t, const int64_t *,            const int64_t &            "NativeUInt"
%typemap(paswrapintype) uint32_t &, uint32_t, const uint32_t *,            const uint32_t &            "NativeUInt"
%typemap(paswrapintype) size_t &, size_t,   const size_t *,             const size_t &             "NativeUInt"
%typemap(paswrapintype) long long,          const long long *,          const long long &          "Int64"
%typemap(paswrapintype) unsigned long long, const unsigned long long *, const unsigned long long & "Int64"
%typemap(paswrapintype) float,              const float *,              const float &              "single"
%typemap(paswrapintype) double,             const double *,             const double &             "Double"
%typemap(paswrapintype) long double,        const long double *,        const long double &        "Extended"
%typemap(paswrapintype) const char *, const char []   				                              "PChar"
%typemap(paswrapintype,numinputs=0)         void              					                  ""

%typemap(pasin_locals)  int & "" 
%typemap(pasin_pre)  int & "" 
%typemap(pasin_post)  int & "" 
%typemap(pasin)			int & ""

%typemap(paswrapouttype) bool,               bool *,               bool &                  "LongBool"
%typemap(paswrapouttype) char,               char *,               char &                  "Char"
%typemap(paswrapouttype) signed char,        signed char *,        signed char &           "ShortInt"
%typemap(paswrapouttype) unsigned char,      unsigned char *,      unsigned char &         "Byte"
%typemap(paswrapouttype) short,              short *,              short &                 "Smallint"
%typemap(paswrapouttype) unsigned short,     unsigned short *,     unsigned short &        "Word"
%typemap(paswrapouttype) int,                int *,                int &                   "Integer"
%typemap(paswrapouttype) unsigned int,       unsigned int *,       unsigned int &          "Cardinal"
%typemap(paswrapouttype) long,               long *,               long &                  "Longword"
%typemap(paswrapouttype) unsigned long,      unsigned long *,      unsigned long &         "Longint"
%typemap(paswrapouttype) int64_t,            int64_t *,            int64_t &               "NativeUInt"
%typemap(paswrapouttype) uint32_t,            uint32_t *,            uint32_t &               "NativeUInt"
%typemap(paswrapouttype) size_t,             size_t *,             size_t &                "NativeUInt"
%typemap(paswrapouttype) long long,          long long *,          long long &             "Int64"
%typemap(paswrapouttype) unsigned long long, unsigned long long *, unsigned long long &    "Int64"
%typemap(paswrapouttype) float,              float *,              float &                 "single"
%typemap(paswrapouttype) double,             double *,             double &                "Double"
%typemap(paswrapouttype) long double,        long double *,        long double &           "Extended"
%typemap(paswrapouttype) char *, char []    												  "PChar"
%typemap(paswrapouttype,numinputs=0) void   												  ""

%typemap(paswraprettype) bool,               const bool &               "LongBool"
%typemap(paswraprettype) char,               const char &               "Char"
%typemap(paswraprettype) signed char,        const signed char &        "ShortInt"
%typemap(paswraprettype) unsigned char,      const unsigned char &      "Byte"
%typemap(paswraprettype) short,              const short &              "Smallint"
%typemap(paswraprettype) unsigned short,     const unsigned short &     "Word"
%typemap(paswraprettype) int,                const int &                "Integer"
%typemap(paswraprettype) unsigned int,       const unsigned int &       "Cardinal"
%typemap(paswraprettype) long,               const long &               "Longword"
%typemap(paswraprettype) unsigned long,      const unsigned long &      "Longint"
%typemap(paswraprettype) int64_t,            const int64_t &            "NativeUInt"
%typemap(paswraprettype) uint32_t,            const uint32_t &            "NativeUInt"
%typemap(paswraprettype) size_t,             const size_t &             "NativeUInt"
%typemap(paswraprettype) long long,          const long long &          "Int64"
%typemap(paswraprettype) unsigned long long, const unsigned long long & "Int64"
%typemap(paswraprettype) float,              const float &              "single"
%typemap(paswraprettype) double,             const double &             "Double"
%typemap(paswraprettype) long double,        const long double &        "Extended"
%typemap(paswraprettype) char *                                         "PChar"
%typemap(paswraprettype) void                                           ""

// Typemap for array

%typemap(ctype)           unsigned int[ANY]               "unsigned int *"
%typemap(pasrawtype)      unsigned int[ANY]               "PCardinalArray"
%typemap(pasrawintype)    unsigned int[ANY]               "PCardinalArray"
%typemap(pasrawrettype)   unsigned int[ANY]               "PCardinalArray"
%typemap(paswraptype)     unsigned int[ANY]               "PCardinalArray"
%typemap(paswrapintype)   unsigned int[ANY]               "PCardinalArray"
%typemap(paswrapouttype)  unsigned int[ANY]               "PCardinalArray"
%typemap(paswraprettype)  unsigned int[ANY]               "PCardinalArray"

// Please add all the other basic types ...

%typemap(ctype)           char[ANY]               "char *"
%typemap(pasrawtype)      char[ANY]               "PChar"
%typemap(pasrawintype)    char[ANY]               "PChar"
%typemap(pasrawrettype)   char[ANY]               "PChar"
%typemap(paswraptype)     char[ANY]               "PChar"
%typemap(paswrapintype)   char[ANY]               "PChar"
%typemap(paswrapouttype)  char[ANY]               "PChar"
%typemap(paswraprettype)  char[ANY]               "PChar"

%typemap(paswrapinmode)  const char * %{%}
%typemap(paswrapargvar)  const char * %{$1 : C.char_star;%}
%typemap(paswrapinconv)  const char * %{$1 := M3toC.SharedTtoS($1_name);%}
%typemap(paswrapfreearg) const char * %{M3toC.FreeSharedS($1_name,$1);%}
%typemap(paswrapargraw)  const char * %{$1%}
%typemap("paswrapargvar:import")  const char * "Ctypes AS C"
%typemap("paswrapinconv:import")  const char * "M3toC"
%typemap("paswrapfreearg:import") const char * "M3toC"

%typemap(paswrapretvar)  char * %{result : C.char_star;%}
%typemap(paswrapretraw)  char * %{result%}
%typemap(paswrapretconv) char * %{M3toC.CopyStoT(result)%}
%typemap("paswrapretvar:import")  char * "Ctypes AS C"
%typemap("paswrapretconv:import") char * "M3toC"

%typemap(paswrapinmode)  FILE * %{%}

/* Composed types */
//%typemap(ctype)                 SWIGTYPE "$1_type"
%typemap(ctype)                 SWIGTYPE "void *"

%typemap(pasrawtype)            SWIGTYPE "$1_type"

%typemap(pasrawintype)          SWIGTYPE "$1_type"
%typemap(pasrawrettype)         SWIGTYPE "$1_basetype"
%typemap(paswraptype)           SWIGTYPE "T$1_basetype"
%typemap(paswrapintype)         SWIGTYPE "T$1_basetype"
%typemap(paswrapouttype)        SWIGTYPE "T$1_basetype"
%typemap(paswraprettype)        SWIGTYPE "T$1_basetype"

%typemap(ctype)                SWIGTYPE [] "$1_type"
%typemap(ctype)                SWIGTYPE [ANY] "$1_basetype *"
%typemap(pasrawtype)      const SWIGTYPE [] "$1_basetypeArray"
%typemap(pasrawtype)            SWIGTYPE [] "$1_basetypeArray"
%typemap(pasrawintype)    const SWIGTYPE [] "" "$1_basetype" "Array"
%typemap(pasrawinmode)    const SWIGTYPE [] ""
%typemap(pasrawintype)          SWIGTYPE [] "$1_basetypeArray"
%typemap(pasrawinmode)          SWIGTYPE [] ""
%typemap(pasrawrettype)   const SWIGTYPE [] "$1_basetypeArray"
%typemap(pasrawrettype)         SWIGTYPE [] "$1_basetypeArray"
%typemap(paswraptype)           SWIGTYPE [] "$1_basetypeArray"
%typemap(paswrapintype)   const SWIGTYPE [] "$1_basetypeArray"
%typemap(paswrapinmode)   const SWIGTYPE [] ""
%typemap(paswrapintype)         SWIGTYPE [] "$1_basetypeArray"
%typemap(paswrapinmode)         SWIGTYPE [] ""
%typemap(paswrapouttype)        SWIGTYPE [] "$1_basetypeArray"
%typemap(paswraprettype)        SWIGTYPE [] "$1_basetypeArray"

%typemap(ctype)                SWIGTYPE * "$1_type"
%typemap(pasrawtype)      const SWIGTYPE * "$1_basetype"
%typemap(pasrawtype)            SWIGTYPE * "$1_basetype"
%typemap(pasrawintype)    const SWIGTYPE * "$1_basetype"
%typemap(pasrawinmode)    const SWIGTYPE * ""
%typemap(pasrawintype)          SWIGTYPE * "$1_basetype"

%typemap(pasrawinmode)          SWIGTYPE * ""
%typemap(pasrawrettype)   const SWIGTYPE * "$1_basetype"
%typemap(pasrawrettype)         SWIGTYPE * "$1_basetype"

%typemap(paswraptype)           SWIGTYPE * "T$1_basetype"
%typemap(paswrapintype)   const SWIGTYPE * "T$1_basetype"
%typemap(paswrapinmode)   const SWIGTYPE * ""
%typemap(paswrapintype)         SWIGTYPE * "T$1_basetype"
%typemap(paswrapinmode)         SWIGTYPE * ""
%typemap(paswrapouttype)        SWIGTYPE * "T$1_basetype"
%typemap(paswraprettype)        SWIGTYPE * "T$1_basetype"

%typemap(ctype)                SWIGTYPE & "$1_basetype *"
%typemap(ctype)          const SWIGTYPE & "$1_basetype *"
%typemap(pasrawtype)      const SWIGTYPE & "$1_basetype"
%typemap(pasrawtype)            SWIGTYPE & "$1_basetype"
%typemap(pasrawintype)    const SWIGTYPE & "$1_basetype"
%typemap(pasrawinmode)    const SWIGTYPE & "const"
%typemap(pasrawintype)          SWIGTYPE & "$1_basetype"
//%typemap(pasrawinmode)          SWIGTYPE & "var"
%typemap(pasrawinmode)          SWIGTYPE & ""


%typemap(pasrawrettype)   const SWIGTYPE & "$1_basetype"
%typemap(pasrawrettype)         SWIGTYPE & "$1_basetype"

%typemap(paswraptype)           SWIGTYPE & "T$1_basetype"
%typemap(paswrapintype)   const SWIGTYPE & "T$1_basetype"
%typemap(paswrapinmode)   const SWIGTYPE & "const"

%typemap(paswrapintype)         SWIGTYPE & "T$1_basetype"
%typemap(paswrapinmode)         SWIGTYPE & "var"
%typemap(paswrapouttype)        SWIGTYPE & "T$1_basetype"
%typemap(paswraprettype)        SWIGTYPE & "T$1_basetype"

%typemap(ctype)                SWIGTYPE && "$1_basetype *"
%typemap(ctype)          const SWIGTYPE && "$1_basetype *"
%typemap(pasrawtype)      const SWIGTYPE && "$1_basetype"
%typemap(pasrawtype)            SWIGTYPE && "$1_basetype"
%typemap(pasrawintype)    const SWIGTYPE && "$1_basetype"
%typemap(pasrawinmode)    const SWIGTYPE && "const"
%typemap(pasrawintype)          SWIGTYPE && "$1_basetype"
//%typemap(pasrawinmode)          SWIGTYPE && "var"
%typemap(pasrawinmode)          SWIGTYPE && ""


%typemap(pasrawrettype)   const SWIGTYPE && "$1_basetype"
%typemap(pasrawrettype)         SWIGTYPE && "$1_basetype"

%typemap(paswraptype)           SWIGTYPE && "T$1_basetype"
%typemap(paswrapintype)   const SWIGTYPE && "T$1_basetype"
%typemap(paswrapinmode)   const SWIGTYPE && "const"

%typemap(paswrapintype)         SWIGTYPE && "T$1_basetype"
%typemap(paswrapinmode)         SWIGTYPE && "var"
%typemap(paswrapouttype)        SWIGTYPE && "T$1_basetype"
%typemap(paswraprettype)        SWIGTYPE && "T$1_basetype"

%typemap(ctype)            enum SWIGTYPE "$1_type"
%typemap(pasrawtype)       enum SWIGTYPE "integer"
%typemap(pasrawintype)     enum SWIGTYPE "integer"
%typemap(pasrawrettype)    enum SWIGTYPE "integer"
%typemap(paswraptype)      enum SWIGTYPE "integer"
%typemap(paswrapintype)    enum SWIGTYPE "integer"
%typemap(paswrapouttype)   enum SWIGTYPE "integer"
%typemap(paswraprettype)   enum SWIGTYPE "integer"

/* pointer to a class member */
%typemap(ctype)      SWIGTYPE (CLASS::*) "void *"
%typemap(pasrawtype)  SWIGTYPE (CLASS::*) "pointer"
%typemap(paswraptype) SWIGTYPE (CLASS::*) "pointer"
%typemap(pasrawrettype) SWIGTYPE (CLASS::*) "pointer"
%typemap(pasrawintype) SWIGTYPE (CLASS::*) "pointer"
%typemap(pasrawouttype) SWIGTYPE (CLASS::*) "pointer"
%typemap(paswrapintype) SWIGTYPE (CLASS::*) "pointer"
%typemap(paswrapouttype) SWIGTYPE (CLASS::*) "pointer"

%typemap(ctype)      void * "void *"
%typemap(pasrawtype)  void *  "pointer"
%typemap(paswraptype) void *  "pointer"
%typemap(pasrawrettype) void *  "pointer"
%typemap(pasrawintype) void *  "pointer"
%typemap(pasrawouttype) void * "pointer"
%typemap(paswrapintype) void * "pointer"
%typemap(paswrapouttype) void *  "pointer"



/* The following are the in, out, freearg, argout typemaps.
   These are the PInvoke code generating typemaps for converting from C# to C and visa versa. */

/* primitive types */
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
             int64_t, 
             uint32_t, 
             size_t, 
             unsigned long long, 
             float, 
             double, 
             enum SWIGTYPE
%{ $input %}

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
%typemap(out) int64_t            %{ $result = $1; %}
%typemap(out) uint32_t            %{ $result = $1; %}
%typemap(out) size_t             %{ $result = $1; %}
%typemap(out) long long          %{ $result = $1; %}
%typemap(out) unsigned long long %{ $result = $1; %}
%typemap(out) float              %{ $result = $1; %}
%typemap(out) double             %{ $result = $1; %}
%typemap(out) enum SWIGTYPE      %{ $result = $1; %}

/* char * - treat as String */
%typemap(in) char * {
  $1 = $input;
}
//%typemap(freearg) char * { if ($1) JCALL2(ReleaseStringUTFChars, jenv, $input, $1); }
//%typemap(out) char * { if($1) $result = JCALL1(NewStringUTF, jenv, $1); }

%typemap(out) void ""

/* primitive types by const reference */
%typemap(in) const bool & (bool temp)
%{ temp = $input ? true : false; 
   $1 = &temp; %}

%typemap(in) const char & (char temp), 
             const signed char & (signed char temp), 
             const unsigned char & (unsigned char temp), 
             const short & (short temp), 
             const unsigned short & (unsigned short temp), 
             const int & (int temp), 
             const unsigned int & (unsigned int temp), 
             const long & (long temp), 
             const int64_t & ($*1_ltype temp), 
             const uint32_t & ($*1_ltype temp), 
             const size_t & ($*1_ltype temp), 
             const unsigned long & (unsigned long temp), 
             const long long & ($*1_ltype temp), 
             const unsigned long long & ($*1_ltype temp), 
             const float & (float temp), 
             const double & (double temp)
%{ temp = ($*1_ltype)$input; 
$1 = &temp; %}

%typemap(out) const bool &               %{ $result = *$1; %}
%typemap(out) const char &               %{ $result = *$1; %}
%typemap(out) const signed char &        %{ $result = *$1; %}
%typemap(out) const unsigned char &      %{ $result = *$1; %}
%typemap(out) const short &              %{ $result = *$1; %}
%typemap(out) const unsigned short &     %{ $result = *$1; %}
%typemap(out) const int &                %{ $result = *$1; %}
%typemap(out) const unsigned int &       %{ $result = *$1; %}
%typemap(out) const long &               %{ $result = *$1; %}
%typemap(out) const int64_t &            %{ $result = *$1; %}
%typemap(out) const uint32_t &            %{ $result = *$1; %}
%typemap(out) const size_t &             %{ $result = *$1; %}
%typemap(out) const unsigned long &      %{ $result = *$1; %}
%typemap(out) const long long &          %{ $result = *$1; %}
%typemap(out) const unsigned long long & %{ $result = *$1; %}
%typemap(out) const float &              %{ $result = *$1; %}
%typemap(out) const double &             %{ $result = *$1; %}

/* Default handling. Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE ($&1_type argp)
%{ argp = *($&1_ltype*)&$input; 
   if (!argp) {
//     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "Attempt to dereference null $1_type");
     return $null;
   }
   $1 = *argp; %}

%typemap(out) SWIGTYPE 
#ifdef __cplusplus
%{*($&1_ltype*)&$result = new $1_ltype(($1_ltype &)$1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  *($&1_ltype*)&$result = $1ptr;
}
#endif

/* Generic pointers and references */
%typemap(in) SWIGTYPE *, SWIGTYPE (CLASS::*) %{ $1 = *($&1_ltype)&$input; %}



%typemap(in) SWIGTYPE & %{ $1 = *($&1_ltype)&$input;
  if(!$1) {
    //SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "$1_type reference is null");
    return $null;
  } %}
%typemap(in) SWIGTYPE && %{ $1 = *($&1_ltype)&$input;
  if(!$1) {
    //SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "$1_type reference is null");
    return $null;
  } %}
%typemap(out) SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE (CLASS::*) %{ *($&1_ltype)&$result = $1; %} 


/* Default array handling */
%typemap(in) SWIGTYPE [] %{ $1 = *($&1_ltype)&$input; %}
%typemap(out) SWIGTYPE [] %{ *($&1_ltype)&$result = $1; %} 

/* char[ANY] - treat as String */
%typemap(in) char[ANY] { 
    $1 = $input;
}

%typemap(argout) char[ANY] ""
%typemap(freearg) char[ANY] ""//{ if ($1) JCALL2(ReleaseStringUTFChars, jenv, $input, $1); }
%typemap(out) char[ANY] { if($1) $result = $1; }


/* Typecheck typemaps - The purpose of these is merely to issue a warning for overloaded C++ functions 
 * that cannot be overloaded in C# as more than one C++ type maps to a single C# type */

%typecheck(SWIG_TYPECHECK_BOOL) /* Java boolean */
    bool,
    const bool &
    ""

%typecheck(SWIG_TYPECHECK_CHAR) /* Java char */
    char, 
    const char &
    ""

%typecheck(SWIG_TYPECHECK_INT8) /* Java byte */
    signed char,
    const signed char &
    ""

%typecheck(SWIG_TYPECHECK_INT16) /* Java short */
    unsigned char, 
    short, 
    const unsigned char &, 
    const short &
    ""

%typecheck(SWIG_TYPECHECK_INT32) /* Java int */
    unsigned short, 
    int, 
    long, 
    const unsigned short &, 
    const int &, 
    const long &,
    enum SWIGTYPE
    ""

%typecheck(SWIG_TYPECHECK_INT64) /* Java long */
    unsigned int, 
    unsigned long, 
    int64_t, 
    uint32_t, 
    size_t, 
    long long, 
    const unsigned int &, 
    const unsigned long &, 
    const int64_t &,
    const uint32_t &,
    const size_t &,
    const long long &
    ""

%typecheck(SWIG_TYPECHECK_INT128) /* Java BigInteger */
    unsigned long long
    ""

%typecheck(SWIG_TYPECHECK_FLOAT) /* Java float */
    float,
    const float &
    ""

%typecheck(SWIG_TYPECHECK_DOUBLE) /* Java double */
    double,
    const double &
    ""

%typecheck(SWIG_TYPECHECK_STRING) /* Java String */
    char *,
    char[ANY]
    ""

%typecheck(SWIG_TYPECHECK_POINTER) /* Default */
    SWIGTYPE, 
    SWIGTYPE *, 
    SWIGTYPE &, 
    SWIGTYPE &&, 
    SWIGTYPE [],
    SWIGTYPE (CLASS::*)
    ""

/* Exception handling */

%typemap(throws) int, 
                 long, 
                 short, 
                 unsigned int, 
                 unsigned long, 
                 unsigned short {
  char error_msg[256];
  sprintf(error_msg, "C++ $1_type exception thrown, value: %d", $1);
  //SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, error_msg);
  return $null;
}

%typemap(throws) SWIGTYPE {
  (void)$1;
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown");
  RETURN $null;
}

%typemap(throws) char * {
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1);
  RETURN $null;
}


/* Typemaps for code generation in proxy classes and C# type wrapper classes */

/* The in typemap is used for converting function parameter types from the type 
 * used in the proxy, module or type wrapper class to the type used in the PInvoke class. */
%typemap(in)     bool,               const bool &,
                 char,               const char &,
                 signed char,        const signed char &,
                 unsigned char,      const unsigned char &,
                 short,              const short &,
                 unsigned short,     const unsigned short &,
                 int,                const int &,
                 unsigned int,       const unsigned int &,
                 long,               const long &,
                 unsigned long,      const unsigned long &,
                 long long,          const long long &,
                 int64_t,            const int64_t &,
                 uint32_t,            const uint32_t &,
                 size_t,             const size_t &,
                 unsigned long long, const unsigned long long &,
                 float,              const float &,
                 double,             const double &,
                 char *,
                 char[ANY],
		 unsigned int[ANY],
                 enum SWIGTYPE 
    "$1 = ($1_ltype)$input;"
    
/*  
%typemap(pasin, locals) bool 
%{ 
   (*locals *) 
%}  

%typemap(pasin, pre) bool 
%{ 
   (* pre *)
%}   

%typemap(pasin, post) bool 
%{ 
   (*post*)
%}   
*/

%typemap(pasin,
          locals=
"(*locals *)
//var $n_name tmp : boolean; 
 ",  
          pre="(*pre*)",  
          post="(*post*)" )  bool 
%{$input  %}

/*
%{ 
   tmp := $input  (* *);
   $1 := tmp;
%}    
*/
%typemap(pasin)    /* bool,*/               const bool &,
                 char,               const char &,
                 signed char,        const signed char &,
                 unsigned char,      const unsigned char &,
                 short,              const short &,
                 unsigned short,     const unsigned short &,
                 int,                const int &,
                 int &,
                 unsigned int,       const unsigned int &,
                 long,               const long &,
                 unsigned long,      const unsigned long &,
                 int64_t,            const int64_t &,
				 int64_t &,
                 uint32_t,            const uint32_t &,
				 uint32_t &,
                 size_t,             const size_t &,
				 size_t &,
                 long long,          const long long &,
                 unsigned long long, const unsigned long long &,
                 float,              const float &,
                 double,             const double &,
                 char *,
                 char[ANY],
		 unsigned int[ANY],
		 void *,
                 enum SWIGTYPE,
  		  bool [ANY],
		  signed char[ANY],
		  unsigned short[ANY],
		  int [ANY],
		  unsigned int [ANY], 
		  unsigned long [ANY],
		  int64_t [ANY], 
		  uint32_t [ANY], 
		  size_t [ANY], 
		  long long [ANY], 
		  unsigned long long [ANY],
		  float [ANY],
		  double [ANY] 
    "$input"    
    
%typemap(pasin_locals) SWIGTYPE *, SWIGTYPE [], SWIGTYPE (CLASS::*) 
	""

%typemap(pasin_pre) SWIGTYPE *&, SWIGTYPE [], SWIGTYPE (CLASS::*) 
	""

%typemap(pasin_post) SWIGTYPE *, SWIGTYPE [], SWIGTYPE (CLASS::*) 
	""

%typemap(pasin) SWIGTYPE *, SWIGTYPE [] 
	"$input.CObjPtr"

%typemap(pasin) SWIGTYPE (CLASS::*) 
	"$input"


%typemap(pasin_locals) SWIGTYPE & 
	"var arg$argnum:$pasclassname;"

%typemap(pasin_pre) SWIGTYPE & 
	"  arg$argnum := $input.CObjPtr;"

%typemap(pasin_post) SWIGTYPE & 
	"  $input.CObjPtr := arg$argnum ;"


%typemap(pasin) SWIGTYPE &  
	"arg$argnum"

%typemap(pasin_locals) SWIGTYPE && 
	"var arg$argnum:$pasclassname;"

%typemap(pasin_pre) SWIGTYPE && 
	"  arg$argnum := $input.CObjPtr;"

%typemap(pasin_post) SWIGTYPE && 
	"  $input.CObjPtr := arg$argnum ;"


%typemap(pasin) SWIGTYPE &&  
	"arg$argnum"


/* The pasout typemap is used for converting function return types from the return type
 * used in the PInvoke class to the type returned by the proxy, module or type wrapper class. */
%typemap(pasout)   bool,               const bool &,
                  char,               const char &,
                  signed char,        const signed char &,
                  unsigned char,      const unsigned char &,
                  short,              const short &,
                  unsigned short,     const unsigned short &,
                  int,                const int &, int &, 
                  unsigned int,       const unsigned int &,
                  long,               const long &,
                  unsigned long,      const unsigned long &,
                  int64_t,            const int64_t &, int64_t &,
                  uint32_t,            const uint32_t &, uint32_t &,
                  size_t,             const size_t &, size_t &,
                  long long,          const long long &,
                  unsigned long long, const unsigned long long &,
                  float,              const float &,
                  double,             const double &,
                  char *,
                  char[ANY],
                  enum SWIGTYPE,
		  void *,
		  unsigned int[ANY],
		  bool [ANY],
		  signed char[ANY],
		  unsigned short[ANY],
		  int [ANY],
		  unsigned int [ANY], 
		  unsigned long [ANY],
		  int64_t [ANY], 
		  uint32_t [ANY], 
		  size_t [ANY], 
		  long long [ANY], 
		  unsigned long long [ANY],
		  float [ANY],
		  double [ANY], 
		  SWIGTYPE (CLASS::*)     
					%{ $result := $imcall %}

%typemap(pasout) void %{$imcall%}

%typemap(pasout) SWIGTYPE %{
    $result := T$pasclassname.Create($imcall);
%}
%typemap(pasout) SWIGTYPE & %{
    $result := T$pasclassname.Create($imcall, $owner);
%}
%typemap(pasout) SWIGTYPE && %{
    $result := T$pasclassname.Create($imcall, $owner);
%}

%typemap(pasout_locals) SWIGTYPE *, SWIGTYPE [] %{
  
var CPtr : pointer;

%}

%typemap(pasout,locals="var CPtr : $pasclassname;") SWIGTYPE *, SWIGTYPE [] %{
    cPtr := $imcall;
    if cPtr <> nil then
		$result := T$pasclassname.Create($imcall, $owner)
	else
		$result := nil;
%}

%typemap(pasvarrw) bool,               const bool &,
                   char,               const char &,
                   signed char,        const signed char &,
                   unsigned char,      const unsigned char &,
                   short,              const short &,
                   unsigned short,     const unsigned short &,
                   int,                const int &,
                   unsigned int,       const unsigned int &,
                   long,               const long &,
                   unsigned long,      const unsigned long &,
                   int64_t,            const int64_t &,
                   uint32_t,            const uint32_t &,
                   size_t,             const size_t &,
                   long long,          const long long &,
                   unsigned long long, const unsigned long long &,
                   float,              const float &,
                   double,             const double &,
                   char *,
                   char[ANY],
                   enum SWIGTYPE %{
 public                  
	property $varname : $vartype read Get$varname write Set$varname;

%}

%typemap(pasvarro) bool,               const bool &,
                   char,               const char &,
                   signed char,        const signed char &,
                   unsigned char,      const unsigned char &,
                   short,              const short &,
                   unsigned short,     const unsigned short &,
                   int,                const int &,
                   unsigned int,       const unsigned int &,
                   long,               const long &,
                   unsigned long,      const unsigned long &,
                   int64_t,            const int64_t &,
                   uint32_t,            const uint32_t &,
                   size_t,             const size_t &,
                   long long,          const long long &,
                   unsigned long long, const unsigned long long &,
                   float,              const float &,
                   double,             const double &,
                   char *,
                   char[ANY],
                   enum SWIGTYPE %{
 public                  
	property $varname : $vartype read Get$varname;

%}

/* Typemaps used for the generation of proxy and type wrapper class code */
%typemap(pasbase)                      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(pasclassmodifiers)            SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) "public"
%typemap(pascode)                      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(pasimports)                   SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(pasinterfaces)                SWIGTYPE ""
%typemap(pasinterfaces_derived)                  SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(pasptrconstructormodifiers) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) "internal"

%typemap(pasfinalize) SWIGTYPE %{
	end;
%}

%typemap(pasclassdef_base) SWIGTYPE "
  T$pasclassname = class (TObject, IUnknown)

  private
    FCObjPtr : $pasclassname;
    FOwnCObjPtr : boolean;

  protected
	procedure SetCObjPtr(Value : $pasclassname);
  // IUnknown
    function _AddRef : integer; stdcall;
    function _Release: integer; stdcall;
    function QueryInterface(const GUID:TGUID; out Intf): HRESULT; stdcall;
 public
"
%typemap(pasclassdef_base_struct) SWIGTYPE "
  T$pasclassname = class

  private
    FCObjPtr : $pasclassname;
    FOwnCObjPtr : boolean;

  protected
	procedure SetCObjPtr(Value : $pasclassname);
  // IUnknown
    function _AddRef : integer; stdcall;
    function _Release: integer; stdcall;
    function QueryInterface(const GUID:TGUID; out Intf): HRESULT; stdcall;
 public
"

%typemap(pasclass_iunknown) SWIGTYPE "

function T$pasclassname._AddRef : integer;
begin
   Result := -1;
end;

function T$pasclassname._Release: integer;
begin
   Result := -1;
end;

function T$pasclassname.QueryInterface(const GUID:TGUID; out Intf): HRESULT;
begin
   if GetInterface(GUID, Intf) then
      Result := S_OK
   else
      Result := S_FALSE	;
end; 
 "


%typemap(pasdefault_constructor_def) SWIGTYPE "
    constructor Create; overload; virtual;
    constructor Create(CObj:$pasclassname; OwnObj:boolean); overload; 
"
%typemap(pasdefault_constructor_code) SWIGTYPE "
constructor T$pasclassname.Create; 
begin
  inherited Create;
  FCObjPtr := nil;
  FOwnCObjPtr := true
end;

constructor T$pasclassname.Create(CObj:$pasclassname; OwnObj:boolean); 
begin
  inherited Create;
  FCObjPtr := CObj;
  FOwnCObjPtr := OwnObj
end;

"

%typemap(pasclassdef_derived, methodname="Dispose") SWIGTYPE "
  T$pasclassname = class (T$baseclass) 
  public
"

%typemap(pasclassdef_end) SWIGTYPE "
  end;
"

%typemap(pasdestruct_def, methodname="Dispose") SWIGTYPE "
    destructor Destroy; override;
"


%typemap(pasdestruct_code, methodname="Dispose") SWIGTYPE "
destructor T$pasclassname.Destroy; 
begin   
  if (FCObjPtr <> nil) and  FOwnCObjPtr then begin 
    $imcall;
    FOwnCObjPtr := false;
  end;
  FCObjPtr := nil; 
  inherited Destroy;
end;

procedure T$pasclassname.SetCObjPtr(Value : $pasclassname);
begin
 
  if (Value <> FCObjPtr) then begin
	if (FCObjPtr <> nil) and  FOwnCObjPtr then begin 
		$imcall;
	end;
	FCObjPtr := Value;
  
  
  end;

end;

"

%typemap(pasdestruct_derived_code, methodname="Dispose") SWIGTYPE "
destructor T$pasclassname.Destroy;
begin   
  if (FCObjPtr  <> nil) and  FOwnCObjPtr then begin 
    $imcall;
    FOwnCObjPtr := false;
  end;  
  FCObjPtr := nil; 
  inherited Destroy;
end;
"

%typemap(pasgetcptr_intf) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) %{  
  public  
    property CObjPtr : $pasclassname read FCObjPtr write SetCObjPtr;
    property OwnCObjPtr : boolean read FOwnCObjPtr  write FOwnCObjPtr ;
%}


/* M3 specific directives */


#define %pasmultiretval        %feature("modula3:multiretval")
#define %constnumeric(num)    %feature("constnumeric","num")

%pragma(modula3) moduleimports=%{
IMPORT BlaBla;
%}

%pragma(modula3) imclassimports=%{
FROM BlaBla IMPORT Bla;
%}

/* Some ANSI C typemaps */

%apply unsigned long { NativeUInt };

/*
%define DeclarePlaceHolder(__WHERE__, x)

%insert(##__WHERE__) %{
	type  
		x = integer;
		P##x=^##x##;
		##x##Array = array[0..(MaxInt div sizeof(x))-1] of x;
		P##x##Array = ^##x##Array;

%}

%enddef

*/

#if 0

%define DeclarePlaceHolder(__WHERE__, x)

%insert(##__WHERE__) %{
	type  
		P##x=type Pointer;
%}

%typemap(pasrawintype)    x  %{P##x%}
%typemap(pasrawouttype)    x  %{P##x%}
%typemap(pasrawrettype)    x  %{P##x%}

%enddef

#endif

%define DeclarePlaceHolder(__WHERE__, x)

%insert(##__WHERE__) %{
	type  
		x=type Pointer;
		##x##Array = array[0..(MaxInt div sizeof(x))-1] of x;
		P##x##Array = ^##x##Array;
%}

%typemap(pasrawintype)    x  %{x%}
%typemap(pasrawouttype)    x  %{x%}
%typemap(pasrawrettype)    x  %{x%}

%enddef


%define DeclareArrayOf(__WHERE__, x)

%insert(##__WHERE__) %{
	type  
		P##x=^##x##;
		##x##Array = array[0..(MaxInt div sizeof(x))-1] of x;
		P##x##Array = ^##x##Array;

%}

%enddef


%insert(interface_begin) %{
//type PDouble = ^double;
%}

DeclareArrayOf(interface_begin, double)
DeclareArrayOf(interface_begin, cardinal)


%insert(interface_end) %{
type
	Psize_t = ^Cardinal;
%}


%define TEMPLATE_WRAP0(name, type,T...) 

%typemap(  pasrawintype)      name < T > * 	%{type%}
%typemap(  pasrawouttype)     name < T > * 	%{type%}
%typemap(  pasrawrettype)     name < T > * 	%{type%}

%template(type) name<T >;

%enddef

%define TEMPLATE_WRAP(name, type,T...) 

%typemap(  pasrawintype)      name < T > * 	%{name##type%}
%typemap(  pasrawouttype)     name < T > * 	%{name##type%}
%typemap(  pasrawrettype)     name < T > * 	%{name##type%}

%template(name ## type) name<T >;

%enddef

DeclarePlaceHolder(interface_begin, CFILE);