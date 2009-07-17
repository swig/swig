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
%typemap(ocpptype) SWIGTYPE (CLASS::*) "" //TBD


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
%typemap(in) char *, char *&
%{ $1 = [$input cStringUsingEncoding: NSStringEncodingConversionAllowLossy]; %} //TBD
%typemap(in) char[ANY]
%{ $1 = [$input cStringUsingEncoding: NSStringEncodingConversionAllowLossy]; %} //TBD
%typemap(in) char[]
%{ $1 = [$input cStringUsingEncoding: NSStringEncodingConversionAllowLossy]; %} //TBD

%typemap(in) SWIGTYPE *
%{ $1 = ($1_ltype)$input; %}
%typemap(in) SWIGTYPE &
%{ $1 = ($1_ltype)$input; %} //TBD
%typemap(in) SWIGTYPE []
%{ $1 = ($1_ltype)$input; %} //TBD
%typemap(in) SWIGTYPE
%{ $1 = ($1_ltype)$input; %} //TBD




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
%typemap(out, null="") void ""


// Pointers, references and arrays
%typemap(out) char * %{ $result = [NSString stringWithCString: $1]; %} //TBD
%typemap(out) SWIGTYPE * %{ $result = (void *)$1; %} 
%typemap(out) SWIGTYPE & %{ $result = (void *)$1; %} 
%typemap(out) SWIGTYPE [] %{ $result = (void *)$1; %} 
%typemap(out) SWIGTYPE    %{ $result = (void *)$1; %} 



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
%typemap(objctype) SWIGTYPE (CLASS::*) "" //TBD



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
%typemap(objcout) bool,              const bool &,
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
{
		$1_ltype ret = $imcall;
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



/* Following are the typemaps used for the generation of proxy and type wrapper class code */
%typemap(objcbase)                      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
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
%typemap(objcinterface_derived) SWIGTYPE ""

%typemap(objcbody_derived) SWIGTYPE %{
 -(void*)getCptr {
	return swigCPtr;
}

-(id)initWithCptr: (void*) cptr{
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


/* Objective-C specific directives */
#define %objcconst(flag)              %feature("objc:const","flag")
#define %objcconstvalue(value)        %feature("objc:constvalue",value)
#define %objcenum(wrapapproach)       %feature("objc:enum","wrapapproach")
#define %objcmethodmodifiers          %feature("objc:methodmodifiers")
#define %objcnothrowexception         %feature("except")
#define %objcattributes               %feature("objc:attributes")
