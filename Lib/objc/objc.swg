/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * objc.swg
 *
 * Objective-C typemaps
 * ----------------------------------------------------------------------------- */

%include <objchead.swg>


/* Following are the ocpptype typemaps which contain the Objective-C or C++ types used in the intermediary C code */
// Primitive types
%typemap(ocpptype) bool,               const bool &               "BOOL"
%typemap(ocpptype) char,               const char &               "char"
%typemap(ocpptype) signed char,        const signed char &        "signed char"
%typemap(ocpptype) unsigned char,      const unsigned char &      "unsigned char"
%typemap(ocpptype) short,              const short &              "short"
%typemap(ocpptype) unsigned short,     const unsigned short &     "unsigned short"
%typemap(ocpptype) int,                const int &                "int"
%typemap(ocpptype) unsigned int,       const unsigned int &       "unsigned int"
%typemap(ocpptype) long,               const long &               "long"
%typemap(ocpptype) unsigned long,      const unsigned long &      "unsigned long"
%typemap(ocpptype) long long,          const long long &          "long long"
%typemap(ocpptype) unsigned long long, const unsigned long long & "unsigned long long"
%typemap(ocpptype) float,              const float &              "float"
%typemap(ocpptype) double,             const double &             "double"
%typemap(ocpptype) void                                           "void"

// Pointers, references and arrays
%typemap(ocpptype) char *, char *&, char[ANY], char[]   "NSString *"
%typemap(ocpptype) SWIGTYPE "void *"
%typemap(ocpptype) SWIGTYPE [] "void *"
%typemap(ocpptype) SWIGTYPE *  "void *" 
%typemap(ocpptype) SWIGTYPE & "void *"

// Pointer to a class member
%typemap(ocpptype) SWIGTYPE (CLASS::*) "void*"


/* Following are the "in" typemaps for Objective-C/C++ to C conversions */
// Primitive types
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
%{ $1 = $input; %}
%typemap(in) bool
%{ $1 = $input ? true : false; %}


// Pointer, references and arrays
%typemap(in, noblock=1) char * {
 $1 = 0;
  if ($input) {
    $1 = [$input cStringUsingEncoding: [NSString defaultCStringEncoding]];
    if (!$1) return $null;
  }
}

%typemap(in, noblock=1) char *& ($*1_ltype temp = 0) {
 $1 = 0;
  if ($input) {
    temp = ($*1_ltype)[$input cStringUsingEncoding: [NSString defaultCStringEncoding]];;
    if (!temp) return $null;
  }
  $1 = &temp;
}


%typemap(in) char[ANY]
%{ $1 = [$input cStringUsingEncoding: [NSString defaultCStringEncoding]]; %}
%typemap(in) char[]
%{ $1 = [$input cStringUsingEncoding: [NSString defaultCStringEncoding]]; %}

%typemap(in) SWIGTYPE *
%{ $1 = ($1_ltype)$input; %}
%typemap(in) SWIGTYPE &
%{ $1 = ($1_ltype)$input; %} //TBD
%typemap(in) SWIGTYPE []
%{ $1 = ($1_ltype)$input; %} //TBD
%typemap(in) SWIGTYPE
%{ $1 = ($1_ltype)$input; %} //TBD

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
             const float & ($*1_ltype temp), 
             const double & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}


/* Default handling. Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE ($&1_type argp)
%{ argp = *($&1_ltype*)&$input; 
   if (!argp) {
		[NSException raise:@"Attempt to dereference null $1_type"];
     return $null;
   }
   $1 = *argp; %}

%typemap(in) SWIGTYPE *, SWIGTYPE (CLASS::*) %{ $1 = *($&1_ltype)&$input; %}
%typemap(in) SWIGTYPE & %{ $1 = *($&1_ltype)&$input;
  if (!$1) {
		[NSException raise:@"$1_type reference is null"];
     return $null;
  } %}
%typemap(in) SWIGTYPE *& ($*1_ltype temp = 0)
%{ temp = *($1_ltype)&$input;
   $1 = &temp; %}


/* Default array handling */
%typemap(in) SWIGTYPE [] %{ $1 = *($&1_ltype)&$input; %}



/* Following are the "out" typemaps for C to Objective-C conversions */
// Primitive types
%typemap(out) bool
%{ $result = $1 ? YES : NO; %}
%typemap(out) char, 
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
%{ $result = $1; %}
%typemap(out) void ""


// Pointers, references and arrays
%typemap(out, noblock=1) char * %{ if ($1) $result = [NSString stringWithCString: $1]; %} //TBD
%typemap(out, noblock=1) char *& %{ if (*$1) $result = [NSString stringWithCString: *$1]; %}
%typemap(out, noblock=1) char[ANY], char[] %{ if ($1) $result = [NSString stringWithCString: $1]; %}



%typemap(out) SWIGTYPE [] %{ $result = (void *)$1; %} 

%typemap(out) SWIGTYPE 
#ifdef __cplusplus
%{ *($&1_ltype*)&$result = new $1_ltype((const $1_ltype &)$1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  *($&1_ltype*)&$result = $1ptr;
}
#endif

%typemap(out) SWIGTYPE *, SWIGTYPE (CLASS::*)
%{ *($&1_ltype)&$result = $1; %} 
%typemap(out) SWIGTYPE &
%{ *($&1_ltype)&$result = $1; %} 

%typemap(out) SWIGTYPE [] %{ *($&1_ltype)&$result = $1; %} 

%typemap(out) SWIGTYPE *&
%{ *($1_ltype)&$result = *$1; %} 



/* Following are the objctype typemaps which contain the Objective-C types used in the proxy code */
// Primitive types
%typemap(objctype) bool,               const bool &               "BOOL"
%typemap(objctype) char,               const char &               "char"
%typemap(objctype) signed char,        const signed char &        "signed char"
%typemap(objctype) unsigned char,      const unsigned char &      "unsigned char"
%typemap(objctype) short,              const short &              "short"
%typemap(objctype) unsigned short,     const unsigned short &     "unsigned short"
%typemap(objctype) int,                const int &                "int"
%typemap(objctype) unsigned int,       const unsigned int &       "unsigned int"
%typemap(objctype) long,               const long &               "long"
%typemap(objctype) unsigned long,      const unsigned long &      "unsigned long"
%typemap(objctype) long long,          const long long &          "long long"
%typemap(objctype) unsigned long long, const unsigned long long & "unsigned long long"
%typemap(objctype) float,              const float &              "float"
%typemap(objctype) double,             const double &             "double"
%typemap(objctype) void                                           "void"

// Pointers, references and arrays
%typemap(objctype) char *, char *&, char[ANY], char[]   "NSString *"
%typemap(objctype) SWIGTYPE "$objcclassname *"
%typemap(objctype) SWIGTYPE [] "NSMutableArray *" //TBD
%typemap(objctype) SWIGTYPE *  "$objcclassname *" 
%typemap(objctype) SWIGTYPE & "$objcclassname *"

// Pointer to a class member
%typemap(objctype) SWIGTYPE (CLASS::*) "$objcclassname" 



/* Following are the "objcin" typemaps for Objective-C to Objective-C++ conversions */
// Primitive types
%typemap(objcin) bool,               const bool &,
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
    "$objcinput"

// Pointers, references and arrays		
%typemap(objcin) char *, char *&, char[ANY], char[] "$objcinput"
%typemap(objcin) SWIGTYPE "[$objcinput getCPtr]"
%typemap(objcin) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] "[$objcinput getCPtr]"
%typemap(objcin) SWIGTYPE (CLASS::*) "" //TBD



/* Following are the "objcout" typemaps for Objective-C++ to Objective-C to conversions */
// Primitive types
%typemap(objcout) char,               const char &,
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
{
		$1_ltype ret = $imcall;
    return ret;
}

%typemap(objcout) bool, const bool & {
	  BOOL ret = $imcall;
    return ret;

}
	
// Pointers, references and arrays		
%typemap(objcout) char *, char *&, char[ANY], char[] {
    NSString *ret = $imcall;
    return ret;
  }
%typemap(objcout) void {
    $imcall;
  }
%typemap(objcout) SWIGTYPE { //TBD
    void *cPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cPtr] autorelease];
    return ret;
  }
%typemap(objcout) SWIGTYPE & { //TBD
		void *cPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cPtr] autorelease];
    return ret;
  }
	
// TBD: below we need to see if this $objcclassname is Class pointer or some other pointer
// Also see the memory management part
%typemap(objcout) SWIGTYPE * {
		void *cPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cPtr] autorelease];
    return ret;
}
%typemap(objcout) SWIGTYPE [] {
		void *cPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cPtr] autorelease];
    return ret;
}
%typemap(objcout) SWIGTYPE (CLASS::*) {
   	void *cMemberPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cMemberPtr] autorelease];
    return ret;
}

%typemap(argout) char[ANY], char[] ""

/* Following are the typemaps used for the generation of proxy and type wrapper class code */
%typemap(objcbase,notderived="")                      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "NSObject"
%typemap(objcclassinterface)            SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "@interface"
%typemap(objcclassimplementation)            SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "@implementation"
%typemap(objccode)                      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(objcimports)                   SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(objcinterfaces)                SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(objcinterfaces_derived)        SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""

// Proxy classes (base classes, ie, not derived classes)
%typemap(objcinterface) SWIGTYPE %{
{
	void *swigCPtr;
	BOOL swigCMemOwn;
}
- (void*)getCptr;
- (id)initWithCptr: (void*) cptr;
%}

%typemap(objcbody) SWIGTYPE %{
- (void*)getCptr {
	return swigCPtr;
}

- (id)initWithCptr: (void*) cptr{
	if(self = [super init]) {
		swigCPtr = cptr;
	}
	return self;
}
%}


// Derived proxy classes
%typemap(objcinterface_derived) SWIGTYPE %{
- (void*)getCptr;
- (id)initWithCptr: (void*) cptr;
%}

%typemap(objcbody_derived) SWIGTYPE %{
- (void*)getCptr {
	return swigCPtr;
}

-(id)initWithCptr: (void*) cptr {
	if(self = [super init]) {
		swigCPtr = cptr;
	}
	return self;
}
%}

// Typewrapper classes
%typemap(interface) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
{
	void *swigCPtr;
	BOOL swigCMemOwn;
}
- (void*)getCptr;
- (id)initWithCptr: (void*) cptr;
%}

%typemap(objcbody) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
- (void*)getCptr {
	return swigCPtr;
}

- (id)init {
	if(self = [super init]) {
		swigCPtr = 0;
	}
	return self;
}

- (id)initWithCptr: (void*) cptr{
	if(self = [super init]) {
		swigCPtr = cptr;
	}
	return self;
}
%}


/* Following are the typemaps used for Objective-C setter and getters for global variables */
// Primitive types
%typemap(objcvarin) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
		$imcall;
%}

// Pointers, references and arrays
%typemap(objcvarin) char *, char *&, char[ANY], char[] %{
		$imcall;
%}

%typemap(objcvarout) bool,              const bool &,
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
%{
		$1_ltype ret = $imcall;
    return ret;
%}

%typemap(objcvarout) char *, char *&, char[ANY], char[] %{
		NSString* ret = $imcall;
    return ret;
%}

%typemap(objcvarout) void %{
    $imcall;
%}

%typemap(objcvarout) SWIGTYPE { //TBD
    void *cPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cPtr] autorelease];
    return ret;
}
	
%typemap(objcvarout) SWIGTYPE & { //TBD
		void *cPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cPtr] autorelease];
    return ret;
}
	
// TBD: below we need to see if this $objcclassname is Class pointer or some other pointer
// Also see the memory management part
%typemap(objcvarout) SWIGTYPE * {
		void *cPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cPtr] autorelease];
    return ret;
}
%typemap(objcvarout) SWIGTYPE [] {
		void *cPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cPtr] autorelease];
    return ret;
}
%typemap(objcvarout) SWIGTYPE (CLASS::*) {
   	void *cMemberPtr = $imcall;
		$objcclassname ret = (cPtr == NULL) ? NIL : [[[$objcclassname] initWithCptr: cMemberPtr] autorelease];
    return ret;
}

/*
 * Objective-C constructor and destructor typemaps:
 *
 * The objcconstruct typemap is inserted when a proxy class's constructor is generated.
 * This typemap allows control over what code is executed in the constructor as
 * well as specifying who owns the underlying C/C++ object. Normally, Objective-C has
 * ownership and the underlying C/C++ object is deallocated when the Objective-C object
 * is deallocated (swigCMemOwn is true.) If swigCMemOwn is false, C/C++ is
 * ultimately responsible for deallocating the underlying object's memory.
 *
 */

%typemap(objcconstruct) SWIGTYPE {
	if(self = [super init]) {
		swigCPtr = $imcall;
	}
	return self;
}

%typemap(objcdestruct, methodname="dealloc") SWIGTYPE {
  if (swigCPtr != 0) {
	  if (swigCMemOwn) {
		  swigCMemOwn = false;
      $imcall;
	  }
    swigCPtr = 0;
  }
  [super dealloc];
}




/* Typecheck typemaps - The purpose of these is merely to issue a warning for overloaded C++ functions 
 * that cannot be overloaded in Objective-C as more than one C++ type maps to a single Objective-C type */

%typecheck(SWIG_TYPECHECK_BOOL) /* Objective-C boolean */
    BOOL,
    bool,
    const bool &
    ""

%typecheck(SWIG_TYPECHECK_CHAR) /* Objective-C char */
    char, 
    const char &
    ""

%typecheck(SWIG_TYPECHECK_INT8) /* Objective-C byte */
    signed char,
    const signed char &
    ""

%typecheck(SWIG_TYPECHECK_INT16) /* Objective-C short */
    unsigned char, 
    short, 
    const unsigned char &, 
    const short &
    ""

%typecheck(SWIG_TYPECHECK_INT32) /* Objective-C int */
    unsigned short, 
    int, 
    long, 
    const unsigned short &, 
    const int &, 
    const long &
    ""

%typecheck(SWIG_TYPECHECK_INT64) /* Objective-C long */
    unsigned int, 
    unsigned long, 
    long long, 
    const unsigned int &, 
    const unsigned long &, 
    const long long &
    ""

%typecheck(SWIG_TYPECHECK_INT128) /* Objective-C BigInteger */
    unsigned long long,
    const unsigned long long &
    ""

%typecheck(SWIG_TYPECHECK_FLOAT) /* Objective-C float */
    float,
    const float &
    ""

%typecheck(SWIG_TYPECHECK_DOUBLE) /* Objective-C double */
    double,
    const double &
    ""

%typecheck(SWIG_TYPECHECK_STRING) /* Objective-C String */
    char *,
    char *&,
    char[ANY],
    char []
    ""

%typecheck(SWIG_TYPECHECK_POINTER) /* Default */
    SWIGTYPE, 
    SWIGTYPE *, 
    SWIGTYPE &, 
    SWIGTYPE [],
    SWIGTYPE (CLASS::*)
    ""


// Exception handling

%typemap(throws) int, 
                 long, 
                 short, 
                 unsigned int, 
                 unsigned long, 
                 unsigned short
%{ NString* aFormat = [NSString stringWithString:@"The value is %d"];
	[NSException raise:@"$1_type exception" format: aFormat, $1] %}

%typemap(throws) SWIGTYPE, SWIGTYPE &, SWIGTYPE *, SWIGTYPE [], SWIGTYPE [ANY]
%{ NString* aFormat = [NSString stringWithString:@"The value is %d"];
	[NSException raise:@"$1_type exception" format: aFormat, $1] %}
	
%typemap(throws) char *
%{ NString* aFormat = [NSString stringWithString:@"%s"];
	[NSException raise:@"$1_type exception" format: aFormat, $1] %}


// Objective-C specific directives
#define %objcconst(flag)              %feature("objc:const","flag")
#define %objcconstvalue(value)        %feature("objc:constvalue",value)
#define %objcenum(wrapapproach)       %feature("objc:enum","wrapapproach")
#define %objcmethodmodifiers          %feature("objc:methodmodifiers")
#define %objcnothrowexception         %feature("except")
#define %objcattributes               %feature("objc:attributes")

// Some ANSI C typemaps
%apply unsigned long { size_t };
%apply const unsigned long & { const size_t & };
	
// Default enum handling
%include <enums.swg>

