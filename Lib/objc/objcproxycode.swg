/* -----------------------------------------------------------------------------
 * objcproxycode.swg
 *
 * Typemaps containing ObjectiveC code used when generating ObjectiveC proxy classes.
 * ----------------------------------------------------------------------------- */

%typemap(objcbase, notderived="")       SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "NSObject"
%typemap(objcinterfacemodifier)         SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "@interface"
%typemap(objcimplementationmodifier)    SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "@implementation"
%typemap(objcclassclose)                SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) "@end"
%typemap(objcprotocols)                 SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(objcprotocols_derived)         SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) ""

/*
 * Proxy classes.
 */


/*
 * Objective-C constructor and destructor typemaps:
 *
 * The objcconstruct typemap is inserted when a proxy class's constructor is generated.
 * This typemap allows control over what code is executed in the constructor as
 * well as specifying who owns the underlying C/C++ object. Normally, Objective-C has
 * ownership and the underlying C/C++ object is deallocated when the Objective-C object
 * is deallocated (swigCMemOwn is YES.) If swigCMemOwn is No, C/C++ is
 * ultimately responsible for deallocating the underlying object's memory.
 *
 */
%typemap(objcconstructor) SWIGTYPE 
%{	self = [self initWithCptr:$imcall swigOwnCObject:YES]; 
	$directorconnect;
	return self;
%}

%typemap(objcdestructor, methodname="dealloc", methodmodifiers="public") SWIGTYPE
%{      if (swigCPtr != NULL) 
	{
		$directordisconnect;

		if (swigCMemOwn) 
		{
			$imcall;
			swigCMemOwn = NO;
		}
		swigCPtr = NULL;
	} %}

// Proxy interface and implementation (for C++ class with no base class)
%typemap(objcinterfacecode) SWIGTYPE %{
{
	void *swigCPtr;
	BOOL swigCMemOwn;
}
-(void*)getCptr;
-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject;
%}

%typemap(objcimplementationcode) SWIGTYPE %{
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
%typemap(objcinterfacecode_derived) SWIGTYPE %{
-(void*)getCptr;
-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject;
%}

%typemap(objcimplementationcode_derived) SWIGTYPE 
%{
-(void*)getCptr 
{
	return swigCPtr;
}

-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject
{
	self = [super initWithCptr:cptr swigOwnCObject:ownCObject];
	return self;
}
%}

// Type wrapper classes.
%typemap(objctypeinterface) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
{
	void *swigCPtr;
	BOOL swigCMemOwn;
}
-(void*)getCptr;
-(id)initWithCptr: (void*) cptr;
%}

%typemap(objctypeimplementation) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) 
%{
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
