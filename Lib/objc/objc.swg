/* -----------------------------------------------------------------------------
 * objc.swg
 *
 * Objective-C module typemaps: 
 * Note that the intermediate layer (ObjectiveC++) is essentially a C layer with the 
 * C++ specific code (such as references) converted to the C code. Since ObjectiveC
 * layer can handle C as is, this makes sense - at least until we decide on something 
 * more appropriate.

 * ----------------------------------------------------------------------------- */

/* 
 * IMTYPE TYPEMAPS: Represents the ObjectiveC++ type corresponding to each C++ type. 
 */
 
// Primary types: ObjectiveC++ understands C primary types.
%typemap(imtype) char               "char"
%typemap(imtype) signed char        "signed char"
%typemap(imtype) unsigned char      "unsigned char"
%typemap(imtype) short              "short"
%typemap(imtype) unsigned short     "unsigned short"
%typemap(imtype) int                "int"
%typemap(imtype) unsigned int       "unsigned int"
%typemap(imtype) long               "long"
%typemap(imtype) unsigned long      "unsigned long"
%typemap(imtype) long long          "long long"
%typemap(imtype) unsigned long long "unsigned long long"
%typemap(imtype) float              "float"
%typemap(imtype) double             "double"
%typemap(imtype) void               "void"

// References to primitive types are treated as pointers in the wrapper(ObjectiveC++) layer.
%typemap(imtype) const char &,              char &                  "char *"
%typemap(imtype) const signed char &, 		signed char &           "signed char *"
%typemap(imtype) const unsigned char &, 	unsigned char &         "unsigned char *"
%typemap(imtype) const short &,				short &                 "short *"
%typemap(imtype) const unsigned short &,	unsigned short &        "unsigned short *"
%typemap(imtype) const int &,		    	int &                   "int *"
%typemap(imtype) const unsigned int &,		unsigned int &          "unsigned int *"
%typemap(imtype) const long &,				long &                  "long *"
%typemap(imtype) const unsigned long &, 	unsigned long &         "unsigned long  *"
%typemap(imtype) const long long &, 		long long &             "long long *"
%typemap(imtype) const unsigned long long &,unsigned long long &    "unsigned long long  *"
%typemap(imtype) const float &, 			float &                 "float *"
%typemap(imtype) const double &,  			double &                "double *"

// Booleans
%typemap(imtype) bool               					"BOOL"
%typemap(imtype) const bool &, bool &, const bool *, bool *             "BOOL *"

//C strings:
%typemap(imtype) char *, const char *, char[ANY], char[]              "NSString *"
%typemap(imtype) char *&                                "NSString *"


// Objects will always be treated as pointers in ObjectiveC++
%typemap(imtype) SWIGTYPE                               "void*" 

// C/C++ prinitve pointers are treated as is in ObjectiveC++
// References to primitive types are treated as pointers in the wrapper(ObjectiveC++) layer.
%typemap(imtype) const signed char *, 		signed char *           "signed char *"
%typemap(imtype) const unsigned char *, 	unsigned char *         "unsigned char *"
%typemap(imtype) const short *,				short *                 "short *"
%typemap(imtype) const unsigned short *,	unsigned short *        "unsigned short *"
%typemap(imtype) const int *,		    	int *                   "int *"
%typemap(imtype) const unsigned int *,		unsigned int *          "unsigned int *"
%typemap(imtype) const long *,				long *                  "long *"
%typemap(imtype) const unsigned long *, 	unsigned long *         "unsigned long  *"
%typemap(imtype) const long long *, 		long long *             "long long *"
%typemap(imtype) const unsigned long long *,unsigned long long *    "unsigned long long  *"
%typemap(imtype) const float *, 			float *                 "float *"
%typemap(imtype) const double *,  			double *                "double *"

// C/C++ object Pointers, are treated as void* in ObjectiveC++
%typemap(imtype) SWIGTYPE *                             "void*"

// Arrays for non-primitive types
%typemap(imtype) SWIGTYPE []                            "void*"

// Pointer to a class member will be void*
%typemap(imtype) SWIGTYPE (CLASS::*)                    "void*"  

// References to non-primitive types
%typemap(imtype) SWIGTYPE &                             "void*"
%typemap(imtype) SWIGTYPE *const&                       "void*"

// Function pointers
%typemap(imtype) SWIGTYPE ((*)(ANY))                    "void*"


/* 
 * IN TYPEMAPS: Used for "in" arguments type conversions: ObjectiveC++ to C++.
 */
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

// No "in" for void
%typemap(in) void ""

// References: are treated as pointers in the wrapper layer (ObjectiveC++)
%typemap(in)	const char &,  			char &,
	     	 const signed char &, 		signed char &,
	         const unsigned char &, 	unsigned char &,
		     const short &,				short &,
		     const unsigned short &,	unsigned short &,
		     const int &,		    	int &,
		     const unsigned int &,		unsigned int &,
			 const long &,				long &,
	     	 const unsigned long &, 	unsigned long &,
	     	 const long long &, 		long long &,
	     	 const unsigned long long &,unsigned long long &,
	      	 const float &, 			float &,
	      	 const double &,  			double &
%{ $1 = ($1_ltype)$input; %}

%typemap(in) const signed char *, 		signed char *,           
 	const unsigned char *, 	        unsigned char *,         
 	const short *,				short *,                 
 	const unsigned short *,	        unsigned short *,        
 	const int *,		    	int *,                   
 	const unsigned int *,		unsigned int *,          
 	const long *,				long *,                 
 	const unsigned long *, 	        unsigned long *,         
 	const long long *, 		long long *,             
 	const unsigned long long *,     unsigned long long *,    
 	const float *, 			float *,               
 	const double *,  	        double *        
%{ $1 = ($1_ltype)$input;%}

//Booleans:
%typemap(in) bool
%{ $1 = $input? true : false; %}

%typemap(in) bool * (bool temp), const bool * (bool temp), const bool & (bool temp), bool & (bool temp) {
  temp = (*input) ? true : false;
  $1 = &temp;
}


//C strings:
%typemap(in) char *, char[ANY], char[]  {
 $1 = 0;
  if ($input) { // TODO: Find a better way to do this!
		int length = [$input length];
		int bufferSize = sizeof(char) * (length + 1);
		char *buffer = (char*)malloc(bufferSize);
		memset(buffer, 0, bufferSize);
		int i = 0;
		for (; i < length; ++i)
			buffer[i] = [$input characterAtIndex: i];
			$1 = ($1_ltype)buffer;
	}
}

%typemap(in) char *& ($*1_ltype temp = 0) {
 $1 = 0;
  if ($input) { // TODO: Find a better way to do this!
		int length = [$input length];
		int bufferSize = sizeof(char) * (length + 1);
		char *buffer = (char*)malloc(bufferSize);
		memset(buffer, 0, bufferSize);
		int i = 0;
		for (; i < length; ++i)
			buffer[i] = [$input characterAtIndex: i];
    temp = ($*1_ltype)buffer;
    if (!temp) return NULL;
  }
  $1 = &temp;
}

// Objects passed by value: convert from a pointer to the C++ value object.
%typemap(in) SWIGTYPE ($&1_type argp)	
%{ 
  argp = ($&1_ltype)$input;
  $1 = *argp; 
%}

// C/C++ Pointers, primary and object, are treated as pointers in ObjectiveC++
%typemap(in) SWIGTYPE *
%{ $1 = ($1_ltype)$input; %}
   
// Object References
%typemap(in) SWIGTYPE &
%{ $1 = ($1_ltype)$input; %}

%typemap(in) SWIGTYPE *const& ($*1_ltype temp = 0)
%{ temp = *($1_ltype)&$input;
   $1 = ($1_ltype)&temp; %}
   
// Array conversion typemap
%typemap(in) SWIGTYPE [] %{ $1 = ($1_ltype)$input; %}

// Pointer to a class member will be passed as void*, convert appropriately
%typemap(in) SWIGTYPE (CLASS::*)
%{ $1 = *($&1_ltype)$input; %}

// Function pointers
%typemap(in) SWIGTYPE ((*)(ANY))
%{ $1 = ($1_ltype)$input; %}

%typemap(in) SWIGTYPE *& ($*1_ltype temp = 0)
%{ temp = *($1_ltype)&$input;
   $1 = &temp; %}

/*
 * OUT TYPEMAPS: Used for return-type type conversions: C++ to ObjectiveC++
 */
//Primary types
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

// References as exported as pointers (by default)
%typemap(out)const char &,  			char &,
	     	 const signed char &, 		signed char &,
	         const unsigned char &, 	unsigned char &,
		     const short &,				short &,
		     const unsigned short &,	unsigned short &,
		     const int &,		    	int &,
		     const unsigned int &,		unsigned int &,
			 const long &,				long &,
	     	 const unsigned long &, 	unsigned long &,
	     	 const long long &, 		long long &,
	     	 const unsigned long long &,unsigned long long &,
	      	 const float &, 			float &,
	      	 const double &,  			double &
%{ $result = $1; %}


%typemap(out)const char *,  			char *,
	     	 const signed char *, 		signed char *,
	         const unsigned char *, 	unsigned char *,
		     const short *,				short *,
		     const unsigned short *,	unsigned short *,
		     const int *,		    	int *,
		     const unsigned int *,		unsigned int *,
			 const long *,				long *,
	     	 const unsigned long *, 	unsigned long *,
	     	 const long long *, 		long long *,
	     	 const unsigned long long *,unsigned long long *,
	      	 const float *, 			float *,
	      	 const double *,  			double *
%{ $result = $1; %}

// Booleans:
%typemap(out) bool
%{  $result = ($1)? YES:NO; %}

%typemap(out) bool& (BOOL temp), bool* (BOOL temp), const bool& (BOOL temp), const bool& (BOOL temp)
%{  temp = (*$1)? YES:NO;
    BOOL* ret = &temp;
    return ret; %}

// C strings: 
%typemap(out)const char *,char * %{ if ($1) $result = [NSString stringWithUTF8String: (const char*)$1]; %}
%typemap(out) char *& %{ if (*$1) $result = [NSString stringWithUTF8String: (const char*)*$1]; %}
%typemap(out) char[ANY], char[] %{ if ($1) $result = [NSString stringWithUTF8String: (const char*)$1]; %}

// Objects returned by value: convert to a pointer.
%typemap(out) SWIGTYPE ($&1_type temp)
#ifdef __cplusplus
%{
  temp = new $1_ltype((const $1_ltype &)$1); 
  $result = (void*)temp;
%}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  temp = $1ptr;
  $result = (void*)temp;
}
#endif

// Pointer objects are returned as void* in the ObjectiveC++ layer
%typemap(out) SWIGTYPE *, SWIGTYPE & 
%{ $result = (void*)$1; %}

%typemap(out) SWIGTYPE [] %{ $result = $1; %}

// Pointer to a class member 
%typemap(out) SWIGTYPE (CLASS::*) 
%{ *($&1_ltype)$result =$1; %}

%typemap(out) SWIGTYPE *const&
%{ $result = (void *)*$1; %}

// Function pointers
%typemap(out) SWIGTYPE ((*)(ANY))
%{ $result = (void*)$1; %}

%typemap(out) SWIGTYPE *&
%{ $result = (void*)*$1; %} 

/* 
 * OBJCTYPE TYPEMAPS: Represents the ObjectiveC(proxy) type corresponding to each ObjectiveC++ type in the intermediate(wrapper) layer. 
 */
// Primary types
%typemap(objctype)  bool               "BOOL"
%typemap(objctype)  char               "char"
%typemap(objctype)  signed char        "signed char"
%typemap(objctype)  unsigned char      "unsigned char"
%typemap(objctype)  short              "short"
%typemap(objctype)  unsigned short     "unsigned short"
%typemap(objctype)  int                "int"
%typemap(objctype)  unsigned int       "unsigned int"
%typemap(objctype)  long               "long"
%typemap(objctype)  unsigned long      "unsigned long"
%typemap(objctype)  long long          "long long"
%typemap(objctype)  unsigned long long "unsigned long long"
%typemap(objctype)  float              "float"
%typemap(objctype)  double             "double"
%typemap(objctype)  void               "void"

// References will always be treated as pointers in the proxy layer (ObjectiveC)
%typemap(objctype) const bool &,              bool &                  "BOOL *"
%typemap(objctype) const char &,              char &                  "char *"
%typemap(objctype) const signed char &, 		signed char &           "signed char *"
%typemap(objctype) const unsigned char &, 	unsigned char &         "unsigned char *"
%typemap(objctype) const short &,				short &                 "short *"
%typemap(objctype) const unsigned short &,	unsigned short &        "unsigned short *"
%typemap(objctype) const int &,		    	int &                   "int *"
%typemap(objctype) const unsigned int &,		unsigned int &          "unsigned int *"
%typemap(objctype) const long &,				long &                  "long *"
%typemap(objctype) const unsigned long &, 	unsigned long &         "unsigned long  *"
%typemap(objctype) const long long &, 		long long &             "long long *"
%typemap(objctype) const unsigned long long &,unsigned long long &    "unsigned long long  *"
%typemap(objctype) const float &, 			float &                 "float *"
%typemap(objctype) const double &,  			double &                "double *"

//C strings:
%typemap(objctype) char *, const char *, char *&, char[ANY], char[]    "NSString *"

// Objects will always be treated as pointers in ObjectiveC
%typemap(objctype) SWIGTYPE                             "$objcclassname*"

// C/C++ Pointers to primitive types are treated as is
// C/C++ prinitve pointers are treated as is in ObjectiveC++
// References to primitive types are treated as pointers in the wrapper(ObjectiveC++) layer.
%typemap(objctype) const bool *,              bool *                  "BOOL *"
%typemap(objctype) const signed char *, 		signed char *           "signed char *"
%typemap(objctype) const unsigned char *, 	unsigned char *         "unsigned char *"
%typemap(objctype) const short *,				short *                 "short *"
%typemap(objctype) const unsigned short *,	unsigned short *        "unsigned short *"
%typemap(objctype) const int *,		    	int *                   "int *"
%typemap(objctype) const unsigned int *,		unsigned int *          "unsigned int *"
%typemap(objctype) const long *,				long *                  "long *"
%typemap(objctype) const unsigned long *, 	unsigned long *         "unsigned long  *"
%typemap(objctype) const long long *, 		long long *             "long long *"
%typemap(objctype) const unsigned long long *,unsigned long long *    "unsigned long long  *"
%typemap(objctype) const float *, 			float *                 "float *"
%typemap(objctype) const double *,  			double *                "double *"

// C/C++ Pointers are treated as  as pointers in ObjectiveC
%typemap(objctype) SWIGTYPE *                           "$objcclassname*" 

// Arrays to non-primitive types
%typemap(objctype) SWIGTYPE []                          "$objcclassname*"

// Pointer to a class member
%typemap(objctype) SWIGTYPE (CLASS::*)                  "$objcclassname*"  

// References to non-primitive types
%typemap(objctype) SWIGTYPE &                           "$objcclassname*"
%typemap(objctype) SWIGTYPE *const&                     "$objcclassname*"

// Function pointers
%typemap(objctype) SWIGTYPE ((*)(ANY))                  "$objcclassname*"


/* 
 * OBJCIN TYPEMAPS: Used for "in" arguments type conversions from ObjectiveC(proxy) layer to ObjectiveC++(wrapper) layer.
 */

// Primary types
%typemap(objcin) bool,
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
             double
"$objcinput"

// No "objcin" for void
%typemap(objcin) void ""

// References: are treated as pointers in the proxy layer (ObjectiveC)
%typemap(objcin) const bool &,                  bool &, 
                 const char &,  		char &,
	     	 const signed char &, 		signed char &,
	         const unsigned char &, 	unsigned char &,
		     const short &,				short &,
		     const unsigned short &,	unsigned short &,
		     const int &,		    	int &,
		     const unsigned int &,		unsigned int &,
			 const long &,				long &,
	     	 const unsigned long &, 	unsigned long &,
	     	 const long long &, 		long long &,
	     	 const unsigned long long &,unsigned long long &,
	      	 const float &, 			float &,
	      	 const double &,  			double &
"$objcinput"

// C/C++ pointers to primitive types are treated as is in the Proxy layer.
%typemap(objcin)const bool *,              bool *,
             const char *,  			char *,
	     	 const signed char *, 		signed char *,
	         const unsigned char *, 	unsigned char *,
		     const short *,				short *,
		     const unsigned short *,	unsigned short *,
		     const int *,		    	int *,
		     const unsigned int *,		unsigned int *,
			 const long *,				long &,
	     	 const unsigned long *, 	unsigned long &,
	     	 const long long *, 		long long *,
	     	 const unsigned long long *,unsigned long long *,
	      	 const float *, 			float *,
	      	 const double *,  			double *
"$objcinput"

//C strings:
%typemap(objcin) char *, char[ANY], char[]  "$objcinput"
%typemap(objcin) char *&                    "$objcinput"

// Objects passed by value: Convert from an ObjectiveC pointer to the ObjectiveC++ void* pointer.
%typemap(objcin) SWIGTYPE "[$objcinput getCptr]"

// C/C++ Pointers, primary and object, are exported as ObjectiveC pointers
%typemap(objcin) SWIGTYPE *, SWIGTYPE & "[$objcinput getCptr]"
%typemap(objcin) SWIGTYPE "[$objcinput getCptr]"

// Pointer to a class member will be passed as void*, convert appropriately
%typemap(objcin) SWIGTYPE (CLASS::*) "[$objcinput getCptr]" 

%typemap(objcin) SWIGTYPE *const& "[$objcinput getCptr]" 

/*
 * OBJCOUT TYPEMAPS: Used for return-type type conversions: ObjectiveC++(wrapper) to ObjectiveC(proxy)
 */

// Primary types are exported as ObjectiveC primary types
%typemap(objcout) bool,
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
	      double
%{ return $imcall; %}

%typemap(objcout) void "$imcall;"

%typemap(objcout) const bool &,         bool &,
             const char &,  			char &,
	     	 const signed char &, 		signed char &,
	         const unsigned char &, 	unsigned char &,
		     const short &,				short &,
		     const unsigned short &,	unsigned short &,
		     const int &,		    	int &,
		     const unsigned int &,		unsigned int &,
			 const long &,				long &,
	     	 const unsigned long &, 	unsigned long &,
	     	 const long long &, 		long long &,
	     	 const unsigned long long &,unsigned long long &,
	      	 const float &, 			float &,
	      	 const double &,  			double &
%{ return $imcall; %}

%typemap(objcout)const bool *,              bool *,
             const char *,  			char *,
	     	 const signed char *, 		signed char *,
	         const unsigned char *, 	unsigned char *,
		     const short *,				short *,
		     const unsigned short *,	unsigned short *,
		     const int *,		    	int *,
		     const unsigned int *,		unsigned int *,
			 const long *,				long *,
	     	 const unsigned long *, 	unsigned long *,
	     	 const long long *, 		long long *,
	     	 const unsigned long long *,unsigned long long *,
	      	 const float *, 			float *,
	      	 const double *,  			double *
%{ return $imcall; %}

// C strings: 
%typemap(objcout)const char *,char * 
%{  NSString *ret = $imcall;
    return ret; %}

%typemap(objcout) char *& 
%{  NSString *ret = $imcall;
    return ret; %}

%typemap(objcout) char[ANY], char[] 
%{  NSString *ret = $imcall;
    return ret; %}

// Objects returned by value: Convert the void* pointer to the ObjectiveC pointer.
// Here, for now, we presume that the returned C++ pointers will not have to be deleted by the client directly
// As such, we mark swigOwnCObject as NO. This has to be reviewed again.
%typemap(objcout) SWIGTYPE
%{   void* cPtr = $imcall;
     $objcclassname* ret = nil;
     if(cPtr) {
        ret = [[[$objcclassname alloc] initWithCptr:cPtr swigOwnCObject:NO] autorelease];
     }
    return ret; %}

// Pointer objects are returned as ObjectiveC pointers
// Here, for now, we presume that the returned C++ pointers will not have to be deleted by the client directly
// As such, we mark swigOwnCObject as NO. This has to be reviewed again.
%typemap(objcout) SWIGTYPE &
%{   void* cPtr = $imcall;
     $objcclassname* ret = nil;
     if(cPtr) {
        ret = [[[$objcclassname alloc] initWithCptr:cPtr swigOwnCObject:NO] autorelease];
     }
    return ret; %}
	
%typemap(objcout) SWIGTYPE *
%{   void* cPtr = $imcall;
     $objcclassname* ret = nil;
     if(cPtr) {
        ret = [[[$objcclassname alloc] initWithCptr:cPtr swigOwnCObject:NO] autorelease];
     }
    return ret; %}
    
// C function pointer
%typemap(objcout) SWIGTYPE ((*)(ANY)) 
%{   void* cPtr = $imcall;
     $objcclassname* ret = nil;
     if(cPtr) {
        ret = [[[$objcclassname alloc] initWithCptr:cPtr swigOwnCObject:NO] autorelease];
     }
    return ret; %}
    
%typemap(objcvarout) SWIGTYPE ((*)(ANY)) 
%{ $objcclassname* $objcvarname = [[[$objcclassname alloc] initWithCptr:($imcall) swigOwnCObject:NO] autorelease]; %}

// Pointer to a class member will be returned as id
%typemap(objcout) SWIGTYPE (CLASS::*) 
%{   void* cPtr = $imcall;
     $objcclassname* ret = nil;
     if(cPtr) {
        ret = [[[$objcclassname alloc] initWithCptr:cPtr swigOwnCObject:NO] autorelease];
     }
    return ret; %}

%typemap(objcout) SWIGTYPE *const& 
%{   void* cPtr = $imcall;
     $objcclassname* ret = nil;
     if(cPtr) {
        ret = [[[$objcclassname alloc] initWithCptr:cPtr swigOwnCObject:NO] autorelease];
     }
    return ret; %}
 
/* apply typemaps */
// Treat references to arrays like like references to a single element.
%apply SWIGTYPE & { SWIGTYPE ((&)[ANY]) }
%apply unsigned long { size_t };
%apply const unsigned long & { const size_t & };

/* const pointers */
%apply SWIGTYPE * { SWIGTYPE *const }

/* Exception handling */
 
%typemap(throws) int, 
                 long, 
                 short, 
                 unsigned int, 
                 unsigned long, 
                 unsigned short
%{ char error_msg[256];
   sprintf(error_msg, "C++ $1_type exception thrown, value: %d", $1);
   SWIG_ObjcThrowException(SWIG_ObjcRuntimeException, error_msg);
   return $null; %}
 
%typemap(throws) SWIGTYPE, SWIGTYPE &, SWIGTYPE *, SWIGTYPE [], SWIGTYPE [ANY]
%{ (void)$1;
   SWIG_ObjcThrowException(SWIG_ObjcRuntimeException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(throws) char *
%{ SWIG_ObjcThrowException(SWIG_ObjcRuntimeException, $1);
   return $null; %}


#define %objcexception(exceptionclasses) %feature("except",throws=exceptionclasses)
#define %noobjcexception            %feature("except","0",throws="")
#define %clearobjcexception         %feature("except","",throws="")

/* Additional typemaps */
// Typemaps containing ObjectiveC code used when generating ObjectiveC proxy classes.
%include <objcproxycode.swg>

// Typemaps for handling enums
%include <objcenums.swg>

// ObjectiveC runtime support code.
%include <objcruntime.swg>

// List of all reserved ObjectiveC keywords.
%include <objckw.swg>
