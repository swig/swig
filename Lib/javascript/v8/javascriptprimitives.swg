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
%{ $1 = ($1_ltype)JSValueToNumber(context, $input, NULL); %}			

%typemap(in) const bool &, 			bool &,
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
%{ $1 = ($1_ltype)&$input; %}

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
%{ $result = JSValueMakeNumber(context, $1); %}

%typemap(out) const bool &, 			bool &,
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
%{ $result = JSValueMakeNumber(context,*$1); %}


%typemap(in) short *, 
             unsigned short *, 
             int *, 
             unsigned int *, 
             long *, 
             unsigned long *, 
             long long *, 
             unsigned long long *,
             float *, 
             double *
%{
  JSObjectRef o$1 = JSValueToObject(context,$input, NULL);
  SWIG_PRV_DATA *$1_privatedata = (SWIG_PRV_DATA *)JSObjectGetPrivate(o$1);
  $1 = ($1_ltype)$1_privatedata->swigCObject;
%}


%typemap(out) short *, 
             unsigned short *, 
             int *, 
             unsigned int *, 
             long *, 
             unsigned long *, 
             long long *, 
             unsigned long long *,
             float *, 
             double *
%{
  SWIG_PRV_DATA *privatedata = new SWIG_PRV_DATA();
  privatedata->swigCMemOwn = false;
  privatedata->swigCObject = result;
  $result = JSObjectMake(context, _wrap_swig_ptr_$*1_ltype_createJSClass(context), privatedata);
%}

%typemap(in) bool
%{
  $1 = ($1_ltype)JSValueToBoolean(context, $input); 
%} 

%typemap(out) bool
%{
  $result = JSValueMakeBoolean(context, $1);
%} 


%typemap(out) void
%{ $result = JSValueMakeUndefined(context); %}


%typemap(in) char *
%{
  JSStringRef $1_str = JSValueToStringCopy(context, $input, NULL);
  size_t $1_strsize = JSStringGetMaximumUTF8CStringSize($1_str);
  $1 = (char *)malloc($1_strsize * sizeof(char));
  JSStringGetUTF8CString($1_str, $1, $1_strsize);
%}

%typemap(out) char *
%{
  JSStringRef jsstring = JSStringCreateWithUTF8CString($1);
  $result = JSValueMakeString(context, jsstring);
  JSStringRelease(jsstring);
%}

%typemap(arginit) char * ""

%typemap(in) char *& ($*1_ltype temp = 0) %{ 
    temp = ($*1_ltype)$input;
    JSStringRef $1_str = JSValueToStringCopy(context, $input, NULL);
    size_t $1_strsize = JSStringGetMaximumUTF8CStringSize($1_str);
    $1 = (char *)malloc($1_strsize * sizeof(char));
    JSStringGetUTF8CString($1_str, $1, $1_strsize);
%}

%typemap(out) char *& 
%{ 
  JSStringRef jsstring = JSStringCreateWithUTF8CString((const char *)*$1);
  $result = JSValueMakeString(context, jsstring);
  JSStringRelease(jsstring);
%}

/* char arrays - treat as String */
%typemap(in) char[ANY], char[] %{
    JSStringRef $1_str = JSValueToStringCopy(context, $input, NULL);
	size_t $1_strsize = JSStringGetMaximumUTF8CStringSize($1_str);
    JSStringGetUTF8CString($1_str, $1, $1_strsize);
%}

%typemap(out) char[ANY], char[] 
%{
  JSStringRef jsstring = JSStringCreateWithUTF8CString($1);
  $result = JSValueMakeString(context, jsstring);
  JSStringRelease(jsstring);
%}

%typemap(freearg) char *, char *&, char[ANY], char[] //TODO: Not working: A memory leak
%{ free($1); %}


/* Typemaps for composite types */
%typemap(in) SWIGTYPE ($&1_type argp)	// Objects passed by value, convert to a pointer
%{ 
  JSObjectRef o$1 = JSValueToObject(context,$input, NULL);
  SWIG_PRV_DATA *$1_privatedata = (SWIG_PRV_DATA *)JSObjectGetPrivate(o$1);
  argp = ($&1_ltype)$1_privatedata->swigCObject;
  $1 = *argp; 
%}

%typemap(out) SWIGTYPE ($&1_type temp)
#ifdef __cplusplus
%{
  temp = new $1_ltype((const $1_ltype &)$1); 
  SWIG_PRV_DATA *privatedata = new SWIG_PRV_DATA();
  privatedata->swigCMemOwn = false; 
  privatedata->swigCObject = temp;
  $result = JSObjectMake(context, _wrap_$1_type_createJSClass(context), privatedata);
  //$result = JSObjectMake(context, _wrap_$1_basetype_createJSClass(context), privatedata); 
  //$result = JSObjectMake(context, _wrap_$objecttype_createJSClass(context), privatedata);
  // $1_mangle
  // $1_descriptor
%}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  temp = $1ptr;
  SWIG_PRV_DATA *privatedata = (SWIG_PRV_DATA *)malloc(sizeof(SWIG_PRV_DATA());
  privatedata->swigCMemOwn = false; 
  privatedata->swigCObject = temp;
  $result = JSObjectMake(context, _wrap_$1_ltype_createJSClass(context), privatedata);
  //$result = JSObjectMake(context, _wrap_$1_basetype_createJSClass(context), privatedata); 
  //$result = JSObjectMake(context, _wrap_$objecttype_createJSClass(context), privatedata);
  // $1_mangle
  // $1_descriptor
}
#endif

%typemap(in) SWIGTYPE *, SWIGTYPE &
%{
  JSObjectRef o$1 = JSValueToObject(context,$input, NULL);
  SWIG_PRV_DATA *$1_privatedata = (SWIG_PRV_DATA *)JSObjectGetPrivate(o$1);
  $1 = ($1_ltype)$1_privatedata->swigCObject;
%}

%typemap(out) SWIGTYPE *, SWIGTYPE & 
%{
  SWIG_PRV_DATA *privatedata = new SWIG_PRV_DATA();
  privatedata->swigCMemOwn = false;
  privatedata->swigCObject = result;
  $result = JSObjectMake(context, _wrap_$*1_ltype_createJSClass(context), privatedata);
  //$result = JSObjectMake(context, _wrap_$1_basetype_createJSClass(context), privatedata); 
  //$result = JSObjectMake(context, _wrap_$objecttype_createJSClass(context), privatedata);
  // $1_mangle
  // $1_descriptor
%}

%typemap(arginit) SWIGTYPE * 
%{
  // Sanity check if the call is not on the global object
  if (!JSValueIsEqual(context, 
					JSValueToObject(context,thisObject,NULL), 
  					JSValueToObject(context,JSContextGetGlobalObject(context), NULL), 
					NULL)) {					
	SWIG_PRV_DATA* $1_swigprivatedata = (SWIG_PRV_DATA*)JSObjectGetPrivate(thisObject);
	$1 = ($1_ltype)$1_swigprivatedata->swigCObject; 
  }
%}

%typemap(in) SWIGTYPE (CLASS::*) "" 

%typemap(out) SWIGTYPE (CLASS::*) 
%{
 // Class* out typemap
 $result = JSObjectMake(context, _wrap_$*1_ltype_createJSClass(context), result);
%}



/* Typecheck typemaps - The purpose of these is merely to issue a warning for overloaded C++ functions 
 * that cannot be overloaded in Javascript as more than one C++ type maps to a single Javascript type */
// TODO


// Default array handling
%typemap(in) SWIGTYPE [] %{ $1 = ($1_ltype)$input; %}
%typemap(out) SWIGTYPE [] %{ $result = $1; %} 


// Javascript specific directives
//TODO

// Some ANSI C typemaps */
%apply unsigned long { size_t };

%apply const unsigned long & { const size_t & };

// Array reference typemaps
%apply SWIGTYPE & { SWIGTYPE ((&)[ANY]) }

// const pointers
%apply SWIGTYPE * { SWIGTYPE *const }
