/* -----------------------------------------------------------------------------
 * csharp.swg
 *
 * CSharp typemaps
 * ----------------------------------------------------------------------------- */

%include "csharphead.swg"

/* The ctype, imtype and cstype typemaps work together and so there should be one of each. 
 * The ctype typemap contains the PInvoke type used in the PInvoke (C/C++) code. 
 * The imtype typemap contains the C# type used in the intermediary class. 
 * The cstype typemap contains the C# type used in the C# proxy classes, type wrapper classes and module class. */

/* Primitive types */
%typemap(ctype) bool,               const bool &               "unsigned int"
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
%typemap(ctype) void                                           "void"

%typemap(imtype) bool,               const bool &               "bool"
%typemap(imtype) char,               const char &               "char"
%typemap(imtype) signed char,        const signed char &        "sbyte"
%typemap(imtype) unsigned char,      const unsigned char &      "byte"
%typemap(imtype) short,              const short &              "short"
%typemap(imtype) unsigned short,     const unsigned short &     "ushort"
%typemap(imtype) int,                const int &                "int"
%typemap(imtype) unsigned int,       const unsigned int &       "uint"
%typemap(imtype) long,               const long &               "int"
%typemap(imtype) unsigned long,      const unsigned long &      "uint"
%typemap(imtype) long long,          const long long &          "long"
%typemap(imtype) unsigned long long, const unsigned long long & "ulong"
%typemap(imtype) float,              const float &              "float"
%typemap(imtype) double,             const double &             "double"
%typemap(imtype) void                                           "void"

%typemap(cstype) bool,               const bool &               "bool"
%typemap(cstype) char,               const char &               "char"
%typemap(cstype) signed char,        const signed char &        "sbyte"
%typemap(cstype) unsigned char,      const unsigned char &      "byte"
%typemap(cstype) short,              const short &              "short"
%typemap(cstype) unsigned short,     const unsigned short &     "ushort"
%typemap(cstype) int,                const int &                "int"
%typemap(cstype) unsigned int,       const unsigned int &       "uint"
%typemap(cstype) long,               const long &               "int"
%typemap(cstype) unsigned long,      const unsigned long &      "uint"
%typemap(cstype) long long,          const long long &          "long"
%typemap(cstype) unsigned long long, const unsigned long long & "ulong"
%typemap(cstype) float,              const float &              "float"
%typemap(cstype) double,             const double &             "double"
%typemap(cstype) void                                           "void"

%typemap(ctype) char *, char[ANY], char[]   "char *"
%typemap(imtype) char *, char[ANY], char[]   "string"
%typemap(cstype) char *, char[ANY], char[]   "string"

/* Non primitive types */
%typemap(ctype) SWIGTYPE "void *"
%typemap(imtype) SWIGTYPE "IntPtr"
%typemap(cstype) SWIGTYPE "$&csclassname"

%typemap(ctype) SWIGTYPE [] "void *"
%typemap(imtype) SWIGTYPE [] "IntPtr"
%typemap(cstype) SWIGTYPE [] "$csclassname"

%typemap(ctype) SWIGTYPE * "void *"
%typemap(imtype) SWIGTYPE * "IntPtr"
%typemap(cstype) SWIGTYPE * "$csclassname"

%typemap(ctype) SWIGTYPE & "void *"
%typemap(imtype) SWIGTYPE & "IntPtr"
%typemap(cstype) SWIGTYPE & "$csclassname"

/* pointer to a class member */
%typemap(ctype) SWIGTYPE (CLASS::*) "int"
%typemap(imtype) SWIGTYPE (CLASS::*) "IntPtr"
%typemap(cstype) SWIGTYPE (CLASS::*) "$csclassname"

/* The following are the in and out typemaps. These are the PInvoke code generating typemaps for converting from C# to C and visa versa. */

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
             double
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

/* char * - treat as String */
%typemap(in) char * %{ $1 = $input; %}
%typemap(out) char * %{ $result = SWIG_csharp_string_callback($1); %}

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
%{ argp = ($&1_ltype)$input; 
   if (!argp) {
     SWIG_CSharpThrowException(SWIG_CSharpNullReferenceException, "Attempt to dereference null $1_type");
   }
   $1 = *argp; %}
%typemap(out) SWIGTYPE 
#ifdef __cplusplus
%{$result = new $1_ltype(($1_ltype &)$1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  $result = $1ptr;
}
#endif

/* Generic pointers and references */
%typemap(in) SWIGTYPE * %{ $1 = ($1_ltype)$input; %}
%typemap(in) SWIGTYPE (CLASS::*) %{ $1 = *($&1_ltype)&$input; %}
%typemap(in) SWIGTYPE & %{ $1 = ($1_ltype)$input;
  if(!$1) {
    SWIG_CSharpThrowException(SWIG_CSharpNullReferenceException, "$1_type reference is null");
  } %}
%typemap(out) SWIGTYPE *, SWIGTYPE & %{ $result = (void *)$1; %} 
%typemap(out) SWIGTYPE (CLASS::*) %{ *($&1_ltype)&$result = $1; %} 


/* Default array handling */
%typemap(in) SWIGTYPE [] %{ $1 = ($1_ltype)$input; %}
%typemap(out) SWIGTYPE [] %{ $result = $1; %} 

/* char arrays - treat as String */
%typemap(in) char[ANY], char[] %{ $1 = $input; %}
%typemap(out) char[ANY], char[] %{ $result = SWIG_csharp_string_callback($1); %}


/* Typecheck typemaps - The purpose of these is merely to issue a warning for overloaded C++ functions 
 * that cannot be overloaded in C# as more than one C++ type maps to a single C# type */

%typecheck(SWIG_TYPECHECK_BOOL)
    bool,
    const bool &
    ""

%typecheck(SWIG_TYPECHECK_CHAR)
    char, 
    const char &
    ""

%typecheck(SWIG_TYPECHECK_INT8)
    signed char,
    const signed char &
    ""

%typecheck(SWIG_TYPECHECK_UINT8)
    unsigned char, 
    const unsigned char & 
    ""

%typecheck(SWIG_TYPECHECK_INT16)
    short, 
    const short &
    ""

%typecheck(SWIG_TYPECHECK_UINT16)
    unsigned short, 
    const unsigned short &
    ""

%typecheck(SWIG_TYPECHECK_INT32)
    int, 
    long, 
    const int &, 
    const long &
    ""

%typecheck(SWIG_TYPECHECK_UINT32)
    unsigned int, 
    unsigned long, 
    const unsigned int &, 
    const unsigned long &
    ""

%typecheck(SWIG_TYPECHECK_INT64)
    long long, 
    const long long &
    ""

%typecheck(SWIG_TYPECHECK_UINT64)
    unsigned long long,
    const unsigned long long &
    ""

%typecheck(SWIG_TYPECHECK_FLOAT)
    float,
    const float &
    ""

%typecheck(SWIG_TYPECHECK_DOUBLE)
    double,
    const double &
    ""

%typecheck(SWIG_TYPECHECK_STRING)
    char *,
    char[ANY],
    char[]
    ""

%typecheck(SWIG_TYPECHECK_POINTER)
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
  SWIG_CSharpThrowException(SWIG_CSharpException, error_msg);
}

%typemap(throws) SWIGTYPE, SWIGTYPE &, SWIGTYPE *, SWIGTYPE [ANY] %{
  (void)$1;
  SWIG_CSharpThrowException(SWIG_CSharpException, "C++ $1_type exception thrown");
%}

%typemap(throws) char * %{
  SWIG_CSharpThrowException(SWIG_CSharpException, $1);
%}


/* Typemaps for code generation in proxy classes and C# type wrapper classes */

/* The csin typemap is used for converting function parameter types from the type 
 * used in the proxy, module or type wrapper class to the type used in the PInvoke class. */
%typemap(csin)   bool,               const bool &,
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
                 double,             const double &
    "$csinput"
%typemap(csin) char *, char[ANY], char[] "$csinput"
%typemap(csin) SWIGTYPE "$&csclassname.getCPtr($csinput)"
%typemap(csin) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "$csclassname.getCPtr($csinput)"

/* The csout typemap is used for converting function return types from the return type
 * used in the PInvoke class to the type returned by the proxy, module or type wrapper class. */
%typemap(csout)   bool,               const bool &,
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
                  double,             const double & {
    return $imcall;
  }
%typemap(csout) char *, char[ANY], char[] {
    return $imcall;
  }
%typemap(csout) void {
    $imcall;
  }
%typemap(csout) SWIGTYPE {
    return new $&csclassname($imcall, true);
  }
%typemap(csout) SWIGTYPE & {
    return new $csclassname($imcall, $owner);
  }
%typemap(csout) SWIGTYPE *, SWIGTYPE [], SWIGTYPE (CLASS::*) {
    IntPtr cPtr = $imcall;
    return (cPtr == IntPtr.Zero) ? null : new $csclassname(cPtr, $owner);
  }

/* Properties */
%typemap(csvarin) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
    set {
      $imcall;
    } %}

%typemap(csvarin) char *, char[ANY], char[] %{
    set {
      $imcall;
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
                   double,             const double & %{
    get {
      return $imcall;
    } %}

%typemap(csvarout) char *, char[ANY], char[] %{
    get {
      return $imcall;
    } %}
%typemap(csvarout) void %{
    get {
      $imcall;
    } %}
%typemap(csvarout) SWIGTYPE %{
    get {
      return new $&csclassname($imcall, true);
    } %}
%typemap(csvarout) SWIGTYPE & %{
    get {
      return new $csclassname($imcall, $owner);
    } %}
%typemap(csvarout) SWIGTYPE *, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
    get {
      IntPtr cPtr = $imcall;
      return (cPtr == IntPtr.Zero) ? null : new $csclassname(cPtr, $owner);
    } %}

/* Typemaps used for the generation of proxy and type wrapper class code */
%typemap(csbase)                      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(csclassmodifiers)            SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "public class"
%typemap(cscode)                      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(csimports)                   SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "\nusing System;\n"
%typemap(csinterfaces)                SWIGTYPE "IDisposable"
%typemap(csinterfaces_derived)                  SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""

// Proxy classes (base classes, ie, not derived classes)
%typemap(csbody) SWIGTYPE %{
  private IntPtr swigCPtr;
  protected bool swigCMemOwn;

  internal $csclassname(IntPtr cPtr, bool cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  internal static IntPtr getCPtr($csclassname obj) {
    return (obj == null) ? IntPtr.Zero : obj.swigCPtr;
  }
%}

// Derived proxy classes
%typemap(csbody_derived) SWIGTYPE %{
  private IntPtr swigCPtr;

  internal $csclassname(IntPtr cPtr, bool cMemoryOwn) : base($modulePINVOKE.$csclassnameUpcast(cPtr), cMemoryOwn) {
    swigCPtr = cPtr;
  }

  internal static IntPtr getCPtr($csclassname obj) {
    return (obj == null) ? IntPtr.Zero : obj.swigCPtr;
  }
%}

// Typewrapper classes
%typemap(csbody) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
  private IntPtr swigCPtr;

  internal $csclassname(IntPtr cPtr, bool bFutureUse) {
    swigCPtr = cPtr;
  }

  protected $csclassname() {
    swigCPtr = IntPtr.Zero;
  }

  internal static IntPtr getCPtr($csclassname obj) {
    return (obj == null) ? IntPtr.Zero : obj.swigCPtr;
  }
%}

%typemap(csfinalize) SWIGTYPE %{
  ~$csclassname() {
    Dispose();
  }
%}

%typemap(csdestruct, methodname="Dispose") SWIGTYPE {
    if(swigCPtr != IntPtr.Zero && swigCMemOwn) {
      swigCMemOwn = false;
      $imcall;
    }
    swigCPtr = IntPtr.Zero;
    GC.SuppressFinalize(this);
  }

%typemap(csdestruct_derived, methodname="Dispose") SWIGTYPE {
    if(swigCPtr != IntPtr.Zero && swigCMemOwn) {
      swigCMemOwn = false;
      $imcall;
    }
    swigCPtr = IntPtr.Zero;
    GC.SuppressFinalize(this);
    base.Dispose();
  }


/* C# specific directives */
#define %csconst(flag)              %feature("cs:const","flag")
#define %csconstvalue(value)        %feature("cs:constvalue",value)
#define %csenum(wrapapproach)       %feature("cs:enum","wrapapproach")
#define %csmethodmodifiers          %feature("cs:methodmodifiers")

%pragma(csharp) imclassclassmodifiers="class"
%pragma(csharp) moduleclassmodifiers="public class"

%pragma(csharp) moduleimports=%{
using System;
%}

%pragma(csharp) imclassimports=%{
using System;
using System.Runtime.InteropServices;
%}

/* Some ANSI C typemaps */

%apply long { size_t };

/* csharp keywords */
/* please test and activate */
//%include "csharpkw.swg"

// Default enum handling
%include "enums.swg"

/*
// Alternative char * typemaps
%pragma(csharp) imclasscode=%{
  public class SWIGStringMarshal {
    public readonly IntPtr ptr;
    public SWIGStringMarshal(string str) {
      ptr = System.Runtime.InteropServices.Marshal.StringToHGlobalAnsi(str);
    }
    ~SWIGStringMarshal() {
      System.Runtime.InteropServices.Marshal.FreeHGlobal(ptr);
    }
  }
%}

%typemap(imtype) char *, char[ANY], char[]   "IntPtr"
%typemap(out) char[ANY], char[] %{ $result = $1; %}
%typemap(csin) char *, char[ANY], char[] "new $modulePINVOKE.SWIGStringMarshal($csinput).ptr"
%typemap(csout) char *, char[ANY], char[] {
    return System.Runtime.InteropServices.Marshal.PtrToStringAnsi($imcall);
  }
%typemap(csvarin) char *, char[ANY], char[] %{
    set {
      new $modulePINVOKE.SwigStringMarshal($imcall).ptr;
    } %}
%typemap(csvarout) char *, char[ANY], char[] %{
    get {
      return System.Runtime.InteropServices.Marshal.PtrToStringAnsi($imcall);
    } %}
*/

