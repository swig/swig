/*
 * php4.swg
 *
 * PHP4 runtime library
 *
 */

#ifdef __cplusplus
extern "C" {
#endif
#include "zend.h"
#include "zend_API.h"
#include "php.h"

// These TSRMLS_ stuff should already be defined now, but with older php under
// redhat are not...
#ifndef TSRMLS_D
#define TSRMLS_D
#endif
#ifndef TSRMLS_DC
#define TSRMLS_DC
#endif
#ifndef TSRMLS_C
#define TSRMLS_C
#endif
#ifndef TSRMLS_CC
#define TSRMLS_CC
#endif

#ifdef __cplusplus
}
#endif

// local scope self_constructors are set to 1 inside function wrappers
// which are also class constructors, so that the php4.swg output typemaps
// know whether or not to wrap returned objects in this_ptr or a new object
int self_constructor=0;

// empty zend destructor for types without one
static ZEND_RSRC_DTOR_FUNC(SWIG_landfill) {};

SWIGRUNTIME(void)
SWIG_MakePtr(char *c, void *ptr, swig_type_info *ty) {
  static char hex[17] = "0123456789abcdef";
  unsigned long p, s;
  char data[32], *r;

  r = data;
  p = (unsigned long) ptr;
  if (p > 0) {
    while (p > 0) {
      s = p & 0xf;
      *(r++) = hex[s];
      p = p >> 4;
    }
    *r = '_';
    while (r >= data) {
      *(c++) = *(r--);
    }
    strcpy (c, ty->name);
  } else {
    strcpy (c, "NULL");
  }
}

SWIGRUNTIME(void)
__SWIG_SetPointerChar(char **c, void *ptr, swig_type_info *type) {
   char data[512];

   SWIG_MakePtr(data, ptr, type);
   *c = estrdup(data);

}

#define SWIG_SetPointerZval(a,b,c) SWIG_ZTS_SetPointerZval(a,b,c, SWIG_module_entry TSRMLS_CC)

SWIGRUNTIME(void)
SWIG_ZTS_SetPointerZval(zval *z, void *ptr, swig_type_info *type, zend_module_entry* module_entry TSRMLS_DC) {
  // No need to call SWIG_MakePtr here!
  if (type->clientdata) { 
    //Assert that type->clientdata is not 0
    ZEND_REGISTER_RESOURCE(z, ptr, (int)type->clientdata);
    return;
  } else { // have to deal with old fashioned string pointer?
           // but this should not get this far
    zend_error(E_ERROR, "Type: %s not registered with zend",type->name);
  }
}

SWIGRUNTIME(int)
_SWIG_ConvertPtr(char *c, void **ptr, swig_type_info *ty) {
   register int d;
   unsigned long p;
   swig_type_info *tc;

   if(c == NULL) {
   	*ptr = 0;
	return 0;
   }

   p = 0;
   if (*c != '_') {
    *ptr = (void *) 0;
    if (strcmp(c,"NULL") == 0) {
	return 0;
    } else {
	goto type_error;
    }
  }

    c++;
    /* Extract hex value from pointer */
    while ((d = *c)) {
      if ((d >= '0') && (d <= '9'))
        p = (p << 4) + (d - '0');
      else if ((d >= 'a') && (d <= 'f'))
        p = (p << 4) + (d - ('a'-10));
      else
        break;
      c++;
    }
    *ptr = (void *) p;
	
    if(ty) {
	tc = SWIG_TypeCheck(c,ty);
	if(!tc) goto type_error;
	*ptr = SWIG_TypeCast(tc, (void*)p);
    }
    return 0;

type_error:

    return -1;
}

SWIGRUNTIME(int)
SWIG_ZTS_ConvertResourcePtr(zval *z, void **ptr, swig_type_info *ty TSRMLS_DC) {
  void * p;
  int type;
  swig_type_info *tc;

  p = (void *) zend_list_find(z->value.lval,&type);
  if (type==-1) return -1;

  if (ty) {
    char * type_name=NULL;
    // Now get type name...
    if (!(type_name=zend_rsrc_list_get_rsrc_type(z->value.lval))) {
      return -1;
    } else {
      tc = SWIG_TypeCheck(type_name,ty);
      if (!tc) return -1;
      *ptr = SWIG_TypeCast(tc, (void*)p);
    }
  } else {
    *ptr = (void *) p;
  }
  return 0;
}

#define SWIG_ConvertPtr(a,b,c) SWIG_ZTS_ConvertPtr(a,b,c TSRMLS_CC)

SWIGRUNTIME(int)
SWIG_ZTS_ConvertPtr(zval *z, void **ptr, swig_type_info *ty TSRMLS_DC) {
   char *c;
   zval *val;
   
   if(z == NULL) {
	*ptr = 0;
	return 0;
   }

   // This could be structured better but will be cleaned up soon.
   // We allow passing of a STRING or RESOURCE pointing to the object
   // or an OBJECT whose _cPtr is a string or resource pointing to the object
   if (z->type==IS_OBJECT) {
     zval ** _cPtr;
     if (zend_hash_find(HASH_OF(z),"_cPtr",sizeof("_cPtr"),(void**)&_cPtr)==SUCCESS) {
       // Don't co-erce to string if it isn't
       if ((*_cPtr)->type==IS_STRING) c = Z_STRVAL_PP(_cPtr);
       else if ((*_cPtr)->type==IS_RESOURCE) {
         return SWIG_ZTS_ConvertResourcePtr(*_cPtr,ptr,ty TSRMLS_CC);
       } else goto type_error; // _cPtr was not string or resource property
     } else goto type_error; // can't find property _cPtr
   } else if (z->type==IS_RESOURCE) {
     return SWIG_ZTS_ConvertResourcePtr(z,ptr,ty TSRMLS_CC);
   } else c = Z_STRVAL_P(z); // was not object or resource
   return _SWIG_ConvertPtr(c,ptr,ty);

type_error:

    return -1;
}

