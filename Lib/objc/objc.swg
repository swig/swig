/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * objc.swg
 *
 * Objective-C typemaps
 * ----------------------------------------------------------------------------- */

%include <objchead.swg>


/* Following are the ObjCpptype typemaps which contain the Objective-C++ types used in the intermediary C code */
/* Primitive types */
%typemap(ObjCpptype) bool,               const bool &               "BOOL"
%typemap(ObjCpptype) char,               const char &               "char"
%typemap(ObjCpptype) signed char,        const signed char &        "signed char"
%typemap(ObjCpptype) unsigned char,      const unsigned char &      "unsigned char"
%typemap(ObjCpptype) short,              const short &              "short"
%typemap(ObjCpptype) unsigned short,     const unsigned short &     "unsigned short"
%typemap(ObjCpptype) int,                const int &                "int"
%typemap(ObjCpptype) unsigned int,       const unsigned int &       "unsigned int"
%typemap(ObjCpptype) long,               const long &               "long"
%typemap(ObjCpptype) unsigned long,      const unsigned long &      "unsigned long"
%typemap(ObjCpptype) long long,          const long long &          "long lon"
%typemap(ObjCpptype) unsigned long long, const unsigned long long & "unsigned long long"
%typemap(ObjCpptype) float,              const float &              "float"
%typemap(ObjCpptype) double,             const double &             "double"
%typemap(ObjCpptype) void                                           "void"

%typemap(ObjCpptype) char *  "NSString *" 
%typemap(ObjCpptype) SWIGTYPE *  "void *" 


/* Following are the "in" typemaps for Objective-C to C conversions */
/* Primitive types */
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

%typemap(in) bool
%{ $1 = $input ? true : false; %}

%typemap(in) char *
%{ $1 = [$input cStringUsingEncoding: NSStringEncodingConversionAllowLossy]; /*this is not proper for now*/ %}

%typemap(in) SWIGTYPE *
%{ $1 = ($1_ltype)$input; %}


/* Following are the "out" typemaps for C to Objective-C conversions */
/* Primitive types */

%typemap(out) bool
%{ $result = (BOOL)$1; %}

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

%typemap(out) SWIGTYPE * %{ $result = (void *)$1; %} 

%typemap(out) char * %{ $result = [NSString stringWithCString: $1]; %}

%typemap(out, null="") void ""
