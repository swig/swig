/* ------------------------------------------------------------
 * go.swg
 *
 * Go configuration module.
 * ------------------------------------------------------------ */

%include <gostring.swg>

/* Code insertion directives */
#define %go_import(...) %insert(go_imports) %{__VA_ARGS__%}

%include <swigcommon.swg>

/* Basic types */

%typemap(gotype) bool,               const bool &               "bool"
%typemap(gotype) char,               const char &               "byte"
%typemap(gotype) signed char,        const signed char &        "int8"
%typemap(gotype) unsigned char,      const unsigned char &      "byte"
%typemap(gotype) short,              const short &              "int16"
%typemap(gotype) unsigned short,     const unsigned short &     "uint16"
%typemap(gotype) int,                const int &                "int"
%typemap(gotype) unsigned int,       const unsigned int &       "uint"
%typemap(gotype) long,               const long &               "int64"
%typemap(gotype) unsigned long,      const unsigned long &      "uint64"
%typemap(gotype) long long,          const long long &          "int64"
%typemap(gotype) unsigned long long, const unsigned long long & "uint64"
%typemap(gotype) float,              const float &              "float32"
%typemap(gotype) double,             const double &             "float64"

%typemap(in) bool,
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
%{ $1 = ($1_ltype)$input; %}

%typemap(in) const bool &,
	     const char &,
	     const signed char &,
	     const unsigned char &,
	     const short &,
	     const unsigned short &,
	     const int &,
	     const unsigned int &,
	     const long long &,
	     const unsigned long long &,
	     const float &,
	     const double &
%{ $1 = ($1_ltype)&$input; %}

%typemap(in) const long & ($*1_ltype temp),
	     const unsigned long & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input;
   $1 = ($1_ltype)&temp; %}

%typemap(out) bool,
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
%{ $result = $1; %}

%typemap(goout) bool,
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
""

%typemap(out) const bool &,
	      const char &,
	      const signed char &,
	      const unsigned char &,
	      const short &,
	      const unsigned short &,
	      const int &,
	      const unsigned int &,
	      const long &,
	      const unsigned long &,
	      const long long &,
	      const unsigned long long &,
	      const float &,
	      const double &
%{ $result = ($*1_ltype)*$1; %}

%typemap(goout) const bool &,
	      const char &,
	      const signed char &,
	      const unsigned char &,
	      const short &,
	      const unsigned short &,
	      const int &,
	      const unsigned int &,
	      const long &,
	      const unsigned long &,
	      const long long &,
	      const unsigned long long &,
	      const float &,
	      const double &
""

%typemap(out) void ""

%typemap(goout) void ""

%typemap(directorin) bool,
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
%{ $input = ($1_ltype)$1; %}

%typemap(godirectorin) bool,
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
""

%typemap(directorin) const bool &,
		     const char &,
		     const signed char &,
		     const unsigned char &,
		     const short &,
		     const unsigned short &,
		     const int &,
		     const unsigned int &,
		     const long &,
		     const unsigned long &,
		     const long long &,
		     const unsigned long long &,
		     const float &,
		     const double &
%{ $input = ($*1_ltype)$1; %}

%typemap(godirectorin) const bool &,
		     const char &,
		     const signed char &,
		     const unsigned char &,
		     const short &,
		     const unsigned short &,
		     const int &,
		     const unsigned int &,
		     const long &,
		     const unsigned long &,
		     const long long &,
		     const unsigned long long &,
		     const float &,
		     const double &
""

%typemap(directorout) bool,
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
%{ $result = ($1_ltype)$input; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) const bool &,
		      const char &,
		      const signed char &,
		      const unsigned char &,
		      const short &,
		      const unsigned short &,
		      const int &,
		      const unsigned int &,
		      const long &,
		      const unsigned long &,
		      const long long &,
		      const unsigned long long &,
		      const float &,
		      const double &
%{
  $result = new $*1_ltype($input);
  swig_acquire_pointer(&swig_mem, $result);
%}

/* The size_t type.  */

%typemap(gotype) size_t, const size_t & %{int64%}

%typemap(in) size_t
%{ $1 = (size_t)$input; %}

%typemap(in) const size_t &
%{ $1 = ($1_ltype)&$input; %}

%typemap(out) size_t
%{ $result = $1; %}

%typemap(goout) size_t ""

%typemap(out) const size_t &
%{ $result = ($*1_ltype)*$1; %}

%typemap(goout) const size_t & ""

%typemap(directorin) size_t
%{ $input = (size_t)$1; %}

%typemap(godirectorin) size_t ""

%typemap(directorin) const size_t &
%{ $input = ($*1_ltype)$1; %}

%typemap(godirectorin) const size_t & ""

%typemap(directorout) size_t
%{ $result = ($1_ltype)$input; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) const size_t &
%{
  $result = new $*1_ltype($input);
  swig_acquire_pointer(&swig_mem, $result);
%}

/* Member pointers.  A member pointer in Go points to a copy of it in Go memory, which is preceded by its size so that it can
   be copied to C/C++ memory for a Go director method returning it, as cgo does not allow returning a pointer to Go memory.  */

// C/C++ code to copy a member pointer into C/C++ memory for swigCopyMemberPtr.
%fragment("AllocateMemberPtr", "runtime") %{
static void *Swig_AllocateMemberPtr(const void *p, intgo size) {
  struct swig_out_type { intgo size; void* val; } *swig_out;
  swig_out = (struct swig_out_type*)malloc(sizeof(*swig_out));
  if (swig_out) {
    swig_out->size = size;
    swig_out->val = malloc(size);
    if (swig_out->val) {
      memcpy(swig_out->val, p, size);
    }
  }
  return swig_out;
}
%}

// Go code to copy a member pointer from C/C++ memory to Go memory and back.
%fragment("CopyMemberPtr", "go_runtime") %{
func swigCopyMemberPtr(p uintptr) SwigMemberPtr {
  type swig_out_type struct { size int; val uintptr }
  o := (*swig_out_type)(unsafe.Pointer(p))
  if o == nil || o.val == 0 {
    return nil
  }
  n := int(unsafe.Sizeof(o.size))
  m := make([]byte, n+o.size)
  *(*int)(unsafe.Pointer(&m[0])) = o.size
  copy(m[n:], unsafe.Slice((*byte)(unsafe.Pointer(o.val)), o.size))
  Swig_free(o.val)
  Swig_free(p)
  return &m[n]
}
func swigAllocateMemberPtr(m SwigMemberPtr) SwigMemberPtr {
  if m == nil {
    return nil
  }
  n := int(unsafe.Sizeof(int(0)))
  size := *(*int)(unsafe.Add(unsafe.Pointer(m), -n))
  p := Swig_malloc(size)
  copy(unsafe.Slice((*byte)(unsafe.Pointer(p)), size), unsafe.Slice((*byte)(m), size))
  return SwigMemberPtr(unsafe.Pointer(p))
}
%}

%typemap(gotype) SWIGTYPE (CLASS::*), SWIGTYPE (CLASS::*const&)
%{$gotypename%}

%typemap(in) SWIGTYPE (CLASS::*)
%{
  $1 = 0;
  if ($input) {
    memcpy(&$1, $input, sizeof($1));
  }
%}

%typemap(in) (SWIGTYPE (CLASS::*const&)) ($*1_ltype temp)
%{
  temp = 0;
  if ($input) {
    memcpy(&temp, $input, sizeof(temp));
  }
  $1 = &temp;
%}

%typemap(out, fragment="AllocateMemberPtr") SWIGTYPE (CLASS::*)
%{ $result = $1 ? Swig_AllocateMemberPtr(&$1, sizeof($1_ltype)) : 0; %}

%typemap(out, fragment="AllocateMemberPtr") SWIGTYPE (CLASS::*const&)
%{ $result = *$1 ? Swig_AllocateMemberPtr($1, sizeof($*1_ltype)) : 0; %}

%typemap(goout, fragment="CopyMemberPtr") SWIGTYPE (CLASS::*), SWIGTYPE (CLASS::*const&)
%{ $result = swigCopyMemberPtr(uintptr(unsafe.Pointer($1))) %}

%typemap(directorin, fragment="AllocateMemberPtr") SWIGTYPE (CLASS::*)
%{ $input = $1 ? Swig_AllocateMemberPtr(&$1, sizeof($1_ltype)) : 0; %}

%typemap(directorin, fragment="AllocateMemberPtr") SWIGTYPE (CLASS::*const&)
%{ $input = $1 ? Swig_AllocateMemberPtr(&$1, sizeof($*1_ltype)) : 0; %}

%typemap(godirectorin, fragment="CopyMemberPtr") SWIGTYPE (CLASS::*), SWIGTYPE (CLASS::*const&)
%{ $result = swigCopyMemberPtr(uintptr(unsafe.Pointer($input))) %}

%typemap(godirectorout, fragment="CopyMemberPtr") SWIGTYPE (CLASS::*), SWIGTYPE (CLASS::*const&)
%{ $result = swigAllocateMemberPtr($input) %}

%typemap(directorout) SWIGTYPE (CLASS::*)
%{
  if ($input) {
    memcpy(&$result, $input, sizeof($result));
    free($input);
  }
%}

%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE (CLASS::*const&)
%{
  $result = new ($*1_ltype)(0);
  if ($input) {
    memcpy($result, $input, sizeof(*$result));
  }
  free($input);
  swig_acquire_pointer(&swig_mem, $result);
%}

/* Pointers.  */

/* We can't translate pointers using a typemap, so that is handled in
   the C++ code.  */
%typemap(gotype) SWIGTYPE *
%{$gotypename%}

%typemap(in) SWIGTYPE *
%{ $1 = *($&1_ltype)&$input; %}

%typemap(out) SWIGTYPE *
%{ *($&1_ltype)&$result = ($1_ltype)$1; %}

%typemap(goout) SWIGTYPE * ""

%typemap(directorin) SWIGTYPE *
%{ *($&1_ltype)&$input = ($1_ltype)$1; %}

%typemap(godirectorin) SWIGTYPE * ""

%typemap(directorout) SWIGTYPE *
%{ $result = *($&1_ltype)&$input; %}

/* A function pointer is copied using memcpy, as a cast to a pointer to a pointer to a noexcept function is not valid before C++17 */
%typemap(in) SWIGTYPE ((*)(ANY)) %{ memcpy(&$1, &$input, sizeof($1)); %}
%typemap(out) SWIGTYPE ((*)(ANY)) %{ memcpy(&$result, &$1, sizeof($1)); %}
%typemap(directorin) SWIGTYPE ((*)(ANY)) %{ memcpy(&$input, &$1, sizeof($1)); %}
%typemap(directorout) SWIGTYPE ((*)(ANY)) %{ memcpy(&$result, &$input, sizeof($result)); %}

/* Pointer references.  */

%typemap(gotype) SWIGTYPE *const&
%{$gotypename%}

%typemap(in) SWIGTYPE *const& ($*1_ltype temp = 0)
%{
  temp = *($1_ltype)&$input;
  $1 = ($1_ltype)&temp;
%}

%typemap(out) SWIGTYPE *const&
%{ *($1_ltype)&$result = *$1; %}

%typemap(goout) SWIGTYPE *const& ""

/* References.  */

/* Converting a C++ reference to Go has to be handled in the C++
   code.  */
%typemap(gotype) SWIGTYPE &
%{$gotypename%}

%typemap(in) SWIGTYPE &
%{
  $1 = *($&1_ltype)&$input;
  if (!$1) {
    _swig_gopanic("Attempt to dereference null $1_type");
  }
%}

%typemap(out) SWIGTYPE &
%{ *($&1_ltype)&$result = $1; %}

%typemap(goout) SWIGTYPE & ""

%typemap(directorin) SWIGTYPE &
%{ $input = ($1_ltype)&$1; %}

%typemap(godirectorin) SWIGTYPE & ""

%typemap(directorout) SWIGTYPE &
%{ *($&1_ltype)&$result = $input; %}

%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE *const&
%{ static $*1_ltype swig_temp;
   swig_temp = *($1_ltype)&$input;
   $result = &swig_temp; %}

%typemap(gotype) SWIGTYPE &&
%{$gotypename%}

%typemap(in, fragment="<memory>") SWIGTYPE && (std::unique_ptr<$*1_ltype> rvrdeleter)
%{
  $1 = *($&1_ltype)&$input;
  if (!$1) {
    _swig_gopanic("Attempt to dereference null $1_type");
  }
  rvrdeleter.reset($1);
%}

%typemap(out) SWIGTYPE &&
%{ *($&1_ltype)&$result = $1; %}

%typemap(goout) SWIGTYPE && ""

%typemap(directorin) SWIGTYPE &&
%{ $input = ($1_ltype)&$1_name; %}

%typemap(godirectorin) SWIGTYPE && ""

%typemap(directorout) SWIGTYPE &&
%{ *($&1_ltype)&$result = $input; %}

/* C arrays turn into Go pointers.  If we know the length we can use a
   slice.  */

%typemap(gotype) SWIGTYPE []
%{$gotypename%}

%typemap(in) SWIGTYPE []
%{ $1 = *($&1_ltype)&$input; %}

%typemap(out) SWIGTYPE []
%{ *($&1_ltype)&$result = $1; %}

%typemap(goout) SWIGTYPE [] ""

%typemap(directorin) SWIGTYPE []
%{ $input = *($1_ltype)&$1; %}

%typemap(godirectorin) SWIGTYPE [] ""

%typemap(directorout) SWIGTYPE []
%{ *($&1_ltype)&$result = $input; %}

/* Strings.  */

%typemap(gotype) char *, char *&, char[ANY], char[] "string"

/* Needed to avoid confusion with the way the go module handles
   references.  */
%typemap(gotype) char&, unsigned char& "*byte"
%typemap(gotype) signed char& "*int8"

%typemap(in) char *(char *temp), char[](char *temp)
%{
  temp = (char *)malloc($input.n + 1);
  memcpy(temp, $input.p, $input.n);
  temp[$input.n] = '\0';
  $1 = ($1_ltype)temp;
%}

%typemap(in, fragment="SWIG_CopyCharArray") char[ANY](char temp[$1_dim0])
%{
  if (!SWIG_CopyCharArray(temp, $1_dim0, $input.p, (size_t)$input.n)) {
    _swig_gopanic("string too long for char array");
  }
  $1 = ($1_ltype)temp;
%}

/* A C99 variable length array parameter, as in 'int n, char s[n]' */
%typemap(in, fragment="SWIG_NewCharArray") char[*]
%{
  $1 = ($1_ltype)(($1_dim0) > 0 ? SWIG_NewCharArray((size_t)($1_dim0), $input.p, (size_t)$input.n) : 0);
  if (!$1) {
    _swig_gopanic("string too long for char array");
  }
%}

%typemap(in) char *&(char *temp)
%{
  temp = (char *)malloc($input.n + 1);
  memcpy(temp, $input.p, $input.n);
  temp[$input.n] = '\0';
  $1 = ($1_ltype)&temp;
%}

%typemap(freearg) char *, char[]
%{ free((char *)$1); %}

%typemap(freearg) char[ANY] ""

%typemap(freearg) char[*]
%{ free((char *)$1); %}

%typemap(freearg) char *&
%{ free((char *)*$1); %}

%typemap(out,fragment="AllocateString") char *, char[]
%{ $result = Swig_AllocateString((char*)$1, $1 ? strlen((char*)$1) : 0); %}

%typemap(out,fragment="AllocateString",fragment="SWIG_CharArrayLength") char[ANY]
%{ $result = Swig_AllocateString((char*)$1, $1 ? SWIG_CharArrayLength((const char *)$1, $1_dim0) : 0); %}

%typemap(out,fragment="AllocateString") char *&
%{ $result = Swig_AllocateString((char*)*$1, *$1 ? strlen((char*)*$1) : 0); %}

%typemap(goout,fragment="CopyString") char *, char *&, char[ANY], char[]
%{ $result = swigCopyString($1) %}

%typemap(directorin,fragment="AllocateString") char *, char *&, char[]
%{
  $input = Swig_AllocateString((char*)$1, $1 ? strlen((char*)$1) : 0);
%}

%typemap(directorin,fragment="AllocateString",fragment="SWIG_CharArrayLength") char[ANY]
%{
  $input = Swig_AllocateString((char*)$1, SWIG_CharArrayLength((const char *)$1, $1_dim0));
%}

%typemap(godirectorin,fragment="CopyString") char *, char *&, char[ANY], char[]
%{
  $result = swigCopyString($input)
%}

%typemap(godirectorout) char *, char *&, char[ANY], char[]
%{
  {
    p := Swig_malloc(len($input) + 1)
    s := unsafe.Slice((*byte)(unsafe.Pointer(p)), len($input) + 1)
    copy(s, $input)
    s[len($input)] = 0
    $result = unsafe.String((*byte)(unsafe.Pointer(p)), len($input) + 1)
  }
%}

%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) char *, char *&, char[ANY], char[]
%{ $result = ($1_ltype)$input.p; %}

%apply char[ANY] { char (&)[ANY], char (&&)[ANY] }

/* String & length */

%typemap(gotype) (const char *STRING, size_t LENGTH) "string"

%typemap(in) (const char *STRING, size_t LENGTH)
%{
  $1 = ($1_ltype)$input.p;
  $2 = ($2_ltype)$input.n;
%}

%typemap(freearg) (const char *STRING, size_t LENGTH) ""
%typecheck(SWIG_TYPECHECK_STRING) (const char *STRING, size_t LENGTH) ""

%typemap(out,fragment="AllocateString") (const char *STRING, size_t LENGTH)
%{ $result = Swig_AllocateString((char*)$1, (size_t)$2); %}

%typemap(goout,fragment="CopyString") (const char *STRING, size_t LENGTH)
%{ $result = swigCopyString($1) %}

%typemap(directorin,fragment="AllocateString") (const char *STRING, size_t LENGTH)
%{ $input = Swig_AllocateString((char*)$1, $2); %}

%typemap(godirectorin,fragment="CopyString") (const char *STRING, size_t LENGTH)
%{ $result = swigCopyString($input) %}

%typemap(directorout) (const char *STRING, size_t LENGTH)
%{
  $1 = ($1_ltype)$input.p;
  $2 = ($2_ltype)$input.n;
%}
%apply (const char *STRING, size_t LENGTH) { (const char *STRING, int LENGTH) }
%apply (const char *STRING, size_t LENGTH) { (char *STRING, size_t LENGTH) }
%apply (char *STRING, size_t LENGTH) { (char *STRING, int LENGTH) }

/* Length & string reverse order typemap */

%typemap(gotype) (size_t LENGTH, const char *STRING) "string"

%typemap(in) (size_t LENGTH, const char *STRING)
%{
  $2 = ($2_ltype)$input.p;
  $1 = ($1_ltype)$input.n;
%}

%typemap(freearg) (size_t LENGTH, const char *STRING) ""
%typecheck(SWIG_TYPECHECK_STRING) (size_t LENGTH, const char *STRING) ""

%typemap(out,fragment="AllocateString") (size_t LENGTH, const char *STRING)
%{ $result = Swig_AllocateString((char*)$2, (size_t)$1); %}

%typemap(goout,fragment="CopyString") (size_t LENGTH, const char *STRING)
%{ $result = swigCopyString($2) %}

%typemap(directorin,fragment="AllocateString") (size_t LENGTH, const char *STRING)
%{ $input = Swig_AllocateString((char*)$2, $1); %}

%typemap(godirectorin,fragment="CopyString") (size_t LENGTH, const char *STRING)
%{ $result = swigCopyString($input) %}

%typemap(directorout) (size_t LENGTH, const char *STRING)
%{
  $2 = ($2_ltype)$input.p;
  $1 = ($1_ltype)$input.n;
%}
%apply (size_t LENGTH, const char *STRING) { (int LENGTH, const char *STRING) }
%apply (size_t LENGTH, const char *STRING) { (size_t LENGTH, char *STRING) }
%apply (size_t LENGTH, char *STRING) { (int LENGTH, char *STRING) }

/* The int & type needs to convert to intgo.  */

%typemap(gotype) int & "*int"

%typemap(in) int & (int e)
%{
  e = (int)*$input;
  $1 = &e;
%}

%typemap(out) int &
%{ $result = new intgo(*$1); %}

%typemap(argout, match="in") int &
%{ *$input = (intgo)e$argnum; %}

%typemap(goout) int & ""

%typemap(directorin) int & (intgo e)
%{
  e = (intgo)$1;
  $input = &e;
%}

%typemap(godirectorin) int & ""

%typemap(directorout,warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) int &
%{
  $result = new $*1_ltype(($*1_ltype)*$input);
  swig_acquire_pointer(&swig_mem, $result);
%}

%typemap(directorargout) int &
%{ $1 = (int)*$input; %}

%typemap(argout) const int & ""
%typemap(directorargout) const int & ""

/* The int && type needs to convert to intgo.  */

%typemap(gotype) int && "*int"

%typemap(in) int && (int e)
%{
  e = (int)*$input;
  $1 = &e;
%}

%typemap(out) int &&
%{ $result = new intgo(*$1); %}

%typemap(argout, match="in") int &&
%{ *$input = (intgo)e$argnum; %}

%typemap(goout) int && ""

%typemap(directorin) int && (intgo e)
%{
  e = (intgo)$1;
  $input = &e;
%}

%typemap(godirectorin) int && ""

%typemap(directorout,warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) int &&
%{
  $result = new $*1_ltype(($*1_ltype)*$input);
  swig_acquire_pointer(&swig_mem, $result);
%}

%typemap(directorargout) int &&
%{ $1 = (int)*$input; %}

%typemap(argout) const int && ""
%typemap(directorargout) const int && ""

/* Enums.  We can't do the right thing for enums in typemap(gotype) so
   we deliberately don't define them.  The right thing would be to
   capitalize the name.  This is instead done in go.cxx.  */

%typemap(gotype) enum SWIGTYPE
%{$gotypename%}

%typemap(in) enum SWIGTYPE
%{ $1 = ($1_ltype)$input; %}

%typemap(out) enum SWIGTYPE
%{ $result = (intgo)$1; %}

%typemap(goout) enum SWIGTYPE ""

%typemap(directorin) enum SWIGTYPE
%{ $input = (intgo)$1; %}

%typemap(godirectorin) enum SWIGTYPE ""

%typemap(directorout) enum SWIGTYPE
%{ $result = ($1_ltype)$input; %}

%typemap(directorin) enum SWIGTYPE & (intgo e)
%{
  e = (intgo)$1;
  $input = ($1_ltype)&e;
%}

%typemap(godirectorin) enum SWIGTYPE & ""

%typemap(directorout) enum SWIGTYPE &
%{ $result = $input; %}

/* Arbitrary type.  This is a type passed by value in the C/C++ code.
   We convert it to a pointer for the Go code.  Note that all basic
   types are explicitly handled above.  */

%typemap(gotype) SWIGTYPE
%{$gotypename%}

%typemap(in) SWIGTYPE ($&1_type argp)
%{
  argp = ($&1_ltype)$input;
  if (argp == NULL) {
    _swig_gopanic("Attempt to dereference null $1_type");
  }
  $1 = ($1_ltype)*argp;
%}

%typemap(out) SWIGTYPE
#ifdef __cplusplus
%{ *($&1_ltype*)&$result = new $1_ltype($1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype)malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  *($&1_ltype*)&$result = $1ptr;
}
#endif

%typemap(goout) SWIGTYPE ""

%typemap(directorin) SWIGTYPE
%{ $input = new $1_ltype(SWIG_STD_MOVE($1)); %}

%typemap(godirectorin) SWIGTYPE ""

%typemap(directorout) SWIGTYPE
%{ $result = *($&1_ltype)$input; %}

/* Exception handling */

%typemap(throws) char *
%{ _swig_gopanic($1); %}

%typemap(throws) SWIGTYPE, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE *, SWIGTYPE [], SWIGTYPE [ANY]
%{
  (void)$1;
  _swig_gopanic("C++ $1_type exception thrown");
%}

/* Typecheck typemaps.  The purpose of these is merely to issue a
   warning for overloaded C++ functions that cannot be overloaded in
   Go as more than one C++ type maps to a single Go type.  */

%typecheck(SWIG_TYPECHECK_BOOL) /* Go bool */
    bool,
    const bool &
    ""

%typecheck(SWIG_TYPECHECK_CHAR) /* Go byte */
    char,
    const char &,
    unsigned char,
    const unsigned char &
    ""

%typecheck(SWIG_TYPECHECK_INT8) /* Go int8 */
    signed char,
    const signed char &
    ""

%typecheck(SWIG_TYPECHECK_INT16) /* Go int16 */
    short,
    const short &
    ""

%typecheck(SWIG_TYPECHECK_INT16) /* Go uint16 */
    unsigned short,
    const unsigned short &
    ""

%typecheck(SWIG_TYPECHECK_INT32) /* Go int */
    int,
    const int &
    ""

%typecheck(SWIG_TYPECHECK_INT32) /* Go uint */
    unsigned int,
    const unsigned int &
    ""

%typecheck(SWIG_TYPECHECK_INT64) /* Go int64 */
    long, 
    const long &, 
    long long,
    const long long &
    ""

%typecheck(SWIG_TYPECHECK_INT64) /* Go uint64 */
    unsigned long, 
    const unsigned long &, 
    unsigned long long,
    const unsigned long long &
    ""

%typecheck(SWIG_TYPECHECK_FLOAT) /* Go float32 */
    float,
    const float &
    ""

%typecheck(SWIG_TYPECHECK_DOUBLE) /* Go float64 */
    double,
    const double &
    ""

%typecheck(SWIG_TYPECHECK_STRING) /* Go string */
    char *,
    char *&,
    char[ANY],
    char [],
    signed char *,
    signed char *&,
    signed char[ANY],
    signed char [],
    unsigned char *,
    unsigned char *&,
    unsigned char[ANY],
    unsigned char []
    ""

%typecheck(SWIG_TYPECHECK_POINTER)
    SWIGTYPE,
    SWIGTYPE *,
    SWIGTYPE &,
    SWIGTYPE &&,
    SWIGTYPE *const&,
    SWIGTYPE [],
    SWIGTYPE (CLASS::*),
    SWIGTYPE (CLASS::*const&)
    ""

%apply SWIGTYPE * { SWIGTYPE *const, SWIGTYPE *volatile, SWIGTYPE *const volatile }
%apply SWIGTYPE (CLASS::*) { SWIGTYPE (CLASS::*const) }
%apply SWIGTYPE & { SWIGTYPE ((&&)[ANY]), SWIGTYPE ((&&)[]), SWIGTYPE ((&&)(ANY)) }

/* Go keywords.  */
%include <gokw.swg>

%include <goruntime.swg>
