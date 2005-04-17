//
// Use the macro SWIG_PRESERVE_CARRAY_SIZE if you prefer to preserve
// the size of char arrays, ie
//  ------------------------------------------
//       C Side             =>   Python Side
//  ------------------------------------------
//   char name[5] = "hola"  =>   'hola\0'
//
// the default behaviour is 
//
//   char name[5] = "hola"  =>   'hola'
//
//
//#define SWIG_PRESERVE_CARRAY_SIZE

/* ------------------------------------------------------------
 *  String typemaps for type Char (char or wchar_t)
 * ------------------------------------------------------------ */

%define %typemap_pystring(Char,
			  SWIG_AsCharPtr,
			  SWIG_AsCharPtrAndSize,
			  SWIG_FromCharPtr,
			  SWIG_AsNewCharPtr,
			  SWIG_AsCharArray,
			  SWIG_FromCharArray)
/* in */

%typemap(in,fragment=#SWIG_AsCharPtr)
  Char *, Char const*, Char *const, Char const *const
  "if (!SWIG_AsCharPtr($input, (Char**)&$1)) {SWIG_arg_fail($argnum);SWIG_fail;}";

%typemap(in,fragment=#SWIG_AsCharPtr) 
  Char const*&, Char *const&, Char const *const & 
{
  $*ltype temp;
  if (!SWIG_AsCharPtr($input, (Char**)&temp)) {SWIG_arg_fail($argnum);SWIG_fail;}
  $1 = &temp;
}    

/* out */

%typemap(out,fragment=#SWIG_FromCharPtr)
  Char *, Char const*, Char *const, Char const *const
  "$result = SWIG_FromCharPtr($1);";

%typemap(out,fragment=#SWIG_FromCharPtr)
  Char *const &, Char const* &, Char const *const &
  "$result = SWIG_FromCharPtr(*$1);";

/* varin */

%typemap(varin,fragment=#SWIG_AsNewCharPtr) Char *
{
  Char *cptr = 0;
  if (!SWIG_AsNewCharPtr($input, &cptr)) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  }
  if ($1) SWIG_delete_array($1);
  $1 = cptr;
}

%typemap(varin,fragment=#SWIG_AsNewCharPtr,
	 warning="451:Setting const Char * variable may leak memory") 
  const Char *
{
  Char *cptr;
  if (!SWIG_AsNewCharPtr($input, &cptr)) {    
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  }
  $1 = cptr;
}

/* varout */

%typemap(varout,fragment=#SWIG_FromCharPtr)
  Char*, Char const*, Char *const, Char const *const
  "$result = SWIG_FromCharPtr($1);";

/* constant */

%typemap(constcode,fragment=#SWIG_FromCharPtr)
  Char *, Char const*, Char * const, Char const* const
  "PyDict_SetItemString(d,\"$symname\", SWIG_FromCharPtr($value));";

/* directorin */

%typemap(directorin,fragment=#SWIG_FromCharPtr)
  Char *, Char const*, Char *const, Char const *const, 
  Char const *&, Char *const &, Char const *const &
  "$input = SWIG_FromCharPtr($1_name);"; 

/* directorout */

%typemap(directorout,fragment=#SWIG_AsCharPtr)
  Char *, Char const*, Char *const, Char const* const
  "if (!$input || !SWIG_AsCharPtr($input, (Char**) &$result)) {
      Swig::DirectorTypeMismatchException(\"Error converting Python object into Char*\");
   }";

%typemap(directorout,fragment=#SWIG_AsCharPtr)
  Char const *&, Char *const &, Char const *const &
{ 
  Char* temp;
  if (!$input || !SWIG_AsCharPtr($input, &temp)) {
    Swig::DirectorTypeMismatchException("Error converting Python object into Char*");
  }
  $result = ($1_ltype) &temp;
}

/* typecheck */

%typemap(typecheck,precedence=SWIG_TYPECHECK_STRING,
	 fragment=#SWIG_AsCharPtr) 
  Char *, Char const*, Char *const, Char const *const, 
  Char const*&, Char *const&, Char const *const & 
 "$1 = SWIG_AsCharPtr($input, (Char **)(0));";

/* throws */

%typemap(throws,fragment=#SWIG_FromCharPtr)
  Char *, Char const*, Char * const, Char const* const
{
  PyErr_SetObject(PyExc_RuntimeError, SWIG_FromCharPtr($1));
  SWIG_fail;
}


/* ------------------------------------------------------------
 *  Unknown size const Character array Char[ANY] handling
 * ------------------------------------------------------------ */

%apply Char* { Char [] };
%apply const Char* { const Char [] };

%typemap(varin,warning="462:Unable to set variable of type Char []") Char []
{
  PyErr_SetString(PyExc_AttributeError, "C/C++ variable '$name' is read-only");
  return 1;
}


/* ------------------------------------------------------------
 *  Fix size Character array Char[ANY] handling
 * ------------------------------------------------------------ */

/*  memberin and globalin typemaps  */

%typemap(memberin) Char [ANY]
{
  if ($input) memcpy($1,$input,$1_dim0*sizeof(Char));
  else memset($1,0,$1_dim0*sizeof(Char));
}

%typemap(globalin) Char [ANY]
{
  if ($input) memcpy($1,$input,$1_dim0*sizeof(Char));
  else memset($1,0,$1_dim0*sizeof(Char));
}

/* in */

%typemap(in,fragment=#SWIG_AsCharArray)
  Char [ANY] (Char temp[$1_dim0]), 
  const Char [ANY](Char temp[$1_dim0])
{  
  if (!SWIG_AsCharArray($input, temp, $1_dim0)) {SWIG_arg_fail($argnum);SWIG_fail;}
  $1 = temp;
}

%typemap(in,fragment=#SWIG_AsCharArray) const Char (&)[ANY] (Char temp[$1_dim0])
{  
  if (!SWIG_AsCharArray($input, temp, $1_dim0)) {SWIG_arg_fail($argnum);SWIG_fail;}
  $1 = &temp;
}

%typemap(out,fragment=#SWIG_FromCharArray)
  Char [ANY], const Char[ANY] 
{
  size_t size = $1_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($1[size - 1] == '\0')) --size;
%#endif
  $result = SWIG_FromCharArray($1, size);
}

/* varin */

%typemap(varin,fragment=#SWIG_AsCharArray) Char [ANY]
{
  if (!SWIG_AsCharArray($input, $1, $1_dim0)) {
    SWIG_append_errmsg("C/C++ variable '$name'");
    return 1;
  }
}

/* varout */

%typemap(varout,fragment=#SWIG_FromCharArray)
  Char [ANY], const Char [ANY] 
{
  size_t size = $1_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($1[size - 1] == '\0')) --size;
%#endif
  $result = SWIG_FromCharArray($1, size);
}

/* constants */

%typemap(constcode,fragment=#SWIG_FromCharArray)
  Char [ANY], const Char [ANY]
{
  size_t size = $value_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($value[size - 1] == '\0')) --size;
%#endif
  PyDict_SetItemString(d,"$symname", SWIG_FromCharArray($value,size));
}

/* directorin */

%typemap(directorin,fragment=#SWIG_FromCharArray)
  Char [ANY], const Char [ANY] 
{
  size_t size = $1_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($1_name[size - 1] == '\0')) --size;
%#endif
  $input = SWIG_FromCharArray($1_name, size);
}

/* directorout */

%typemap(directorout,fragment=#SWIG_AsCharArray)
  Char [ANY], const Char [ANY] (Char temp[$result_dim0])
{ 
  if (!$input || !SWIG_AsCharArray($input, temp, $result_dim0)) {
    Swig::DirectorTypeMismatchException("Error converting Python object into Char[$result_dim0]");
  }
  $result = temp;
}

/* typecheck */

%typemap(typecheck,precedence=SWIG_TYPECHECK_STRING,
	 fragment=#SWIG_AsCharArray)  
  Char [ANY], const Char[ANY]
  "$1 = SWIG_AsCharArray($input, (Char *)0, $1_dim0);";

/* throws */

%typemap(throws,fragment=#SWIG_FromCharArray)
  Char [ANY], const Char[ANY]
{
  size_t size = $1_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($1[size - 1] == '\0')) --size;
%#endif
  PyErr_SetObject(PyExc_RuntimeError, SWIG_FromCharArray($1, size));
  SWIG_fail;
}

/* -------------------------------------------------------------------
 * --- Really fix size Char arrays, including '\0'chars at the end ---
 * ------------------------------------------------------------------- */

%typemap(varout,fragment=#SWIG_FromCharArray)
  Char FIXSIZE[ANY], const Char FIXSIZE[ANY]
{
  size_t size = $1_dim0;
  $result = SWIG_FromCharArray($1, size);
}

%typemap(out,fragment=#SWIG_FromCharArray)
  Char FIXSIZE[ANY], const Char FIXSIZE[ANY]
{
  size_t size = $1_dim0;
  $result = SWIG_FromCharArray($1, size);
}

%typemap(constcode,fragment=#SWIG_FromCharArray)
  Char FIXSIZE[ANY], const Char FIXSIZE[ANY]
{
  size_t size = $value_dim0;
  PyDict_SetItemString(d,"$symname", SWIG_FromCharArray($value,size));
}

%typemap(directorin,fragment=#SWIG_FromCharArray)
  Char FIXSIZE[ANY], const Char FIXSIZE[ANY]
{
  size_t size = $1_dim0;
  $input = SWIG_FromCharArray($1_name, size);
}

%typemap(throws,fragment=#SWIG_FromCharArray)
  Char FIXSIZE[ANY], const Char FIXSIZE[ANY]
{
  size_t size = $1_dim0;
  PyErr_SetObject(PyExc_RuntimeError, SWIG_FromCharArray($1, size));
  SWIG_fail;
}

/* ------------------------------------------------------------
 * --- String & length ---
 * ------------------------------------------------------------ */

/* Here len doesn't include the '0' terminator */
%typemap(in, fragment=#SWIG_AsCharPtrAndSize) 
  (Char *STRING, int LENGTH) (Char *buf, size_t size)
{
  int res = SWIG_AsCharPtrAndSize($input, &buf, &size);
  if (!res) {SWIG_arg_fail($argnum);SWIG_fail;}
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) size - 1;
}

/* Here size includes the '0' terminator */
%typemap(in,fragment=#SWIG_AsCharPtrAndSize)
  (Char *STRING, int SIZE) (Char *buf, size_t size)
{
  if (!SWIG_AsCharPtrAndSize($input, &buf, &size)) {SWIG_arg_fail($argnum);SWIG_fail;}
  $1 = ($1_ltype) buf;
  $2 = ($2_ltype) size;
}

%enddef
