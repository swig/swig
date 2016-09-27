%include <shared_ptr.i>

%define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE...)

%naturalvar TYPE;
%naturalvar SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;
// destructor mods
%feature("unref") TYPE
//"if (debug_shared) { cout << \"deleting use_count: \" << (*smartarg1).use_count() << \" [\" << (boost::get_deleter<SWIG_null_deleter>(*smartarg1) ? std::string(\"CANNOT BE DETERMINED SAFELY\") : ((*smartarg1).get() ? (*smartarg1)->getValue() : std::string(\"NULL PTR\"))) << \"]\" << endl << flush; }\n"
                               "(void)arg1; delete smartarg1;"

//plain value
%typemap(in) CONST TYPE ($&1_type argp = 0) %{
  argp = ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0;
  if (!argp) {
    SWIG_ObjcThrowException(SWIG_ObjcNullPointerException, "Attempt to dereference null $1_type");
    return $null;
  }
  $1 = *argp; %}

%typemap(out) CONST TYPE
%{ $result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype(($1_ltype &)$1)); %}

// plain pointer
%typemap(in) CONST TYPE * (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input;
  $1 = (TYPE *)(smartarg ? smartarg->get() : 0); %}

%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * %{
  $result = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner) : 0;
%}

// plain reference
%typemap(in) CONST TYPE & %{
  $1 = ($1_ltype)(((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0);
  if (!$1) {
    SWIG_ObjcThrowException(SWIG_ObjcNullPointerException, "$1_type reference is null");
    return $null;
  } %}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE &
%{ $result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner); %}

// plain pointer by reference
%typemap(in) TYPE *CONST& ($*1_ltype temp = 0)
%{ temp = (TYPE *)(((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0);
   $1 = &temp; %}
%typemap(out, fragment="SWIG_null_deleter") TYPE *CONST&
%{ $result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 SWIG_NO_NULL_DELETER_$owner); %}

// shared_ptr by value
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ if ($input) $1 = *($&1_ltype)$input; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ $result = $1 ? new $1_ltype($1) : 0; %}
%typemap(directorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ *($&1_ltype)&$input = new $1_ltype(*$1); %}
%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > ($&1_ltype argp)
%{ argp = *($&1_ltype*)&$input;
   if (argp) { $result = *argp; } %}

// shared_ptr by reference
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & ($*1_ltype tempnull)
%{ $1 = $input ? ($1_ltype)$input : &tempnull; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{ $result = *$1 ? new $*1_ltype(*$1) : 0; %}
%typemap(directorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{ *($&1_ltype)&$input = new $*1_ltype($1); %}

// shared_ptr by pointer
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * ($*1_ltype tempnull)
%{ $1 = $input ? ($1_ltype)$input : &tempnull; %}
%typemap(out, fragment="SWIG_null_deleter") SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *
%{ $result = ($1 && *$1) ? new $*1_ltype(*($1_ltype)$1) : 0;
   if ($owner) delete $1; %}

// shared_ptr by pointer reference
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempnull, $*1_ltype temp = 0)
%{ temp = $input ? *($1_ltype)&$input : &tempnull;
   $1 = &temp; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
%{ *($1_ltype)&$result = (*$1 && **$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(**$1) : 0; %}

// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}

%typemap (imtype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "void*"

%typemap (objctype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(objctype,TYPE)"

%typemap(objcin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
               SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
               SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
               SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "[$objcinput getCptr]"

// These are used if a type has been decleared a shared_ptr, and the method return type is a shared_ptr as well
%typemap(objcout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{   void* cPtr = $imcall;
	$typemap(objctype,TYPE) ret = nil;
	if(cPtr) {
		ret = [[$typemap(objcbasetype,TYPE) alloc] initWithCptr:cPtr swigOwnCObject:YES];
	}
	return ret; %}
%typemap(objcdirectorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
	"[[$typemap(objcbasetype,TYPE) alloc] initWithCptr:$iminput swigOwnCObject:YES]"
%typemap(objcdirectorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
	"[($objccall) getCptr]"

%typemap(objcout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{   void* cPtr = $imcall;
	$typemap(objctype,TYPE) ret = nil;
	if(cPtr) {
		ret = [[$typemap(objcbasetype,TYPE) alloc] initWithCptr:cPtr swigOwnCObject:YES];
	}
	return ret; %}
%typemap(objcdirectorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
	"[[$typemap(objcbasetype,TYPE) alloc] initWithCptr:$iminput swigOwnCObject:YES]"
%typemap(objcdirectorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
	"[($objccall) getCptr]"

%typemap(objcout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *
%{   void* cPtr = $imcall;
	$typemap(objctype,TYPE) ret = nil;
	if(cPtr) {
		ret = [[$typemap(objcbasetype,TYPE) alloc] initWithCptr:cPtr swigOwnCObject:YES];
	}
	return ret; %}
%typemap(objcout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
%{   void* cPtr = $imcall;
	$typemap(objctype,TYPE) ret = nil;
	if(cPtr) {
		ret = [[$typemap(objcbasetype,TYPE) alloc] initWithCptr:cPtr swigOwnCObject:YES];
	}
	return ret; %}

// These are used if a type has been decleared a shared_ptr, but the method return type is a normal type
%typemap(objcout) CONST TYPE
%{   void* cPtr = $imcall;
	$typemap(objctype,TYPE) ret = nil;
	if(cPtr) {
		ret = [[$typemap(objcbasetype,TYPE) alloc] initWithCptr:cPtr swigOwnCObject:YES];
	}
	return ret; %}
// These will not work, swigOwnCObject:NO will cause a memory leak, swigOwnCObject:YES will
// delete a c++ object not owned by SWIG
%typemap(objcout) CONST TYPE &
%{   #error "typemaps for $1_type not available" %}
%typemap(objcout) CONST TYPE *
%{   #error "typemaps for $1_type not available" %}
%typemap(objcout) TYPE *CONST&
%{   #error "typemaps for $1_type not available" %}

// What are these used for?
%typemap(objcvarout) CONST TYPE &
%{   $objcclassname* $objcvarname = [[$objcclassname alloc] initWithCptr:($imcall) swigOwnCObject:NO]; %}
%typemap(objcvarout) CONST TYPE *
%{   $objcclassname* $objcvarname = [[$objcclassname alloc] initWithCptr:($imcall) swigOwnCObject:NO]; %}
%typemap(objcvarout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{   $objcclassname* $objcvarname = [[$objcclassname alloc] initWithCptr:($imcall) swigOwnCObject:NO]; %}
%typemap(objcvarout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *
%{   $objcclassname* $objcvarname = [[$objcclassname alloc] initWithCptr:($imcall) swigOwnCObject:NO]; %}

// Proxy interface and implementation (for C++ class with no base class)
%typemap(objcinterfacecode) TYPE %{
{
	void *swigCPtr;
	BOOL swigCMemOwn;
}
-(void*)getCptr;
-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject;
%}

%typemap(objcimplementationcode) TYPE %{
-(void*)getCptr
{
	return swigCPtr;
}

-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject 
{
	swigCPtr = cptr;
	swigCMemOwn = ownCObject;
	self = [super init];
	return self;
}
%}

// Proxy interface and implementation (for C++ class with a base class)
%typemap(objcinterfacecode_derived) TYPE %{
-(void*)getCptr;
-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject;
%}

%typemap(objcimplementationcode_derived) TYPE %{
- (void*)getCptr 
{
	return swigCPtr;
}

-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject 
{
	self = [super initWithCptr:cptr swigOwnCObject:ownCObject];
	return self;
}
%}

// Type wrapper classes
%typemap(objctypeinterface) TYPE *, TYPE & %{
{
	void *swigCPtr;
	BOOL swigCMemOwn;
}
-(void*)getCptr;
-(id)initWithCptr: (void*) cptr;
%}

%typemap(objctypeimplementation) TYPE *, TYPE & %{
-(void*)getCptr
{
	return swigCPtr;
}

-(id)init
{
	if((self = [super init]))
	{
		swigCPtr = 0;
	}
	return self;
}

-(id)initWithCptr: (void*) cptr
{
	if((self = [super init]))
	{
		swigCPtr = cptr;
	}
	return self;
}
%}

%typemap(objcdestructor, methodname="dealloc", methodmodifiers="public") TYPE
%{   if (swigCPtr != NULL) {
		$directordisconnect;

		if (swigCMemOwn) {
			$imcall;
			swigCMemOwn = NO;
		}
		swigCPtr = NULL;
	} %}

%template() SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;
%enddef
