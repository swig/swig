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
#ifdef __cplusplus
}
#endif

// local scope self_constructors are set to 1 inside function wrappers
// which are also class constructors, so that the php4.swg output typemaps
// know whether or not to wrap returned objects in this_ptr or a new object
int self_constructor=0;

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
SWIG_SetPointerChar(char **c, void *ptr, swig_type_info *type) {
   char data[512];

   SWIG_MakePtr(data, ptr, type);
   *c = estrdup(data);

}

SWIGRUNTIME(void)
SWIG_SetPointerZval(zval *z, void *ptr, swig_type_info *type) {
   char data[512];

   SWIG_MakePtr(data, ptr, type);

   if((z->type == IS_STRING) && (z->value.str.val)) { efree(z->value.str.val); }

   z->type = IS_STRING;
   z->value.str.val = estrdup(data);
   z->value.str.len = strlen(data)+1;
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
   // We allow passing of a STRING or RESOURCE pointing to the string
   // or an OBJECT whose _cPtr is a string or resource pointing to the string
   if (z->type==IS_OBJECT) {
     zval ** _cPtr;
     if (zend_hash_find(HASH_OF(z),"_cPtr",sizeof("_cPtr"),(void**)&_cPtr)==SUCCESS) {
       // Don't co-erce to string if it isn't
       if ((*_cPtr)->type==IS_STRING) c = Z_STRVAL_PP(_cPtr);
       else if ((*_cPtr)->type==IS_RESOURCE) {
         int type;
         c = (char *) zend_list_find((*_cPtr)->value.lval,&type);
         if (! c) goto type_error;
       } else goto type_error; // _cPtr was not string or resource property
     } else goto type_error; // can't find property _cPtr
   } else if (z->type==IS_RESOURCE) {
     int type;
     c = (char *) zend_list_find(z->value.lval,&type);
     if (! c) goto type_error;
   } else c = Z_STRVAL_P(z); // was not object or resource
   return _SWIG_ConvertPtr(c,ptr,ty);

type_error:

    return -1;
}

