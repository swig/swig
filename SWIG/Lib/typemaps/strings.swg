//
// Use the macro SWIG_PRESERVE_CARRAY_SIZE if you prefer to preserve
// the size of char arrays, ie
//  ------------------------------------------
//       C Side             =>   Language Side
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

%define %_typemap_string(Char,
			 SWIG_AsCharPtrAndSize,
			 SWIG_FromCharPtrAndSize,
			 SWIG_CharPtrLen,
			 SWIG_AsCharPtr,
			 SWIG_FromCharPtr,
			 SWIG_AsCharArray)

/* in */

%typemap(in,noblock=1,fragment=#SWIG_AsCharPtr) 
  Char * (Char *buf = 0, int alloc = 0),
  const Char * (Char *buf = 0, int alloc = SWIG_OLDOBJ) {
  if (SWIG_AsCharPtr($input, &buf, &alloc) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError,"$type",$argnum);
  }
  $1 = buf;
}
%typemap(freearg,noblock=1) Char *, const Char * {
  if (alloc$argnum == SWIG_NEWOBJ) SWIG_delete_array(buf$argnum);
}

%typemap(in,noblock=1,fragment=#SWIG_AsCharPtr) Char const*& (Char *buf = 0, int alloc = 0) {
  if (SWIG_AsCharPtr($input, &buf, &alloc) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError,"$type",$argnum);
  }
  $1 = &temp;
}    
%typemap(freearg, noblock=1) Char const*& {
  if (alloc$argnum == SWIG_NEWOBJ) SWIG_delete_array(buf$argnum);
}

/* out */

%typemap(out,noblock=1,fragment=#SWIG_FromCharPtr) Char *, const Char* {
  SWIG_set_result(SWIG_FromCharPtr($1));
}


%typemap(out,noblock=1,fragment=#SWIG_FromCharPtr) Char const*& {
  SWIG_set_result(SWIG_FromCharPtr(*$1));
}


/* varin */

%typemap(varin,noblock=1,fragment=#SWIG_AsCharPtrAndSize) Char * {
  Char *cptr = 0; size_t csize = 0; int alloc = SWIG_NEWOBJ;
  if (SWIG_AsCharPtrAndSize($input, &cptr, &csize, &alloc) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError,"$type","$name");
  }
  if ($1) SWIG_delete_array($1);
  if (alloc == SWIG_NEWOBJ) {
    $1 = cptr;
  } else {
    $1 = csize ? SWIG_new_copy_array(cptr, csize, Char) : 0;
  }
}

%typemap(varin,noblock=1,fragment=#SWIG_AsCharPtrAndSize,warning="451:Setting const Char * variable may leak memory") const Char * {
  Char *cptr = 0; size_t csize = 0; int alloc = SWIG_NEWOBJ;
  if (SWIG_AsCharPtrAndSize($input, &cptr, &csize, &alloc) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name");
  }
  if (alloc == SWIG_NEWOBJ) {
    $1 = cptr;
  } else {
    $1 = csize ? SWIG_new_copy_array(cptr, csize, Char) : 0;
  }
}

/* varout */

%typemap(varout,noblock=1,fragment=#SWIG_FromCharPtr) Char*, const Char* {
  $result = SWIG_FromCharPtr($1);
}

/* meberin */

%typemap(memberin,noblock=1) Char * {
  if ($1) SWIG_delete_array($1);
  if ($input) {
    size_t size = SWIG_CharPtrLen($input) + 1;
    $1 = SWIG_new_copy_array($input, size, Char);
  } else {
    $1 = 0;
  }
}

%typemap(memberin,noblock=1,warning="451:Setting const char * member may leak memory.") const Char * {
  if ($input) {
    size_t size = SWIG_CharPtrLen($input) + 1;
    $1 = SWIG_new_copy_array($input, size, Char);
  } else {
    $1 = 0;
  }
}

/* globalin */

%typemap(globalin,noblock=1) Char * {
  if ($1) SWIG_delete_array($1);
  if ($input) {
    size_t size = SWIG_CharPtrLen($input) + 1;
    $1 = SWIG_new_copy_array($input, size, Char);
  } else {
    $1 = 0;
  }
}

%typemap(globalin,noblock=1,warning="451:Setting const char * variable may leak memory.") const Char * {
  if ($input) {
    size_t size = SWIG_CharPtrLen($input) + 1;
    $1 = SWIG_new_copy_array($input, size, Char);
  } else {
    $1 = 0;
  }
}

/* constant */

%typemap(constcode,noblock=1,fragment=#SWIG_FromCharPtr)
  Char *, Char const*, Char * const, Char const* const {
  SWIG_set_constant("$symname", SWIG_FromCharPtr($value));
}


#ifdef SWIG_DIRECTOR_TYPEMAPS

/* directorin */

%typemap(directorin,noblock=1,fragment=#SWIG_FromCharPtr)
  Char *, Char const*, Char *const, Char const *const, 
  Char const *&, Char *const &, Char const *const & {
  $input = SWIG_FromCharPtr($1_name);
}


/* directorout */

%typemap(directorout,noblock=1,fragment=#SWIG_AsCharPtr) Char * (Char* buf = 0, int alloc = 0) {
  if (SWIG_AsCharPtr($input, &buf, &alloc) != SWIG_OK) {
    SWIG_dout_fail(SWIG_TypeError, "$type");
  }
  $result = buf;
}

%typemap(directorout,noblock=1,fragment=#SWIG_AsCharPtr) Char * const& (Char* buf = 0, int alloc = 0) { 
  if (SWIG_AsCharPtr($input, &buf, &alloc) != SWIG_OK) {
    SWIG_dout_fail(SWIG_TypeError, "$type");
  }
  $result = ($1_ltype) &buf;
}

#endif /* SWIG_DIRECTOR_TYPEMAPS */

/* typecheck */

%typemap(typecheck,noblock=1,precedence=SWIG_TYPECHECK_STRING,
	 fragment=#SWIG_AsCharPtr) Char *, Char const*& {
  $1 = (SWIG_AsCharPtr($input, 0, 0) == SWIG_OK);
}


/* throws */

%typemap(throws,noblock=1,fragment=#SWIG_FromCharPtr) Char * {
  SWIG_raise(SWIG_FromCharPtr($1), "$type", 0);
}


/* ------------------------------------------------------------
 *  Unknown size const Character array Char[ANY] handling
 * ------------------------------------------------------------ */

%apply Char* { Char [] };
%apply const Char* { const Char [] };

%typemap(varin,noblock=1,warning="462:Unable to set variable of type Char []") Char []
{
  SWIG_var_fail(SWIG_AttributeError, "$type", "read-only $name");
}


/* ------------------------------------------------------------
 *  Fix size Character array Char[ANY] handling
 * ------------------------------------------------------------ */

/*  memberin and globalin typemaps  */

%typemap(memberin,noblock=1) Char [ANY]
{
  if ($input) memcpy($1,$input,$1_dim0*sizeof(Char));
  else memset($1,0,$1_dim0*sizeof(Char));
}

%typemap(globalin,noblock=1) Char [ANY]
{
  if ($input) memcpy($1,$input,$1_dim0*sizeof(Char));
  else memset($1,0,$1_dim0*sizeof(Char));
}

/* in */

%typemap(in,noblock=1,fragment=#SWIG_AsCharArray)
  Char [ANY] (Char temp[$1_dim0]), 
  const Char [ANY](Char temp[$1_dim0])
{  
  if (SWIG_AsCharArray($input, temp, $1_dim0) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError,"$type",$argnum);
  }
  $1 = temp;
}

%typemap(in,noblock=1,fragment=#SWIG_AsCharArray) const Char (&)[ANY] (Char temp[$1_dim0])
{  
  if (SWIG_AsCharArray($input, temp, $1_dim0) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError,"$type",$argnum);
  }
  $1 = &temp;
}

%typemap(out,fragment=#SWIG_FromCharPtrAndSize)
  Char [ANY], const Char[ANY] 
{
  size_t size = $1_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($1[size - 1] == '\0')) --size;
%#endif
   SWIG_set_result(SWIG_FromCharPtrAndSize($1, size));
}

/* varin */

%typemap(varin,noblock=1,fragment=#SWIG_AsCharArray) Char [ANY]
{
  if (SWIG_AsCharArray($input, $1, $1_dim0) != SWIG_OK) {
    SWIG_var_fail(SWIG_TypeError, "$type", "$name");
  }
}

/* varout */

%typemap(varout,noblock=1,fragment=#SWIG_FromCharPtrAndSize)
  Char [ANY], const Char [ANY] {
  size_t size = $1_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($1[size - 1] == '\0')) --size;
%#endif
  $result = SWIG_FromCharPtrAndSize($1, size);
}

/* constant */

%typemap(constcode,fragment=#SWIG_FromCharPtrAndSize)
  Char [ANY], const Char [ANY]
{
  size_t size = $value_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($value[size - 1] == '\0')) --size;
%#endif
  SWIG_set_constant("$symname", SWIG_FromCharPtrAndSize($value,size));
}


#ifdef SWIG_DIRECTOR_TYPEMAPS

/* directorin */
%typemap(directorin,fragment=#SWIG_FromCharPtrAndSize)
  Char [ANY], const Char [ANY] 
{
  size_t size = $1_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($1_name[size - 1] == '\0')) --size;
%#endif
  $input = SWIG_FromCharPtrAndSize($1_name, size);
}

/* directorout */

%typemap(directorout,noblock=1,fragment=#SWIG_AsCharArray)
  Char [ANY] (Char temp[$result_dim0]),
  const Char [ANY] (Char temp[$result_dim0])
{ 
  if (SWIG_AsCharArray($input, temp, $result_dim0) != SWIG_OK) {
    SWIG_dout_fail(SWIG_TypeError, "$type");
  }
  $result = temp;
}

#endif /* SWIG_DIRECTOR_TYPEMAPS */

/* typecheck */

%typemap(typecheck,noblock=1,precedence=SWIG_TYPECHECK_STRING,
	 fragment=#SWIG_AsCharArray)  
  Char [ANY], const Char[ANY] {
  $1 = (SWIG_AsCharArray($input, (Char *)0, $1_dim0) == SWIG_OK);
}


/* throws */

%typemap(throws,fragment=#SWIG_FromCharPtrAndSize)
  Char [ANY], const Char[ANY]
{
  size_t size = $1_dim0;
%#ifndef SWIG_PRESERVE_CARRAY_SIZE
  while (size && ($1[size - 1] == '\0')) --size;
%#endif
  SWIG_raise(SWIG_FromCharPtrAndSize($1, size), "$type", 0); 
}

/* -------------------------------------------------------------------
 * --- Really fix size Char arrays, including '\0'chars at the end ---
 * ------------------------------------------------------------------- */

%typemap(varout,noblock=1,fragment=#SWIG_FromCharPtrAndSize)
  Char FIXSIZE[ANY], const Char FIXSIZE[ANY]
{
  $result = SWIG_FromCharPtrAndSize($1, $1_dim0);
}

%typemap(out,noblock=1,fragment=#SWIG_FromCharPtrAndSize)
  Char FIXSIZE[ANY], const Char FIXSIZE[ANY]
{
  SWIG_set_result(SWIG_FromCharPtrAndSize($1, $1_dim0));
}

#ifdef SWIG_DIRECTOR_TYPEMAPS

%typemap(directorin,noblock=1,fragment=#SWIG_FromCharPtrAndSize)
  Char FIXSIZE[ANY], const Char FIXSIZE[ANY]
{
  $input = SWIG_FromCharPtrAndSize($1_name, $1_dim0);
}

#endif /* SWIG_DIRECTOR_TYPEMAPS */

%typemap(throws,noblock=1,fragment=#SWIG_FromCharPtrAndSize)
  Char FIXSIZE[ANY], const Char FIXSIZE[ANY] {
  SWIG_raise(SWIG_FromCharPtrAndSize($1, $1_dim0), "$type", 0); 
}

/* ------------------------------------------------------------
 * --- String & length ---
 * ------------------------------------------------------------ */

/* Here len doesn't include the '0' terminator */
%typemap(in,noblock=1,fragment=#SWIG_AsCharPtrAndSize) 
  (Char *STRING, size_t LENGTH) (Char *buf = 0, size_t size = 0, int alloc = 0),
  (const Char *STRING, size_t LENGTH) (Char *buf = 0, size_t size = 0, int alloc = SWIG_OLDOBJ)
{
  if (SWIG_AsCharPtrAndSize($input, &buf, &size, &alloc) != SWIG_OK) { 
    SWIG_arg_fail(SWIG_TypeError,"$type",$argnum);
  }  
  $1 = SWIG_static_cast(buf, $1_ltype);
  $2 = SWIG_numeric_cast(size - 1, $2_ltype);
}
%typemap(freearg,noblock=1) (Char *STRING, size_t LENGTH) {
  if (alloc$argnum == SWIG_NEWOBJ) SWIG_delete_array(buf$argnum);
}
/* old 'int' form */
%typemap(in) (Char *STRING, int LENGTH) = (Char *STRING, size_t LENGTH);
%typemap(freearg) (Char *STRING, int LENGTH) = (Char *STRING, size_t LENGTH);


/* Here size includes the '0' terminator */
%typemap(in,noblock=1,fragment=#SWIG_AsCharPtrAndSize)
  (Char *STRING, size_t SIZE) (Char *buf = 0, size_t size = 0, int alloc = 0),
  (const Char *STRING, size_t SIZE) (Char *buf = 0, size_t size = 0, int alloc = SWIG_OLDOBJ)
{
  if (SWIG_AsCharPtrAndSize($input, &buf, &size, &alloc) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError,"$type",$argnum);
  }
  $1 = SWIG_static_cast(buf, $1_ltype);
  $2 = SWIG_numeric_cast(size, $2_ltype);
}
%typemap(freearg, noblock=1) (Char *STRING, size_t SIZE) {
  if (alloc$argnum == SWIG_NEWOBJ) SWIG_delete_array(buf$argnum);
}
/* old 'int' form */
%typemap(in) (Char *STRING, int SIZE) = (Char *STRING, size_t SIZE);
%typemap(freearg) (Char *STRING, int SIZE) = (Char *STRING, size_t SIZE);


/* reverse order versions */

/* Here len doesn't include the '0' terminator */
%typemap(in,noblock=1,fragment=#SWIG_AsCharPtrAndSize) 
  (size_t LENGTH, Char *STRING) (Char *buf = 0, size_t size = 0, int alloc = 0),
  (size_t LENGHT, const Char *STRING) (Char *buf = 0, size_t size = 0, int alloc = SWIG_OLDOBJ)
{
  if (SWIG_AsCharPtrAndSize($input, &buf, &size, &alloc) != SWIG_OK) { 
    SWIG_arg_fail(SWIG_TypeError,"$type",$argnum);
  }  
  $2 = SWIG_static_cast(buf, $2_ltype) ;
  $1 = SWIG_numeric_cast(size - 1, $1_ltype) ;
}
%typemap(freearg, noblock=1) (size_t LENGTH, Char *STRING) {
  if (alloc$argnum == SWIG_NEWOBJ) SWIG_delete_array(buf$argnum);
}
/* old 'int' form */
%typemap(in) (int LENGTH, Char *STRING) = (size_t LENGTH, Char *STRING);
%typemap(freearg) (int LENGTH, Char *STRING) = (size_t LENGTH, Char *STRING);

/* Here size includes the '0' terminator */
%typemap(in,noblock=1,fragment=#SWIG_AsCharPtrAndSize)
  (size_t SIZE, Char *STRING) (Char *buf = 0, size_t size = 0, int alloc = 0),
  (size_t SIZE, const Char *STRING) (Char *buf = 0, size_t size = 0, int alloc = SWIG_OLDOBJ)
{
  if (SWIG_AsCharPtrAndSize($input, &buf, &size, &alloc) != SWIG_OK) {
    SWIG_arg_fail(SWIG_TypeError, "$type",$argnum);
  }
  $2 = SWIG_static_cast(buf, $2_ltype) ;
  $1 = SWIG_numeric_cast(size, $1_ltype) ;
}
%typemap(freearg, noblock=1) (size_t SIZE, Char *STRING) {
  if (alloc$argnum == SWIG_NEWOBJ) SWIG_delete_array(buf$argnum);
}
/* old 'int' form */
%typemap(in) (int SIZE, Char *STRING) = (size_t SIZE, Char *STRING);
%typemap(freearg) (int SIZE, Char *STRING) = (size_t SIZE, Char *STRING);


%enddef

%define %typemap_string(Char, CharName,
			SWIG_AsCharPtrAndSize,
			SWIG_FromCharPtrAndSize,
			SWIG_CharPtrLen)
/* String fragment methods */

%fragment("SWIG_From"#CharName"Ptr","header",fragment=#SWIG_FromCharPtrAndSize) {
SWIGINTERNINLINE SWIG_Object 
SWIG_From##CharName##Ptr(const Char *cptr)
{ 
  return SWIG_FromCharPtrAndSize(cptr, (cptr ? SWIG_CharPtrLen(cptr) : 0));
}
}

%fragment("SWIG_From"#CharName"Array","header",fragment=#SWIG_FromCharPtrAndSize) {
SWIGINTERNINLINE SWIG_Object 
SWIG_From##CharName##Array(const Char *cptr, size_t size)
{ 
  return SWIG_FromCharPtrAndSize(cptr, size);
}
}

%fragment("SWIG_As" #CharName "Ptr","header",fragment=#SWIG_AsCharPtrAndSize) {
  SWIG_define(SWIG_As##CharName##Ptr(obj, val, alloc), SWIG_AsCharPtrAndSize(obj, val, NULL, alloc))
}

%check_swig_object()

%fragment("SWIG_As" #CharName "Array","header",fragment=#SWIG_AsCharPtrAndSize) {
SWIGINTERN int
SWIG_As##CharName##Array(SWIG_Object obj, Char *val, size_t size)
{ 
  Char* cptr = 0; size_t csize = 0; int alloc = SWIG_OLDOBJ;
  if (SWIG_AsCharPtrAndSize(obj, &cptr, &csize, &alloc) == SWIG_OK) {
    if ((csize == size + 1) && cptr && !(cptr[csize-1])) --csize;
    if (csize <= size) {
      if (val) {
	if (csize) memcpy(val, cptr, csize*sizeof(Char));
	if (csize < size) memset(val + csize, 0, (size - csize)*sizeof(Char));
      }
      if (alloc == SWIG_NEWOBJ) SWIG_delete_array(cptr);
      return SWIG_OK;
    }
    if (alloc == SWIG_NEWOBJ) SWIG_delete_array(cptr);
  }
  return SWIG_TypeError;
}
}

%_typemap_string(Char,
		 SWIG_AsCharPtrAndSize,
		 SWIG_FromCharPtrAndSize,
		 SWIG_CharPtrLen,
		 SWIG_As##CharName##Ptr,
		 SWIG_From##CharName##Ptr,
		 SWIG_As##CharName##Array)

%enddef
