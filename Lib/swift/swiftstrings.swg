/* -----------------------------------------------------------------------------
 * swiftstrings.swg
 *
 * Typemaps for C strings (const char*) <-> Swift String.
 * ----------------------------------------------------------------------------- */

/* const char* input: Swift String auto-bridges to const char* */
%typemap(ctype)  char *               "const char *"
%typemap(imtype) char *               "UnsafePointer<CChar>?"
%typemap(swifttype) char *            "String"
%typemap(in)     char *  %{$1 = ($1_ltype)$input;%}
%typemap(out)    char *  %{$result = $1;%}
%typemap(swiftin)    char *  "$swiftinput"
%typemap(swiftout)   char *  %{
    guard let rawStr = $imcall else {
        try swigCheckException()
        return ""
    }
    try swigCheckException()
    return String(cString: rawStr)
%}

/* const char* */
%typemap(ctype)  const char *         "const char *"
%typemap(imtype) const char *         "UnsafePointer<CChar>?"
%typemap(swifttype) const char *      "String"
%typemap(in)     const char *  %{$1 = ($1_ltype)$input;%}
%typemap(out)    const char *  %{$result = $1;%}
%typemap(swiftin)    const char *  "$swiftinput"
%typemap(swiftout)   const char *  %{
    guard let rawStr = $imcall else {
        try swigCheckException()
        return ""
    }
    try swigCheckException()
    return String(cString: rawStr)
%}
