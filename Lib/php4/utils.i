// Contains operations useful in php typemaps
// typemaps don't support "subroutine" typemaps where one typemap can
// include another, so we define useful bodies here to include inother places

// _strbuf_out is designed to be included as part of an argout typemap
// and _strbuf_in which should be part of the in typemap for the same argument
// They share knowledge of the "force" temporary variable.
// You probably don't want to make direct use of _strbuf_out or _strbuf_in but
// you may want strbufsize_inout which uses these
%define _strbuf_out(BUFFER,SIZE)
  if (force$argnum) {  /* pass back arg$argnum through params ($arg) if we can */
    if(! PZVAL_IS_REF(*$arg)) {
      zend_error(E_WARNING, "Parameter %d of $symname wasn't passed by reference [argout TYPES *, TYPES &]",$argnum-argbase);
    } else {
      #if SIZE
      // SIZE
      ZVAL_STRINGL(*$arg,BUFFER$argnum, SIZE, 1);
      #else
      // Measure length
      ZVAL_STRING(*$arg,BUFFER$argnum, 1);
      #endif
    }
  }  
%enddef

%define 
_strbuf_in(BUFFER)
  // _strbuf_in 
  if(! SWIG_ConvertPtr(*$input, (void **) &$1, $1_descriptor) < 0) {
    /* Using a _p_ SWIG pointer, so they will have to manage size themselves */
    force=0;
  } else if ((*$input)->type==IS_STRING ||
             (*$input)->type==IS_LONG ||
             /* Null passed by reference means we want a value back */
             (*$input)->type==IS_NULL ||
             (*$input)->type==IS_BOOL ||
             (*$input)->type==IS_DOUBLE) {
       
    // Only pass back if we can...
    if (PZVAL_IS_REF(*$input)) force=1;
    else force=0;

    convert_to_string_ex($input);
    // Init temp buffer
    strncpy((char *)temp,Z_STRVAL_PP($input),sizeof(BUFFER));
    $1=temp;
  } else {
    force=0;
    $1=NULL;
    zend_error(E_ERROR, "Type error in argument %d of $symname. Expected %s or at least something looking vaguely like a string hopefully passed by reference", $argnum-argbase, $1_descriptor->name);
  }
%enddef

// strbufsize_inout defines a typemap which
// Example: strbufsize_inout(UCHAR FAR * szErrorMsg, SWORD cbErrorMsgMax,1024)
// defines a typeemap for UCHAR FAR * szErrorMsg, SWORD cbErrorMsgMax with a
// max buffer size of 1024
%define strbufsize_inout(BUFFER,SIZE,MAXSIZE)
%typemap(in) (BUFFER, SIZE) ($*1_ltype temp[MAXSIZE], int force) {
  _strbuf_in(temp)
  $2=sizeof(temp);
}
%typemap(argout) (BUFFER, SIZE) {
  _strbuf_out((char *)temp,strlen(temp))
}
%enddef

// char array can be in/out, though the passed string may not be big enough...
// so we have to size it
// e.g. Do: strarray_inout(char [ANY])
%define strarray_inout(TYPE) 
%typemap(in) TYPE ($*1_ltype temp[$1_dim0], int force) %{
        _strbuf_in(temp)
%}
%typemap(argout) TYPE %{
        _strbuf_out((char *)temp,$1_dim0);
%}
%enddef

%define strarraysize_inout(TYPE,SIZE) 
%typemap(in) TYPE ($*1_ltype temp[SIZE], int force) %{
        _strbuf_in(temp)
%}
%typemap(argout) TYPE %{
        _strbuf_out((char *)temp,SIZE);
%}
%enddef

%define strbuf_inout(BUFFER,MAXSIZE)
%typemap(in) (BUFFER) ($*1_ltype temp[MAXSIZE], int force) {
	_strbuf_in(temp)
}
%typemap(argout) (BUFFER) {
  _strbuf_out(temp,strlen(temp))
}
%enddef

/* Typemap for in/argout references
   NOTE: we don't choose to use these for arrays yet, maybe later */
%define outLONG(ZVALARG,CARG)
      ZVAL_LONG(*$arg,intr$argnum);
%enddef

// Defines an on/argout typemap for ordinal types
//Usage: %typemap_inout_ord(bool,convert_to_boolean_ex,ZVAL_BOOL)
%define %typemap_inout_ord(TYPES,TYPE_IN,TYPE_OUT)
%typemap(in) TYPES * ($*1_ltype intr, int force), 
             TYPES & ($*1_ltype intr, int force) %{
   /* inout typemap for TYPES using TYPE_IN and TYPE_OUT */
  if(SWIG_ConvertPtr(*$input, (void **) &$1, $1_descriptor) < 0) {
    /* So... we didn't get a ref or ptr, but can it be reasonably 
       co-erced into what we were looking for a ref of or ptr to? */
    if (!PZVAL_IS_REF(*$input) && (*$input)->type==IS_NULL) {
      // null passed not by reference means pass NULL
      $1 = NULL;
      force=0;
    } else if (PZVAL_IS_REF(*$input) &&
        ((*$input)->type==IS_STRING ||
         (*$input)->type==IS_LONG ||
         /* Null passed by reference means we want a value back */
         (*$input)->type==IS_NULL ||
         (*$input)->type==IS_BOOL ||
         (*$input)->type==IS_DOUBLE)) {
      TYPE_IN($input);
      intr = ($*1_ltype) (*$input)->value.lval;
      $1 = &intr;
      /* have to passback arg$arg too */
      force=1;
    } else {  /* wasn't a pre/ref/thing, OR anything like an int thing */
      force=0;
      zend_error(E_ERROR, "Type error in argument %d of $symname. Expected %s or at least something looking vaguely like a number hopefully passed by reference", $argnum-argbase, $1_descriptor->name);
    }
  } else force=0;
%}

%typemap(argout) TYPES *, TYPES & %{
  if (force$argnum) {  /* pass back arg$argnum through params ($arg) if we can */
    if(! PZVAL_IS_REF(*$arg)) {
      zend_error(E_WARNING, "Parameter %d of $symname wasn't passed by reference [argout TYPES *, TYPES &]",$argnum-argbase);
    } else {
       TYPE_OUT(*$arg,intr$argnum);	
    }
  }
%}
%enddef
