/* -----------------------------------------------------------------------------
 * swiftswigtype.swg
 *
 * Typemaps for C++ class/struct types wrapped as Swift proxy classes.
 * The opaque handle is passed as void* between C and Swift.
 * ----------------------------------------------------------------------------- */

/* SWIGTYPE* (pointer to a C++ class) */
%typemap(ctype)  SWIGTYPE *  "void *"
%typemap(imtype) SWIGTYPE *  "UnsafeMutableRawPointer?"
%typemap(swifttype) SWIGTYPE *  "$swiftclassname?"
%typemap(in)  SWIGTYPE * %{$1 = ($1_ltype)$input;%}
%typemap(out) SWIGTYPE * %{$result = (void*)$1;%}
%typemap(swiftin)    SWIGTYPE *  "$swiftinput == nil ? nil : $swiftinput!.swigCPtr"
%typemap(swiftout)   SWIGTYPE *  %{
    let jresult = $imcall
    try swigCheckException()
    guard let ptr = jresult else { return nil }
    return $swiftclassname(ptr, $owner)
%}

/* SWIGTYPE& (reference to a C++ class) */
%typemap(ctype)  SWIGTYPE &  "void *"
%typemap(imtype) SWIGTYPE &  "UnsafeMutableRawPointer?"
%typemap(swifttype) SWIGTYPE &  "$swiftclassname"
%typemap(in)  SWIGTYPE & %{$1 = ($1_ltype)$input;%}
%typemap(out) SWIGTYPE & %{$result = (void*)$1;%}
%typemap(swiftin)    SWIGTYPE &  "$swiftinput.swigCPtr"
%typemap(swiftout)   SWIGTYPE &  %{
    let jresult = $imcall
    try swigCheckException()
    return $swiftclassname(jresult!, false)
%}

/* SWIGTYPE (value type — returned as new heap object) */
%typemap(ctype)  SWIGTYPE  "void *"
%typemap(imtype) SWIGTYPE  "UnsafeMutableRawPointer?"
%typemap(swifttype) SWIGTYPE  "$swiftclassname"
%typemap(in)  SWIGTYPE ($&1_ltype argp) %{
    argp = ($&1_ltype)$input;
    if (!argp) { SWIG_Swift_SetPendingException("Attempt to dereference null $1_type"); return $null; }
    $1 = *argp;
%}
%typemap(out) SWIGTYPE %{$result = (void*)new $1_ltype($1);%}
%typemap(swiftin)    SWIGTYPE  "$swiftinput.swigCPtr!"
%typemap(swiftout)   SWIGTYPE  %{
    let jresult = $imcall
    try swigCheckException()
    return $swiftclassname(jresult!, true)
%}

/* SWIGTYPE (by const reference) */
%typemap(ctype)  const SWIGTYPE &  "void *"
%typemap(imtype) const SWIGTYPE &  "UnsafeMutableRawPointer?"
%typemap(swifttype) const SWIGTYPE &  "$swiftclassname"
%typemap(in)  const SWIGTYPE & %{$1 = ($1_ltype)$input;%}
%typemap(out) const SWIGTYPE & %{$result = (void*)$1;%}
%typemap(swiftin)    const SWIGTYPE &  "$swiftinput.swigCPtr"
%typemap(swiftout)   const SWIGTYPE &  %{
    let jresult = $imcall
    try swigCheckException()
    return $swiftclassname(jresult!, false)
%}

/* Default class body typemap for proxy classes */
%typemap(swiftclassmodifiers) SWIGTYPE "public"

%typemap(swiftbody) SWIGTYPE %{
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

%typemap(swiftbody_derived) SWIGTYPE %{
    fileprivate override init(_ ptr: UnsafeMutableRawPointer?, _ own: Bool) {
        super.init(ptr, own)
    }
%}

/* Body of the public init(...) generated from a C++ constructor.  $imcall is the
 * call to the C wrapper factory.  Override this (and swiftcode, to declare the
 * stored property) to pin a constructor argument for the object's lifetime, e.g.
 * to keep an ARC reference alive while C++ holds a non-owning handle to it. */
%typemap(swiftconstruct) SWIGTYPE %{{
        swigCPtr = $imcall
        swigCMemOwn = true
        try swigCheckException()
    }%}

%typemap(swiftconstruct_derived) SWIGTYPE %{{
        guard let ptr = $imcall else {
            try swigCheckException()
            fatalError("Constructor returned nil")
        }
        super.init(ptr, true)
        try swigCheckException()
    }%}

%typemap(swiftdestruct) SWIGTYPE %{
    deinit {
        if swigCMemOwn {
            swigCMemOwn = false
            $imcall
        }
    }
%}

%typemap(swiftdestruct_derived) SWIGTYPE %{
    deinit {
        if swigCMemOwn {
            swigCMemOwn = false
            $imcall
        }
    }
%}

/* Typecheck typemaps for overloaded functions.
 *
 * The precedence=SWIG_TYPECHECK_POINTER level is required, not optional.  The
 * overload ranker (Source/Modules/overload.cxx:Swig_overload_rank) flags any
 * argument whose typecheck typemap has no precedence as an error and then sets
 * "overload:ignore" on that method, silently dropping it from both the C
 * wrapper and the Swift proxy.  This only bites when two overloads share the
 * same argument count and differ in a wrapped (SWIGTYPE) argument -- e.g. a
 * copy constructor and a %extend constructor that takes a different wrapped
 * type.  SWIG_TYPECHECK_POINTER is 0, which makes the ranker fall back to the
 * ltype subtype comparison that correctly distinguishes the two C++ pointer
 * types and keeps both overloads.  Mirrors the Java and C# modules. */
%typecheck(SWIG_TYPECHECK_POINTER)
    SWIGTYPE,
    SWIGTYPE *,
    SWIGTYPE &,
    SWIGTYPE &&,
    SWIGTYPE *const&,
    SWIGTYPE [],
    SWIGTYPE (CLASS::*)
    ""

/* Director typemaps: C++ -> C conversions for callback parameters */
%typemap(directorin) SWIGTYPE *         "(void *)($input)"
%typemap(directorin) SWIGTYPE &         "(void *)std::addressof($input)"
%typemap(directorin) const SWIGTYPE &   "(void *)std::addressof($input)"
%typemap(directorin) SWIGTYPE           "(void *)std::addressof($input)"

/* Director typemaps: C return -> C++ return */
%typemap(directorout) SWIGTYPE *        "($1_ltype)$result"
%typemap(directorout) SWIGTYPE &        "*($1_ltype)$result"
/* Value return: Swift transferred ownership of the heap object (swigCMemOwn was set
 * to false on the Swift side).  Dereference to copy, then delete to avoid a leak. */
%typemap(directorout) SWIGTYPE \
    "[&](){ auto _p = ($&1_ltype)($result); auto _v = *_p; delete _p; return _v; }()"

/* Director typemaps: C param -> Swift type in dispatch function */
%typemap(swiftdirectorin) SWIGTYPE *        "$input == nil ? nil : $swiftclassname($input!, false)"
%typemap(swiftdirectorin) SWIGTYPE &        "$swiftclassname($input!, false)"
%typemap(swiftdirectorin) const SWIGTYPE &  "$swiftclassname($input!, false)"
/* By-value param: the C director passes a pointer to the value (directorin uses
 * addressof); build a non-owning proxy over it (C++ owns the value). */
%typemap(swiftdirectorin) SWIGTYPE          "$swiftclassname($input!, false)"

/* Director typemaps: Swift return -> C return in dispatch function */
%typemap(swiftdirectorout) SWIGTYPE *   "$input?.swigCPtr"
%typemap(swiftdirectorout) SWIGTYPE &   "$input.swigCPtr"
/* Value return: transfer ownership of the heap object to C++ so it can be
 * safely dereferenced after the Swift function exits.  Setting swigCMemOwn=false
 * prevents the Swift ARC destructor from freeing the vector; C++ deletes it after
 * copying (see the matching directorout typemap above). */
%typemap(swiftdirectorout) SWIGTYPE \
    "{ $input.swigCMemOwn = false; return $input.swigCPtr }()"
