/*
 * php4.swg
 *
 * PHP 4 configuration file
 *
 */

%runtime "swigrun.swg"             // Common C API type-checking code
%runtime "php4run.swg"		// Php4 runtime functions
%include "utils.i"		// building blocks

%init "swiginit.swg"

/* Typemaps for input parameters by value */

%typemap(in) int, unsigned int, unsigned short, short, unsigned short, long, unsigned long, signed char, unsigned char, enum SWIGTYPE %{
	convert_to_long_ex($input);
	$1 = ($1_ltype) Z_LVAL_PP($input);
%}

%typemap(in) bool %{
	convert_to_boolean_ex($input);
	$1 = ($1_ltype) Z_LVAL_PP($input);
%}

%typemap(in) char %{
	convert_to_string_ex($input);
	$1 = ($1_ltype) *Z_STRVAL_PP($input);
%}

%typemap(in) float,double %{
	convert_to_double_ex($input);
	$1 = ($1_ltype) Z_DVAL_PP($input);
%}

// char * is input only normally
%typemap(in) char * %{
	convert_to_string_ex($input);
	$1 = ($1_ltype) Z_STRVAL_PP($input);
%}

// char array can be in/out, though the passed string may not be big enough...
// so we have to size it
strarray_inout(char [ANY])

%typemap(in) SWIGTYPE *, SWIGTYPE [], SWIGTYPE & %{
	if(SWIG_ConvertPtr(*$input, (void **) &$1, $1_descriptor) < 0) {
	  zend_error(E_ERROR, "Type error in argument %d of $symname. Expected %s", $argnum-argbase, $1_descriptor->name);
	}
%}
	
%typemap(in) void * %{
	if(SWIG_ConvertPtr(*$input, (void **) &$1, 0) < 0) {
	  /* Allow NULL from php for void* */
	  if ((*$input)->type==IS_NULL) $1=0;
	  else zend_error(E_ERROR, "Type error in argument %d of $symname. Expected %s", $argnum-argbase, $1_descriptor->name);
	}
%}

/* Special case when void* is passed by reference so it can be made to point
   to opaque api structs */
%typemap(in) void ** ($*1_ltype ptr, int force), void *& ($*1_ltype ptr, int force) %{
  /* If they pass NULL by reference, make it into a void*
     This bit should go in arginit if arginit support init-ing scripting args */
  if(SWIG_ConvertPtr(*$input, (void **) &$1, $1_descriptor) < 0) {
    /* So... we didn't get a ref or ptr, but we'll accept NULL by reference */
    if ((*$input)->type==IS_NULL && PZVAL_IS_REF(*$input)) {
#ifdef __cplusplus
      ptr=new $*1_ltype;
#else
      ptr=($*1_ltype) calloc(1,sizeof($*1_ltype));
#endif
      $1=&ptr;
      /* have to passback arg$arg too */
      force=1;
    } else {  /* wasn't a pre/ref/thing, OR anything like an int thing */
      force=0;
      zend_error(E_ERROR, "Type error in argument %d of $symname. Expected %s or %s or at least NULL passed by reference", $argnum-argbase, $1_descriptor->name,$*1_descriptor->name);
    }
  } else force=0;
%}

%typemap(argout) void **, void *& %{
  if (force$argnum) {  /* pass back arg$argnum through params ($arg) if we can */
    if(! PZVAL_IS_REF(*$arg)) {
      zend_error(E_WARNING, "Parameter %d of $symname wasn't passed by reference: [argout void**, void*&]",$argnum-argbase);
    } else {
      SWIG_SetPointerZval(*$arg, (void *) ptr$argnum, $*1_descriptor, 1);
    }
  }
%}

/* Object passed by value. Convert to a pointer */
%typemap(in) SWIGTYPE {
	$&1_ltype argp;
	if(SWIG_ConvertPtr(*$input, (void **) &argp, $&1_descriptor) < 0) {
	  zend_error(E_ERROR, "Type error in argument %d of $symname. Expected %s", $argnum-argbase, $&1_descriptor->name);
	}
	$1 = *argp;
}

/* Typemap for output values */

%typemap(out) int, unsigned int, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE %{
	ZVAL_LONG(return_value,$1);
%}

%typemap(out) bool %{
	ZVAL_BOOL(return_value,($1)?1:0);
%}

%typemap(out) float, double %{
	ZVAL_DOUBLE(return_value,$1);
%}

%typemap(out) char %{
	// out char
	ZVAL_STRINGL(return_value,$1, 1, 1);
%}

%typemap(out) char * %{
	if(!$1) {
	  ZVAL_NULL(return_value);
	} else {
	  ZVAL_STRING(return_value,$1, 1);
	}
%}

%typemap(out) SWIGTYPE *, SWIGTYPE [], SWIGTYPE & %{
	SWIG_SetPointerZval(return_value, (void *)$1, $1_descriptor, $owner);
%}

%typemap(out) SWIGTYPE *DYNAMIC, SWIGTYPE &DYNAMIC {
        swig_type_info *ty = SWIG_TypeDynamicCast($1_descriptor, (void **) &$1);
	SWIG_SetPointerZval(return_value, (void *)$1, ty, $owner);
}

%typemap(out) SWIGTYPE
#ifdef __cplusplus
{
  $&1_ltype resultobj = new $1_ltype(($1_ltype &) $1);
  SWIG_SetPointerZval(return_value, (void *)resultobj, $&1_descriptor, 1);
}
#else
{
  $&1_ltype resultobj = ($&1_ltype) emalloc(sizeof($1_type));
  memmove(resultobj, &$1, sizeof($1_type));
  SWIG_SetPointerZval(return_value, (void *)resultobj, $&1_descriptor, 1);
}
#endif

%typemap(out) void "";

/* Typemap for character array returns */

%typemap(out) char [ANY] {
        // out char any
	ZVAL_STRINGL(return_value,$1, $1_dim0, 1);
}

/* Typemap for in/argout references
   NOTE: we don't choose to use these for arrays yet, maybe later */

%typemap_inout_ord(bool,convert_to_boolean_ex,ZVAL_BOOL)
%typemap_inout_ord(int,convert_to_long_ex,ZVAL_LONG)
%typemap_inout_ord(unsigned int,convert_to_long_ex,ZVAL_LONG)
%typemap_inout_ord(short,convert_to_long_ex,ZVAL_LONG)
%typemap_inout_ord(unsigned short,convert_to_long_ex,ZVAL_LONG)
%typemap_inout_ord(long,convert_to_long_ex,ZVAL_LONG)
%typemap_inout_ord(unsigned long,convert_to_long_ex,ZVAL_LONG)
%typemap_inout_ord(signed char,convert_to_long_ex,ZVAL_LONG)
%typemap_inout_ord(unsigned char,convert_to_long_ex,ZVAL_LONG)
%typemap_inout_ord(enum SWIGTYPE,convert_to_long_ex,ZVAL_LONG)

/* Global variables - add the variable to PHP */

%typemap(varinit) char *
{
  zval *z_var;
  MAKE_STD_ZVAL(z_var);
  z_var->type = IS_STRING;
  if($1) {
      z_var->value.str.val = estrdup($1);
      z_var->value.str.len = strlen($1);
  } else {
      z_var->value.str.val = 0;
      z_var->value.str.len = 0;
  }
  zend_hash_add(&EG(symbol_table), "$1", strlen("$1")+1, (void *)&z_var, sizeof(zval *), NULL);
}

%typemap(varinit) int, unsigned int, unsigned short, short, unsigned short, long, unsigned long, signed char, unsigned char, bool, enum SWIGTYPE
{
  zval *z_var;
  MAKE_STD_ZVAL(z_var);
  z_var->type = IS_LONG;
  z_var->value.lval = $1;
  zend_hash_add(&EG(symbol_table), "$1", strlen("$1")+1, (void *)&z_var, sizeof(zval *), NULL);
}

%typemap(varinit) bool
{
  zval *z_var;
  MAKE_STD_ZVAL(z_var);
  z_var->type = IS_BOOL;
  z_var->value.lval = ($1)?1:0;
  zend_hash_add(&EG(symbol_table), "$1", strlen("$1")+1, (void *)&z_var, sizeof(zval *), NULL);
}

%typemap(varinit) float, double
{
  zval *z_var;
  MAKE_STD_ZVAL(z_var);
  z_var->type = IS_DOUBLE;
  z_var->value.dval = $1;
  zend_hash_add(&EG(symbol_table), "$1", strlen("$1")+1, (void *)&z_var,
  sizeof(zval *), NULL);
}

%typemap(varinit) char
{
  zval *z_var;
  char c[2];
  MAKE_STD_ZVAL(z_var);
  c[0] = $1;
  c[1] = 0;
  z_var->type = IS_STRING;
  z_var->value.str.val = estrdup(c);
  z_var->value.str.len = 2;
  zend_hash_add(&EG(symbol_table), "$1", strlen("$1")+1, (void *)&z_var,
  sizeof(zval *), NULL);
}

%typemap(varinit) SWIGTYPE *, SWIGTYPE &, SWIGTYPE []
{
  zval *z_var;
  MAKE_STD_ZVAL(z_var);
  SWIG_SetPointerZval(z_var, (void*)$1, $1_descriptor, $owner);
  zend_hash_add(&EG(symbol_table), "$1", strlen("$1")+1, (void *)&z_var,
  sizeof(zval *), NULL);
}

%typemap(varinit) SWIGTYPE
{
  $&1_ltype argp;
  zval *z_var;

  MAKE_STD_ZVAL(z_var);
  SWIG_SetPointerZval(z_var, (void*)&$1, $&1_descriptor, $owner);
  zend_hash_add(&EG(symbol_table), "$1", strlen("$1")+1, (void*)&z_var,
  sizeof(zval *), NULL);
}

%typemap(varinit) char [ANY]
{
 zval *z_var;
 MAKE_STD_ZVAL(z_var);
 z_var->type = IS_STRING;
 if($1) {
	// varinit char [ANY]
	ZVAL_STRINGL(z_var,$1, $1_dim0, 1);
 }
 zend_hash_add(&EG(symbol_table), "$1", strlen("$1")+1, (void*)&z_var,
 sizeof(zval *), NULL);
}

%typemap(varin) int, unsigned int, unsigned short, short, unsigned short, long, unsigned long, signed char, unsigned char,  enum SWIGTYPE
{
  zval **z_var;

  zend_hash_find(&EG(symbol_table), "$1",strlen("$1")+1, (void**)&z_var);
  convert_to_long_ex(z_var);
  if($1 != ($1_ltype)((*z_var)->value.lval)) {
    $1 = Z_LVAL_PP(z_var);
  }
}

%typemap(varin) bool
{
  zval **z_var;

  zend_hash_find(&EG(symbol_table), "$1",strlen("$1")+1, (void**)&z_var);
  convert_to_boolean_ex(z_var);
  if($1 != ($1_ltype)((*z_var)->value.lval)) {
    $1 = Z_LVAL_PP(z_var);
  }
}

%typemap(varin) double,float
{
  zval **z_var;

  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  convert_to_double_ex(z_var);
  if($1 != ($1_ltype)((*z_var)->value.dval)) {
    $1 = Z_DVAL_PP(z_var);
  }
}

%typemap(varin) char
{
  zval **z_var;

  zend_hash_find(&EG(symbol_table), "$1",strlen("$1")+1, (void**)&z_var);
  convert_to_string_ex(z_var);
  if($1 != *((*z_var)->value.str.val)) {
    $1 = *((*z_var)->value.str.val);
  }
}

%typemap(varin) char *
{
  zval **z_var;
  char *s1;

  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  convert_to_string_ex(z_var);
  s1 = Z_STRVAL_PP(z_var);
  if((s1 == NULL) || ($1 == NULL) || zend_binary_strcmp(s1, strlen(s1), $1, strlen($1))) {
    if(s1)
      $1 = estrdup(s1);
    else
      $1 = NULL;
  }
}


%typemap(varin) SWIGTYPE []
{
  zval **z_var;

  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  if($1) {
    SWIG_SetPointerZval(*z_var, (void*)$1, $1_descriptor, $owner);
  }
}

%typemap(varin) char [ANY]
{
 zval **z_var;
 char *s1;

 zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
 s1 = Z_STRVAL_PP(z_var);
 if((s1 == NULL) || ($1 == NULL) || zend_binary_strcmp(s1, strlen(s1), $1, strlen($1))) {
  if(s1)
    strncpy($1, s1, $1_dim0);
 }
}

%typemap(varin) SWIGTYPE
{
  zval **z_var;
  $&1_ltype _temp;

  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  if (SWIG_ConvertPtr(*z_var, (void**)&_temp, $&1_descriptor) < 0) {
    zend_error(E_ERROR, "Type error in value of $symname. Expected %s", $&1_descriptor->name);
  }

  $1 = *($&1_ltype)_temp;

}

%typemap(varin) SWIGTYPE *, SWIGTYPE &
{
  zval **z_var;
  $1_ltype _temp;

  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  if (SWIG_ConvertPtr(*z_var, (void **)&_temp, $1_descriptor) < 0) { 
    zend_error(E_ERROR, "Type error in value of $symname. Expected %s", $1_descriptor->name);
  }

  $1 = ($1_ltype)_temp;
}

%typemap(varout) int, unsigned int, unsigned short, short, unsigned short, long, unsigned long, signed char, unsigned char, enum SWIGTYPE
{
  zval **z_var;
  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  if($1 != ($1_ltype)((*z_var)->value.lval)) {
    (*z_var)->value.lval = (long)$1;
  }
}

//SAMFIX need to cast zval->type, what if zend-hash_find fails? etc?
%typemap(varout) bool
{
  zval **z_var;
  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  if($1 != ($1_ltype)((*z_var)->value.lval)) {
    (*z_var)->value.lval = (long)$1;
  }
}

%typemap(varout) double, float
{
  zval **z_var;
  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  if($1 != ($1_ltype)((*z_var)->value.dval)) {
    (*z_var)->value.dval = (double)$1;
  }
}

%typemap(varout) char
{
  zval **z_var;
  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  if($1 != *((*z_var)->value.str.val)) {
    char c[2];
    efree((*z_var)->value.str.val);
    c[0] = $1;
    c[1] = 0;
    (*z_var)->value.str.val = estrdup(c);
  }
}

%typemap(varout) char *
{
  zval **z_var;
  char *s1;

  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  s1 = Z_STRVAL_PP(z_var);
  if((s1 == NULL) || ($1 == NULL) || zend_binary_strcmp(s1, strlen(s1), $1, strlen($1) )) {
    if(s1)
      efree(s1);
    if($1) {
      (*z_var)->value.str.val = estrdup($1);
      (*z_var)->value.str.len = strlen($1) +1;
    } else {
      (*z_var)->value.str.val = 0;
      (*z_var)->value.str.len = 0;
    }
 }
}

%typemap(varout) SWIGTYPE
{
  zval **z_var;

  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  SWIG_SetPointerZval(*z_var, (void*)&$1, $&1_descriptor, $owner);
}

%typemap(varout) SWIGTYPE []
{
  zval **z_var;

  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  if($1) 
  	SWIG_SetPointerZval(*z_var, (void*)$1, $1_descriptor, $owner);
}

%typemap(varout) char [ANY]
{
  zval **z_var;
  char *s1;
deliberate error cos this code looks bogus to me
  zend_hash_find(&EG(symbol_table), "$1" ,strlen("$1")+1, (void**)&z_var);
  s1 = Z_STRVAL_PP(z_var);
  if((s1 == NULL) || zend_binary_strcmp(s1, strlen(s1), $1, strlen($1))) {

    if($1) {
      (*z_var)->value.str.val = estrdup($1);
      (*z_var)->value.str.len = strlen($1)+1;
    } else {
      (*z_var)->value.str.val = 0;
      (*z_var)->value.str.len = 0;
    }
  }
}

%typemap(varout) SWIGTYPE *, SWIGTYPE &
{
  zval **z_var;

  zend_hash_find(&EG(symbol_table), "$1", strlen("$1")+1, (void**)&z_var);
  SWIG_SetPointerZval(*z_var, (void*)$1, $1_descriptor, $owner);
}



/* Typemaps for constants */

%typemap(consttab) int, unsigned int, short, unsigned short, long, unsigned long, unsigned char, signed char, bool, enum SWIGTYPE
	"REGISTER_LONG_CONSTANT( \"$symname\", $value, CONST_CS | CONST_PERSISTENT);";

%typemap(consttab) float, double
	"REGISTER_DOUBLE_CONSTANT(\"$symname\", $value, CONST_CS | CONST_PERSISTENT);";

%typemap(consttab) char, char *
	"REGISTER_STRING_CONSTANT(\"$symname\", \"$value\", CONST_CS | CONST_PERSISTENT);";

%typemap(consttab) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] {
	char *cp;
	SWIG_SetPointerChar(&cp, (void*)$value, $1_descriptor);
	REGISTER_STRING_CONSTANT("$symname", cp, CONST_CS | CONST_PERSISTENT);
}

/* Some ANSI C typemaps */

%apply unsigned long { size_t };

%init %{
  SWIG_php_minit {
    SWIG_InitializeModule(0);
%}

/* php kewords */
/* please test and activate */
//%include "phpkw.swg"
