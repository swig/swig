/* -----------------------------------------------------------------------------
 * dstrings.swg
 *
 * Typemaps for wrapping pointers to/arrays of C chars as D strings.
 * ----------------------------------------------------------------------------- */

%define SWIGD_STRING_TYPEMAPS(DW_STRING_TYPE, DP_STRING_TYPE, FROM_STRINGZ, TO_STRINGZ)
%typemap(ctype) char *, char *&, char[ANY], char[]   "char *"
%typemap(imtype) char *, char *&, char[ANY], char[]   #DW_STRING_TYPE
%typemap(dtype) char *, char *&, char[ANY], char[]   #DP_STRING_TYPE


/*
 * char* typemaps.
 */

%typemap(in) char * %{ $1 = ($1_ltype)$input; %}
%typemap(out) char * %{ $result = SWIG_d_string_callback((const char *)$1); %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) char * %{ $result = ($1_ltype)$input; %}
%typemap(directorin) char * %{ $input = SWIG_d_string_callback((const char *)$1); %}
%typemap(ddirectorin) char * "FROM_STRINGZ($winput)"
%typemap(ddirectorout) char * "TO_STRINGZ($dcall)"


/*
 * char*& typemaps.
 */

%typemap(in) char *& ($*1_ltype temp = 0) %{
  temp = ($*1_ltype)$input;
  $1 = &temp;
%}
%typemap(out) char *& %{ if ($1) $result = SWIG_d_string_callback((const char *)*$1); %}


/*
 * char array typemaps.
 */

%typemap(in, canthrow=1, fragment="SWIG_CopyCharArray") char[ANY] (char temp[$1_dim0])
%{ $1 = 0;
   if ($input) {
     if (!SWIG_CopyCharArray(temp, $1_dim0, $input, strlen($input))) {
       SWIG_DSetPendingException(SWIG_DIllegalArgumentException, "string too long for char array");
       return $null;
     }
     $1 = ($1_ltype)temp;
   } %}
%typemap(in) char[] %{ $1 = ($1_ltype)$input; %}
%typemap(out, fragment="SWIG_CharArrayString") char[ANY] %{ {
     const char *swig_str = SWIG_CharArrayString((const char *)$1, $1_dim0);
     $result = SWIG_d_string_callback(swig_str);
     SWIG_DeleteCharArrayString(swig_str, (const char *)$1);
   } %}
%typemap(out) char[] %{ $result = SWIG_d_string_callback((const char *)$1); %}

%typemap(directorout) char[ANY], char[] %{ $result = ($1_ltype)$input; %}
%typemap(directorin, fragment="SWIG_CharArrayString") char[ANY] %{ {
     const char *swig_str = SWIG_CharArrayString((const char *)$1, $1_dim0);
     $input = SWIG_d_string_callback(swig_str);
     SWIG_DeleteCharArrayString(swig_str, (const char *)$1);
   } %}
%typemap(directorin) char[] %{ $input = SWIG_d_string_callback((const char *)$1); %}

%typemap(ddirectorin) char[ANY], char[] "FROM_STRINGZ($winput)"
%typemap(ddirectorout) char[ANY], char[] "$dcall"


%typemap(din) char *, char *&, char[ANY], char[] "($dinput ? TO_STRINGZ($dinput) : null)"
%typemap(dout, excode=SWIGEXCODE) char *, char *&, char[ANY], char[] {
  DP_STRING_TYPE ret = FROM_STRINGZ ## ($imcall);$excode
  return ret;
}

%typecheck(SWIG_TYPECHECK_STRING)
    char *,
    char *&,
    char[ANY],
    char[]
  ""
%enddef


// We need to have the \0-terminated string conversion functions available in
// the D proxy modules.
SWIGD_STRING_TYPEMAPS(const(char)*, string, std.conv.to!string, std.string.toStringz)

%pragma(d) globalproxyimports = %{
static import std.conv;
static import std.string;
%}
#undef SWIGD_STRING_TYPEMAPS

%apply char[ANY] { char (&)[ANY], char (&&)[ANY] }
/* Unlike for a char array, NULL is not accepted, as a reference cannot be bound to NULL */
%typemap(in, canthrow=1, fragment="SWIG_CopyCharArray") char (&)[ANY] (char temp[$1_dim0]), char (&&)[ANY] (char temp[$1_dim0])
%{ if (!$input) {
     SWIG_DSetPendingException(SWIG_DNullReferenceException, "$1_type is null");
     return $null;
   }
   if (!SWIG_CopyCharArray(temp, $1_dim0, $input, strlen($input))) {
     SWIG_DSetPendingException(SWIG_DIllegalArgumentException, "string too long for char array");
     return $null;
   }
   $1 = ($1_ltype)temp; %}
