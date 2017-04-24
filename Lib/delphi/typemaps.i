/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * typemaps.i
 *
 * Pointer and reference handling typemap library
 *
 * These mappings provide support for input/output arguments and common
 * uses for C/C++ pointers and C++ references.
 * ----------------------------------------------------------------------------- */

/* These typemaps will eventually probably maybe make their way into named typemaps
 * OUTPUT * and OUTPUT & as they currently break functions that return a pointer or 
 * reference. */

%typemap(ctype) bool *,               bool &               "bool *"
%typemap(ctype)                       char &               "char *"
%typemap(ctype) signed char *,        signed char &        "signed char *"
%typemap(ctype) unsigned char *,      unsigned char &      "unsigned short *"
%typemap(ctype) short *,              short &              "short *"
%typemap(ctype) unsigned short *,     unsigned short &     "unsigned short *"
%typemap(ctype) int *,                int &                "int *"
%typemap(ctype) unsigned int *,       unsigned int &       "unsigned int *"
%typemap(ctype) long *,               long &               "long *"
%typemap(ctype) unsigned long *,      unsigned long &      "unsigned long *"
%typemap(ctype) int64_t *,            int64_t &            "int64_t *"
%typemap(ctype) uint32_t *,            uint32_t &            "uint32_t *"
%typemap(ctype) size_t *,             size_t &             "size_t *"
%typemap(ctype) long long *,          long long &          "long long *"
%typemap(ctype) unsigned long long *, unsigned long long & "unsigned long long *"
%typemap(ctype) float *,              float &              "float *"
%typemap(ctype) double *,             double &             "double *"

%typemap(imtype) bool *,               bool &               "ref bool"
%typemap(imtype)                       char &               "ref char"
%typemap(imtype) signed char *,        signed char &        "ref sbyte"
%typemap(imtype) unsigned char *,      unsigned char &      "ref byte"
%typemap(imtype) short *,              short &              "ref short"
%typemap(imtype) unsigned short *,     unsigned short &     "ref ushort"
%typemap(imtype) int *,                int &                "ref int"
%typemap(imtype) unsigned int *,       unsigned int &       "ref uint"
%typemap(imtype) long *,               long &               "ref int"
%typemap(imtype) unsigned long *,      unsigned long &      "ref uint"
%typemap(imtype) int64_t *,            int64_t &            "ref int64_t"
%typemap(imtype) uint32_t *,            uint32_t &            "ref uint32_t"
%typemap(imtype) size_t *,             size_t &             "ref size_t"
%typemap(imtype) long long *,          long long &          "ref long"
%typemap(imtype) unsigned long long *, unsigned long long & "ref ulong"
%typemap(imtype) float *,              float &              "ref float"
%typemap(imtype) double *,             double &             "ref double"

%typemap(cstype) bool *,               bool &               "ref bool"
%typemap(cstype)                       char &               "ref char"
%typemap(cstype) signed char *,        signed char &        "ref sbyte"
%typemap(cstype) unsigned char *,      unsigned char &      "ref byte"
%typemap(cstype) short *,              short &              "ref short"
%typemap(cstype) unsigned short *,     unsigned short &     "ref ushort"
%typemap(cstype) int *,                int &                "ref int"
%typemap(cstype) unsigned int *,       unsigned int &       "ref uint"
%typemap(cstype) long *,               long &               "ref int"
%typemap(cstype) unsigned long *,      unsigned long &      "ref uint"
%typemap(cstype) int64_t *,            int64_t &            "ref int64_t"
%typemap(cstype) uint32_t *,            uint32_t &            "ref uint32_t"
%typemap(cstype) size_t *,             size_t &             "ref size_t"
%%typemap(cstype) long long *,          long long &          "ref long"
typemap(cstype) unsigned long long *, unsigned long long & "ref ulong"
%typemap(cstype) float *,              float &              "ref float"
%typemap(cstype) double *,             double &             "ref double"

%typemap(csin)   bool *,               bool &,
                                       char &,
                 signed char *,        signed char &,
                 unsigned char *,      unsigned char &,
                 short *,              short &,
                 unsigned short *,     unsigned short &,
                 int *,                int &,
                 unsigned int *,       unsigned int &,
                 long *,               long &,
                 unsigned long *,      unsigned long &,
                 int64_t *,            int64_t &,
                 uint32_t *,            uint32_t &,
                 size_t *,             size_t &,
                 long long *,          long long &,
                 unsigned long long *, unsigned long long &,
                 float *,              float &,
                 double *,             double &
    "ref $csinput"
