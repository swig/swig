/* -----------------------------------------------------------------------------
 * csharp.swg
 *
 * CSharp typemaps
 * ----------------------------------------------------------------------------- */

%include <csharphead.swg>

/* The ctype, imtype and cstype typemaps work together and so there should be one of each. 
 * The ctype typemap contains the PInvoke type used in the PInvoke (C/C++) code. 
 * The imtype typemap contains the C# type used in the intermediary class. 
 * The cstype typemap contains the C# type used in the C# proxy classes, type wrapper classes and module class. */

/* Primitive types */
%typemap(ctype) bool,               const bool &               "unsigned int"
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
%typemap(imtype, out="IntPtr") SWIGTYPE "HandleRef"
%typemap(cstype) SWIGTYPE "$&csclassname"

%typemap(ctype) SWIGTYPE [] "void *"
%typemap(imtype, out="IntPtr") SWIGTYPE [] "HandleRef"
%typemap(cstype) SWIGTYPE [] "$csclassname"

%typemap(ctype) SWIGTYPE * "void *"
%typemap(imtype, out="IntPtr") SWIGTYPE * "HandleRef"
%typemap(cstype) SWIGTYPE * "$csclassname"

%typemap(ctype) SWIGTYPE & "void *"
%typemap(imtype, out="IntPtr") SWIGTYPE & "HandleRef"
%typemap(cstype) SWIGTYPE & "$csclassname"

/* pointer to a class member */
%typemap(ctype) SWIGTYPE (CLASS::*) "int"
%typemap(imtype, out="IntPtr") SWIGTYPE (CLASS::*) "HandleRef"
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

%typemap(out, null="") void ""

/* primitive types by const reference */
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
             const double & ($*1_ltype temp)
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
%typemap(in, canthrow=1) SWIGTYPE ($&1_type argp)
%{ argp = ($&1_ltype)$input; 
  if (!argp) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "Attempt to dereference null $1_type", 0);
    return $null;
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
%typemap(in, canthrow=1) SWIGTYPE & %{ $1 = ($1_ltype)$input;
  if(!$1) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "$1_type type is null", 0);
    return $null;
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

%typemap(throws, canthrow=1) int, 
                 long, 
                 short, 
                 unsigned int, 
                 unsigned long, 
                 unsigned short {
  char error_msg[256];
  sprintf(error_msg, "C++ $1_type exception thrown, value: %d", $1);
  SWIG_CSharpSetPendingException(SWIG_CSharpApplicationException, error_msg);
  return $null;
}

%typemap(throws, canthrow=1) SWIGTYPE, SWIGTYPE &, SWIGTYPE *, SWIGTYPE [ANY] %{
  (void)$1;
  SWIG_CSharpSetPendingException(SWIG_CSharpApplicationException, "C++ $1_type exception thrown");
  return $null;
%}

%typemap(throws, canthrow=1) char * %{
  SWIG_CSharpSetPendingException(SWIG_CSharpApplicationException, $1);
  return $null;
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
 * used in the PInvoke class to the type returned by the proxy, module or type wrapper class.
 * The $excode special variable is replaced by the excode typemap attribute code if the
 * method can throw any exceptions from unmanaged code, otherwise replaced by nothing. */

// Macro used by the $excode special variable
%define SWIGEXCODE "\n    if ($imclassname.SWIGPendingException.Pending) throw $imclassname.SWIGPendingException.Retrieve();" %enddef
%define SWIGEXCODE2 "\n      if ($imclassname.SWIGPendingException.Pending) throw $imclassname.SWIGPendingException.Retrieve();" %enddef

%typemap(csout, excode=SWIGEXCODE) bool,               const bool &               {
    bool ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) char,               const char &               {
    char ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) signed char,        const signed char &        {
    sbyte ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) unsigned char,      const unsigned char &      {
    byte ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) short,              const short &              {
    short ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) unsigned short,     const unsigned short &     {
    ushort ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) int,                const int &                {
    int ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) unsigned int,       const unsigned int &       {
    uint ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) long,               const long &               {
    int ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) unsigned long,      const unsigned long &      {
    uint ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) long long,          const long long &          {
    long ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) unsigned long long, const unsigned long long & {
    ulong ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) float,              const float &              {
    float ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) double,             const double &             {
    double ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) char *, char[ANY], char[] {
    string ret = $imcall;$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) void {
    $imcall;$excode
  }
%typemap(csout, excode=SWIGEXCODE) SWIGTYPE {
    $&csclassname ret = new $&csclassname($imcall, true);$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) SWIGTYPE & {
    $csclassname ret = new $csclassname($imcall, $owner);$excode
    return ret;
  }
%typemap(csout, excode=SWIGEXCODE) SWIGTYPE *, SWIGTYPE [], SWIGTYPE (CLASS::*) {
    IntPtr cPtr = $imcall;
    $csclassname ret = (cPtr == IntPtr.Zero) ? null : new $csclassname(cPtr, $owner);$excode
    return ret;
  }


/* Properties */
%typemap(csvarin, excode=SWIGEXCODE2) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
    set {
      $imcall;$excode
    } %}

%typemap(csvarin, excode=SWIGEXCODE2) char *, char[ANY], char[] %{
    set {
      $imcall;$excode
    } %}

%typemap(csvarout, excode=SWIGEXCODE2) bool,               const bool &               %{
    get {
      bool ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) char,               const char &               %{
    get {
      char ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) signed char,        const signed char &        %{
    get {
      sbyte ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) unsigned char,      const unsigned char &      %{
    get {
      byte ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) short,              const short &              %{
    get {
      short ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) unsigned short,     const unsigned short &     %{
    get {
      ushort ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) int,                const int &                %{
    get {
      int ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) unsigned int,       const unsigned int &       %{
    get {
      uint ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) long,               const long &               %{
    get {
      int ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) unsigned long,      const unsigned long &      %{
    get {
      uint ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) long long,          const long long &          %{
    get {
      long ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) unsigned long long, const unsigned long long & %{
    get {
      ulong ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) float,              const float &              %{
    get {
      float ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) double,             const double &             %{
    get {
      double ret = $imcall;$excode
      return ret;
    } %}


%typemap(csvarout, excode=SWIGEXCODE2) char *, char[ANY], char[] %{
    get {
      string ret = $imcall;$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) void %{
    get {
      $imcall;$excode
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) SWIGTYPE %{
    get {
      $&csclassname ret = new $&csclassname($imcall, true);$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) SWIGTYPE & %{
    get {
      $csclassname ret = new $csclassname($imcall, $owner);$excode
      return ret;
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) SWIGTYPE *, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
    get {
      IntPtr cPtr = $imcall;
      $csclassname ret = (cPtr == IntPtr.Zero) ? null : new $csclassname(cPtr, $owner);$excode
      return ret;
    } %}

/* Pointer reference typemaps */
%typemap(ctype) SWIGTYPE *& "void *"
%typemap(imtype, out="IntPtr") SWIGTYPE *& "HandleRef"
%typemap(cstype) SWIGTYPE *& "$*csclassname"
%typemap(csin) SWIGTYPE *& "$*csclassname.getCPtr($csinput)"
%typemap(csout, excode=SWIGEXCODE) SWIGTYPE *& {
    IntPtr cPtr = $imcall;
    $*csclassname ret = (cPtr == IntPtr.Zero) ? null : new $*csclassname(cPtr, $owner);$excode
    return ret;
  }
%typemap(in) SWIGTYPE *& ($*1_ltype temp = 0)
%{ temp = ($*1_ltype)$input;
   $1 = &temp; %}
%typemap(out) SWIGTYPE *&
%{ $result = (void *)*$1; %} 

/* Typemaps used for the generation of proxy and type wrapper class code */
%typemap(csbase)                      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(csclassmodifiers)            SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "public class"
%typemap(cscode)                      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(csimports)                   SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "\nusing System;\nusing System.Runtime.InteropServices;\n"
%typemap(csinterfaces)                SWIGTYPE "IDisposable"
%typemap(csinterfaces)                          SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(csinterfaces_derived)        SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""

// Proxy classes (base classes, ie, not derived classes)
%typemap(csbody) SWIGTYPE %{
  private HandleRef swigCPtr;
  protected bool swigCMemOwn;

  internal $csclassname(IntPtr cPtr, bool cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = new HandleRef(this, cPtr);
  }

  internal static HandleRef getCPtr($csclassname obj) {
    return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
  }
%}

// Derived proxy classes
%typemap(csbody_derived) SWIGTYPE %{
  private HandleRef swigCPtr;

  internal $csclassname(IntPtr cPtr, bool cMemoryOwn) : base($imclassname.$csclassnameUpcast(cPtr), cMemoryOwn) {
    swigCPtr = new HandleRef(this, cPtr);
  }

  internal static HandleRef getCPtr($csclassname obj) {
    return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
  }
%}

// Typewrapper classes
%typemap(csbody) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
  private HandleRef swigCPtr;

  internal $csclassname(IntPtr cPtr, bool futureUse) {
    swigCPtr = new HandleRef(this, cPtr);
  }

  protected $csclassname() {
    swigCPtr = new HandleRef(null, IntPtr.Zero);
  }

  internal static HandleRef getCPtr($csclassname obj) {
    return (obj == null) ? new HandleRef(null, IntPtr.Zero) : obj.swigCPtr;
  }
%}

%typemap(csfinalize) SWIGTYPE %{
  ~$csclassname() {
    Dispose();
  }
%}

%typemap(csconstruct, excode=SWIGEXCODE) SWIGTYPE %{: this($imcall, true) {$excode
  }
%}

%typemap(csdestruct, methodname="Dispose") SWIGTYPE {
    if(swigCPtr.Handle != IntPtr.Zero && swigCMemOwn) {
      swigCMemOwn = false;
      $imcall;
    }
    swigCPtr = new HandleRef(null, IntPtr.Zero);
    GC.SuppressFinalize(this);
  }

%typemap(csdestruct_derived, methodname="Dispose") SWIGTYPE {
    if(swigCPtr.Handle != IntPtr.Zero && swigCMemOwn) {
      swigCMemOwn = false;
      $imcall;
    }
    swigCPtr = new HandleRef(null, IntPtr.Zero);
    GC.SuppressFinalize(this);
    base.Dispose();
  }


/* C# specific directives */
#define %csconst(flag)              %feature("cs:const","flag")
#define %csconstvalue(value)        %feature("cs:constvalue",value)
#define %csenum(wrapapproach)       %feature("cs:enum","wrapapproach")
#define %csmethodmodifiers          %feature("cs:methodmodifiers")
#define %csnothrowexception         %feature("except")
#define %csattributes               %feature("cs:attributes")

%pragma(csharp) imclassclassmodifiers="class"
%pragma(csharp) moduleclassmodifiers="public class"

%pragma(csharp) moduleimports=%{
using System;
using System.Runtime.InteropServices;
%}

%pragma(csharp) imclassimports=%{
using System;
using System.Runtime.InteropServices;
%}

/* Some ANSI C typemaps */

%apply unsigned long { size_t };

/* csharp keywords */
%include <csharpkw.swg>

// Default enum handling
%include <enums.swg>

/*
// Alternative char * typemaps.
%pragma(csharp) imclasscode=%{
  public class SWIGStringMarshal : IDisposable {
    public readonly HandleRef swigCPtr;
    public SWIGStringMarshal(string str) {
      swigCPtr = new HandleRef(this, System.Runtime.InteropServices.Marshal.StringToHGlobalAnsi(str));
    }
    public virtual void Dispose() {
      System.Runtime.InteropServices.Marshal.FreeHGlobal(swigCPtr.Handle);
      GC.SuppressFinalize(this);
    }
  }
%}

%typemap(imtype, out="IntPtr") char *, char[ANY], char[]   "HandleRef"
%typemap(out) char *, char[ANY], char[] %{ $result = $1; %}
%typemap(csin) char *, char[ANY], char[] "new $imclassname.SWIGStringMarshal($csinput).swigCPtr"
%typemap(csout, excode=SWIGEXCODE) char *, char[ANY], char[] {
    string ret = System.Runtime.InteropServices.Marshal.PtrToStringAnsi($imcall);$excode
    return ret;
  }
%typemap(csvarin, excode=SWIGEXCODE2) char *, char[ANY], char[] %{
    set {
      $imcall;$excode
    } %}
%typemap(csvarout, excode=SWIGEXCODE2) char *, char[ANY], char[] %{
    get {
      string ret = System.Runtime.InteropServices.Marshal.PtrToStringAnsi($imcall);$excode
      return ret;
    } %}
*/

