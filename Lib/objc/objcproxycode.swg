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
%typemap(objcconstructor) SWIGTYPE %{
	if((self = [super init])) {
		void* cptr = $imcall;
        $objcbasecptrinit$objcclasscptr = cptr;
        $directorconnect
        swigCMemOwn = YES;
	}
	return self;
%}

%typemap(objcdestructor, methodname="dealloc", methodmodifiers="public") SWIGTYPE %{
  if ($objcclasscptr != NULL) {
    if (swigCMemOwn) {
        $imcall;
        swigCMemOwn = NO;
    }
    $objcclasscptr = NULL;
    $objcbasecptrclear
  }
  [super dealloc];
%}

// Proxy interface and implementation (for C++ class with no base class)
%typemap(objcinterfacecode) SWIGTYPE %{
{
	void *swigCPtr;
	BOOL swigCMemOwn;
}
-(void*)getCptr;
-(void*)$objccptrmethod;
-(void*)swigRelease;
-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject;
%}

%typemap(objcimplementationcode) SWIGTYPE %{
-(void*)getCptr {
	return [self $objccptrmethod];
}

-(void*)$objccptrmethod {
	return $objcclasscptr;
}

-(void*)swigRelease {
	void *cptr = $objcclasscptr;
	$objcclasscptr = NULL;
	swigCMemOwn = NO;
	return cptr;
}

-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject {
	if((self = [super init])) {
		$objcclasscptr = cptr;
        swigCMemOwn = ownCObject;
	}
	return self;
}
%}

// Proxy interface and implementation (for C++ class with a base class)
%typemap(objcinterfacecode_derived) SWIGTYPE %{
{
	void *$objcclasscptr;
}
-(void*)getCptr;
-(void*)$objccptrmethod;
-(void*)swigRelease;
-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject;
%}

%typemap(objcimplementationcode_derived) SWIGTYPE %{
- (void*)getCptr {
	return [self $objccptrmethod];
}

-(void*)$objccptrmethod {
	return $objcclasscptr;
}

-(void*)swigRelease {
	void *cptr = $objcclasscptr;
	$objcclasscptr = NULL;
	$objcbasecptrclear
	swigCMemOwn = NO;
	return cptr;
}

-(id)initWithCptr: (void*)cptr swigOwnCObject: (BOOL)ownCObject {
	if((self = [super init])) {
		$objcbasecptrinit$objcclasscptr = cptr;
        swigCMemOwn = ownCObject;
	}
	return self;
}
%}

/*
 * Type wrapper classes.
 */

%typemap(objctypeinterface) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
{
	void *swigCPtr;
	BOOL swigCMemOwn;
}
-(void*)getCptr;
-(void*)swigRelease;
-(id)initWithCptr: (void*) cptr;
%}

%typemap(objctypeimplementation) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [], SWIGTYPE (CLASS::*) %{
-(void*)getCptr {
	return swigCPtr;
}

-(void*)swigRelease {
	void *cptr = swigCPtr;
	swigCPtr = NULL;
	swigCMemOwn = NO;
	return cptr;
}

-(id)init {
	if((self = [super init])) {
		swigCPtr = 0;
	}
	return self;
}

-(id)initWithCptr: (void*) cptr{
	if((self = [super init])) {
		swigCPtr = cptr;
	}
	return self;
}
%}
