
/* These typemaps will eventually probably maybe make their way into named typemaps
 * OUTPUT * and OUTPUT & as they currently break functions that return a pointer or 
 * reference. */

%typemap(jni) bool *,               bool &               "bool *"
%typemap(jni)                       char &               "char *"
%typemap(jni) signed char *,        signed char &        "signed char *"
%typemap(jni) unsigned char *,      unsigned char &      "unsigned short *"
%typemap(jni) short *,              short &              "short *"
%typemap(jni) unsigned short *,     unsigned short &     "unsigned short *"
%typemap(jni) int *,                int &                "int *"
%typemap(jni) unsigned int *,       unsigned int &       "unsigned int *"
%typemap(jni) long *,               long &               "long *"
%typemap(jni) unsigned long *,      unsigned long &      "unsigned long *"
%typemap(jni) long long *,          long long &          "long long *"
%typemap(jni) unsigned long long *, unsigned long long & "unsigned long long *"
%typemap(jni) float *,              float &              "float *"
%typemap(jni) double *,             double &             "double *"

%typemap(jtype) bool *,               bool &               "ref bool"
%typemap(jtype)                       char &               "ref char"
%typemap(jtype) signed char *,        signed char &        "ref sbyte"
%typemap(jtype) unsigned char *,      unsigned char &      "ref byte"
%typemap(jtype) short *,              short &              "ref short"
%typemap(jtype) unsigned short *,     unsigned short &     "ref ushort"
%typemap(jtype) int *,                int &                "ref int"
%typemap(jtype) unsigned int *,       unsigned int &       "ref uint"
%typemap(jtype) long *,               long &               "ref int"
%typemap(jtype) unsigned long *,      unsigned long &      "ref uint"
%typemap(jtype) long long *,          long long &          "ref long"
%typemap(jtype) unsigned long long *, unsigned long long & "ref ulong"
%typemap(jtype) float *,              float &              "ref float"
%typemap(jtype) double *,             double &             "ref double"

%typemap(jstype) bool *,               bool &               "ref bool"
%typemap(jstype)                       char &               "ref char"
%typemap(jstype) signed char *,        signed char &        "ref sbyte"
%typemap(jstype) unsigned char *,      unsigned char &      "ref byte"
%typemap(jstype) short *,              short &              "ref short"
%typemap(jstype) unsigned short *,     unsigned short &     "ref ushort"
%typemap(jstype) int *,                int &                "ref int"
%typemap(jstype) unsigned int *,       unsigned int &       "ref uint"
%typemap(jstype) long *,               long &               "ref int"
%typemap(jstype) unsigned long *,      unsigned long &      "ref uint"
%typemap(jstype) long long *,          long long &          "ref long"
%typemap(jstype) unsigned long long *, unsigned long long & "ref ulong"
%typemap(jstype) float *,              float &              "ref float"
%typemap(jstype) double *,             double &             "ref double"

%typemap(javain) bool *,               bool &,
                                       char &,
                 signed char *,        signed char &,
                 unsigned char *,      unsigned char &,
                 short *,              short &,
                 unsigned short *,     unsigned short &,
                 int *,                int &,
                 unsigned int *,       unsigned int &,
                 long *,               long &,
                 unsigned long *,      unsigned long &,
                 long long *,          long long &,
                 unsigned long long *, unsigned long long &,
                 float *,              float &,
                 double *,             double &
    "ref $javainput"

