/* -----------------------------------------------------------------------------
 * boost_shared_ptr.i  (Swift variant)
 *
 * Swift shared_ptr typemaps. The Swift proxy class stores a void* pointing to
 * a heap-allocated shared_ptr<T>. Deleters call delete on that shared_ptr*.
 * ----------------------------------------------------------------------------- */

#ifndef SWIG_SHARED_PTR_TYPEMAPS
#define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE...) SWIG_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(CONST, TYPE)
#endif

%include <shared_ptr.i>

%define SWIG_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(CONST, TYPE...)

%naturalvar TYPE;
%naturalvar SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

/* The "unref" feature provides the C destructor body for the shared_ptr holder */
%feature("unref") TYPE "(void)arg1; delete smartarg1;"

/* ---------- C++ <-> C conversions for the various smart-ptr forms ---------- */

/* plain value: dereference shared_ptr to get value */
%typemap(in) CONST TYPE ($&1_type argp = 0) %{
    argp = (*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)
           ? (*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get()
           : 0;
    if (!argp) {
        SWIG_Swift_SetPendingException("Attempt to dereference null $1_type");
        return $null;
    }
    $1 = *argp;
%}
%typemap(out) CONST TYPE %{
    *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result =
        new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype($1));
%}

/* plain pointer */
%typemap(in) CONST TYPE * (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
    smartarg = *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input;
    $1 = (TYPE *)(smartarg ? smartarg->get() : 0);
%}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * %{
    *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result =
        $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner) : 0;
%}

/* plain reference */
%typemap(in) CONST TYPE & %{
    $1 = ($1_ltype)((*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)
                    ? (*(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$input)->get()
                    : 0);
    if (!$1) {
        SWIG_Swift_SetPendingException("$1_type reference is null");
        return $null;
    }
%}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE & %{
    *(SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > **)&$result =
        new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner);
%}

/* shared_ptr by value */
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > ($&1_type argp) %{
    argp = *($&1_ltype*)&$input;
    if (argp) $1 = *argp;
%}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > %{
    *($&1_ltype*)&$result = $1 ? new $1_ltype($1) : 0;
%}

/* shared_ptr by reference */
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & ($*1_ltype tempnull) %{
    $1 = $input ? *($&1_ltype)&$input : &tempnull;
%}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
    *($&1_ltype)&$result = *$1 ? new $*1_ltype(*$1) : 0;
%}

/* shared_ptr by pointer */
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * ($*1_ltype tempnull) %{
    $1 = $input ? *($&1_ltype)&$input : &tempnull;
%}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
    *($&1_ltype)&$result = ($1 && *$1) ? new $*1_ltype(*$1) : 0;
    if ($owner) delete $1;
%}

/* ---------- ctype / imtype / swifttype ------------------------------------ */
%typemap(ctype)   SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&  "void *"

%typemap(imtype)  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&  "UnsafeMutableRawPointer?"

%typemap(swifttype, out="$typemap(swifttype, TYPE)?") SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                    SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                    SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                    SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&  "$typemap(swifttype, TYPE)"

/* directorout (C++ side): jresult is void* = shared_ptr<T>* owned by Swift proxy.
 * Dereference to copy the shared_ptr value (increments ref count); do NOT delete —
 * the Swift proxy's deinit will call delete via swigCMemOwn. */
%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
    "($result ? *($1_ltype *)($result) : $1_ltype())"

/* swiftdirectorout: convert Swift proxy (optional) back to void* for director dispatch */
%typemap(swiftdirectorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                           SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                           SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                           SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
    "$input?.swigCPtr"

/* ---------- swiftin / swiftout -------------------------------------------- */
%typemap(swiftin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
    "$typemap(swifttype, TYPE).swigGetCPtr($swiftinput)"

%typemap(swiftout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > %{
    let jresult = $imcall
    try swigCheckException()
    guard let ptr = jresult else { return nil }
    return $typemap(swifttype, TYPE)(ptr, true)
%}
%typemap(swiftout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
    let jresult = $imcall
    try swigCheckException()
    guard let ptr = jresult else { return nil }
    return $typemap(swifttype, TYPE)(ptr, true)
%}
%typemap(swiftout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
    let jresult = $imcall
    try swigCheckException()
    guard let ptr = jresult else { return nil }
    return $typemap(swifttype, TYPE)(ptr, true)
%}
%typemap(swiftout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& %{
    let jresult = $imcall
    try swigCheckException()
    guard let ptr = jresult else { return nil }
    return $typemap(swifttype, TYPE)(ptr, true)
%}

%typemap(swiftout) CONST TYPE %{
    let jresult = $imcall
    try swigCheckException()
    return $typemap(swifttype, TYPE)(jresult!, true)
%}
%typemap(swiftout) CONST TYPE & %{
    let jresult = $imcall
    try swigCheckException()
    return $typemap(swifttype, TYPE)(jresult!, true)
%}
%typemap(swiftout) CONST TYPE * %{
    let jresult = $imcall
    try swigCheckException()
    guard let ptr = jresult else { return nil }
    return $typemap(swifttype, TYPE)(ptr, true)
%}

/* ---------- Proxy class body for shared_ptr classes ----------------------- */
%typemap(swiftbody) TYPE %{
    fileprivate var swigCPtr: UnsafeMutableRawPointer?
    fileprivate var swigCMemOwn: Bool

    fileprivate init(_ ptr: UnsafeMutableRawPointer?, _ own: Bool) {
        swigCPtr = ptr
        swigCMemOwn = own
    }

    internal static func swigGetCPtr(_ obj: $swiftclassname?) -> UnsafeMutableRawPointer? {
        return obj?.swigCPtr
    }
%}

%typemap(swiftbody_derived) TYPE %{
    fileprivate override init(_ ptr: UnsafeMutableRawPointer?, _ own: Bool) {
        super.init(ptr, own)
    }
%}

%typemap(swiftdestruct, methodname="deinit") TYPE %{
    deinit {
        if swigCMemOwn {
            swigCMemOwn = false
            $imcall
        }
    }
%}

/* Typecheck typemaps for overloaded dispatch */
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *")
    TYPE CONST, TYPE CONST &, TYPE CONST *,
    SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
    SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
    SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
    SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
    ""

%template() SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;
%enddef
