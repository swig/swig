/* -----------------------------------------------------------------------------
 * csharp.swg
 *
 * CSharp typemaps
 * ----------------------------------------------------------------------------- */

//Initial revision of this module - the typemap names will change, in fact anything could change!!
%include "csharphead.swg"

/* The jni, jtype and jstype typemaps work together and so there should be one of each. 
 * The jni typemap contains the JNI type used in the JNI (C/C++) code. 
 * The jtype typemap contains the Java type used in the Java module class. 
 * The jstype typemap contains the Java type used in the Java proxy class. */

/* Primitive types */
%typemap(jni) bool,               const bool &               "bool"
%typemap(jni) char,               const char &               "char"
%typemap(jni) signed char,        const signed char &        "signed char"
%typemap(jni) unsigned char,      const unsigned char &      "unsigned short"
%typemap(jni) short,              const short &              "short"
%typemap(jni) unsigned short,     const unsigned short &     "unsigned short"
%typemap(jni) int,                const int &                "int"
%typemap(jni) unsigned int,       const unsigned int &       "unsigned int"
%typemap(jni) long,               const long &               "long"
%typemap(jni) unsigned long,      const unsigned long &      "unsigned long"
%typemap(jni) long long,          const long long &          "long long"
%typemap(jni) unsigned long long, const unsigned long long & "unsigned long long"
%typemap(jni) float,              const float &              "float"
%typemap(jni) double,             const double &             "double"
%typemap(jni) char *                                         "char *"
%typemap(jni) void                                           "void"

%typemap(jtype) bool,               const bool &               "bool"
%typemap(jtype) char,               const char &               "char"
%typemap(jtype) signed char,        const signed char &        "sbyte"
%typemap(jtype) unsigned char,      const unsigned char &      "byte"
%typemap(jtype) short,              const short &              "short"
%typemap(jtype) unsigned short,     const unsigned short &     "ushort"
%typemap(jtype) int,                const int &                "int"
%typemap(jtype) unsigned int,       const unsigned int &       "uint"
%typemap(jtype) long,               const long &               "int"
%typemap(jtype) unsigned long,      const unsigned long &      "uint"
%typemap(jtype) long long,          const long long &          "long"
%typemap(jtype) unsigned long long, const unsigned long long & "ulong"
%typemap(jtype) float,              const float &              "float"
%typemap(jtype) double,             const double &             "double"
%typemap(jtype) char *                                         "string"
%typemap(jtype) void                                           "void"

%typemap(jstype) bool,               const bool &               "bool"
%typemap(jstype) char,               const char &               "char"
%typemap(jstype) signed char,        const signed char &        "sbyte"
%typemap(jstype) unsigned char,      const unsigned char &      "byte"
%typemap(jstype) short,              const short &              "short"
%typemap(jstype) unsigned short,     const unsigned short &     "ushort"
%typemap(jstype) int,                const int &                "int"
%typemap(jstype) unsigned int,       const unsigned int &       "uint"
%typemap(jstype) long,               const long &               "int"
%typemap(jstype) unsigned long,      const unsigned long &      "uint"
%typemap(jstype) long long,          const long long &          "long"
%typemap(jstype) unsigned long long, const unsigned long long & "ulong"
%typemap(jstype) float,              const float &              "float"
%typemap(jstype) double,             const double &             "double"
%typemap(jstype) char *                                         "string"
%typemap(jstype) void                                           "void"

%typemap(jni) char[ANY]               "char *"
%typemap(jtype) char[ANY]               "string"
%typemap(jstype) char[ANY]               "string"

/* Non primitive types */
%typemap(jni) SWIGTYPE "int"
%typemap(jtype) SWIGTYPE "IntPtr"
%typemap(jstype) SWIGTYPE "$&javaclassname"

%typemap(jni) SWIGTYPE [] "int"
%typemap(jtype) SWIGTYPE [] "IntPtr"
%typemap(jstype) SWIGTYPE [] "$javaclassname"

%typemap(jni) SWIGTYPE * "int"
%typemap(jtype) SWIGTYPE * "IntPtr"
%typemap(jstype) SWIGTYPE * "$javaclassname"

%typemap(jni) SWIGTYPE & "int"
%typemap(jtype) SWIGTYPE & "IntPtr"
%typemap(jstype) SWIGTYPE & "$javaclassname"

%typemap(jni) enum SWIGTYPE "int"
%typemap(jtype) enum SWIGTYPE "int"
%typemap(jstype) enum SWIGTYPE "int"

/* pointer to a class member */
%typemap(jni) SWIGTYPE (CLASS::*) "int"
%typemap(jtype) SWIGTYPE (CLASS::*) "IntPtr"
%typemap(jstype) SWIGTYPE (CLASS::*) "$javaclassname"

/* The following are the in, out, freearg, argout typemaps. These are the JNI code generating typemaps for converting from Java to C and visa versa. */

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
             unsigned long long, 
             float, 
             double, 
             enum SWIGTYPE
%{ $1 = ($1_ltype)$input; %}

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
%typemap(out) SWIGTYPE *, SWIGTYPE &, SWIGTYPE (CLASS::*) %{ *($&1_ltype)&$result = $1; %} 


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
 * that cannot be overloaded in Java as more than one C++ type maps to a single Java type */

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
    long long, 
    const unsigned int &, 
    const unsigned long &, 
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
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, error_msg);
  return $null;
}

%typemap(throws) SWIGTYPE {
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, "C++ $1_type exception thrown");
  return $null;
}

%typemap(throws) char * {
  SWIG_JavaThrowException(jenv, SWIG_JavaRuntimeException, $1);
  return $null;
}


/* Typemaps for code generation in proxy classes and Java type wrapper classes */

/* The javain typemap is used for converting function parameter types from the type 
 * used in the proxy, module or type wrapper class to the type used in the JNI class. */
%typemap(javain) bool,               const bool &,
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
                 double,             const double &,
                 char *,
                 char[ANY],
                 enum SWIGTYPE 
    "$javainput"
%typemap(javain) SWIGTYPE "$&javaclassname.getCPtr($javainput)"
%typemap(javain) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "$javaclassname.getCPtr($javainput)"

/* The javaout typemap is used for converting function return types from the return type
 * used in the JNI class to the type returned by the proxy, module or type wrapper class. */
%typemap(javaout) bool,               const bool &,
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
                  double,             const double &,
                  char *,
                  char[ANY],
                  enum SWIGTYPE {
    return $jnicall;
  }
%typemap(javaout) void {
    $jnicall;
  }
%typemap(javaout) SWIGTYPE {
    return new $&javaclassname($jnicall, true);
  }
%typemap(javaout) SWIGTYPE & {
    return new $javaclassname($jnicall, $owner);
  }
%typemap(javaout) SWIGTYPE *, SWIGTYPE [], SWIGTYPE (CLASS::*) {
    IntPtr cPtr = $jnicall;
    return (cPtr == IntPtr.Zero) ? null : new $javaclassname(cPtr, $owner);
  }

/* Properties */
%typemap(csvarin) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
    set {
      $jnicall;
    } %}

%typemap(csvarout) bool,               const bool &,
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
                   double,             const double &,
                   char *,
                   char[ANY],
                   enum SWIGTYPE %{
    get {
      return $jnicall;
    } %}
%typemap(csvarout) void %{
    get {
      $jnicall;
    } %}
%typemap(csvarout) SWIGTYPE %{
    get {
      return new $&javaclassname($jnicall, true);
    } %}
%typemap(csvarout) SWIGTYPE & %{
    get {
      return new $javaclassname($jnicall, $owner);
    } %}
%typemap(csvarout) SWIGTYPE *, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
    get {
      IntPtr cPtr = $jnicall;
      return (cPtr == IntPtr.Zero) ? null : new $javaclassname(cPtr, $owner);
    } %}

/* Typemaps used for the generation of proxy and type wrapper class code */
%typemap(javabase)             SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(javaclassmodifiers)   SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "public"
%typemap(javacode)             SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(javaimports)          SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "using System;"
%typemap(csinterfaces_base)    SWIGTYPE "IDisposable"
%typemap(csinterfaces_derived)           SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(javaptrconstructormodifiers)   SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "internal"

%typemap(csfinalize) SWIGTYPE %{
  protected override void Finalize() {
    Dispose();
  }
%}

%typemap(csdestruct_base) SWIGTYPE {
    if(swigCPtr != IntPtr.Zero && swigCMemOwn) {
      $jnicall;
      swigCMemOwn = false;
    }
    swigCPtr = IntPtr.Zero;
    GC.SuppressFinalize(this);
  }

%typemap(csdestruct_derived) SWIGTYPE {
    if(swigCPtr != IntPtr.Zero && swigCMemOwn) {
      $jnicall;
      swigCMemOwn = false;
    }
    swigCPtr = IntPtr.Zero;
    GC.SuppressFinalize(this);
    base.Dispose();
  }

%typemap(javagetcptr) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
  internal static IntPtr getCPtr($javaclassname obj) {
    return (obj == null) ? IntPtr.Zero : obj.swigCPtr;
  }
%}

/* Java specific directives */
#define %javaconst(flag)     %feature("java:const","flag")
#define %javamethodmodifiers %feature("java:methodmodifiers")

%javamethodmodifiers "public";

%pragma(java) moduleimports=%{
using System;
%}

%pragma(java) jniclassimports=%{
using System;
using System.Runtime.InteropServices;
%}

/* Some ANSI C typemaps */

%apply long { size_t };

