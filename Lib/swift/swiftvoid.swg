/* -----------------------------------------------------------------------------
 * swiftvoid.swg
 *
 * Typemaps for void and void*.
 * ----------------------------------------------------------------------------- */

/* void return */
%typemap(ctype)  void  "void"
%typemap(imtype) void  "Void"
%typemap(swifttype) void  ""
%typemap(out)    void  ""
%typemap(swiftout) void  %{
    $imcall
    try swigCheckException()
%}

/* void* (opaque pointer) */
%typemap(ctype)  void *  "void *"
%typemap(imtype) void *  "UnsafeMutableRawPointer?"
%typemap(swifttype) void *  "UnsafeMutableRawPointer?"
%typemap(in)     void *  %{$1 = $input;%}
%typemap(out)    void *  %{$result = $1;%}
%typemap(swiftin)    void *  "$swiftinput"
%typemap(swiftout)   void *  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* const void* (read-only pointer — maps to Swift UnsafeRawPointer?) */
%typemap(ctype)  const void *  "const void *"
%typemap(imtype) const void *  "UnsafeRawPointer?"
%typemap(swifttype) const void *  "UnsafeRawPointer?"
%typemap(in)     const void *  %{$1 = (void *)$input;%}
%typemap(swiftin)    const void *  "$swiftinput"
