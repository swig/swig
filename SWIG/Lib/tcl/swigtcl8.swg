/*
 * $Header$
 * 
 * swigtcl8.swg
 */

#include <tcl.h>
#include <stdlib.h>
#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef SWIG_NOINCLUDE
SWIGEXPORT(char *)    SWIG_PackData(char *c, void *ptr, int sz);
SWIGEXPORT(char *)    SWIG_UnpackData(char *c, void *ptr, int sz);
SWIGEXPORT(int)       SWIG_ConvertPtrFromString(Tcl_Interp *, char *, void **, swig_type_info *);
SWIGEXPORT(int)       SWIG_ConvertPtr(Tcl_Interp *, Tcl_Obj *, void **, swig_type_info *);
SWIGEXPORT(int)       SWIG_ConvertPacked(Tcl_Interp *, Tcl_Obj *, void *, int sz, swig_type_info *, int);
SWIGEXPORT(void)      SWIG_MakePtr(char *, void *, swig_type_info *);
SWIGEXPORT(Tcl_Obj *) SWIG_NewPointerObj(void *, swig_type_info *);
SWIGEXPORT(Tcl_Obj *) SWIG_NewPackedObj(void *, int sz, swig_type_info *);
SWIGEXPORT(int)       SWIG_GetArgs(Tcl_Interp *, int, Tcl_Obj *CONST [], const char *, ...);
SWIGEXPORT(char *)    SWIG_PointerTypeFromString(char *c);
#else

/* Pack binary data into a string */
SWIGRUNTIME(char *)
SWIG_PackData(char *c, void *ptr, int sz) {
  static char hex[17] = "0123456789abcdef";
  int i;
  unsigned char *u = (unsigned char *) ptr;
  register unsigned char uu;
  for (i = 0; i < sz; i++,u++) {
    uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}

/* Unpack binary data from a string */
SWIGRUNTIME(char *)
SWIG_UnpackData(char *c, void *ptr, int sz) {
  register unsigned char uu;
  register int d;
  unsigned char *u = (unsigned char *) ptr;
  int i;
  for (i = 0; i < sz; i++, u++) {
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    *u = uu;
  }
  return c;
}

/* Convert a pointer value */
SWIGRUNTIME(int)
SWIG_ConvertPtrFromString(Tcl_Interp *interp, char *c, void **ptr, swig_type_info *ty)
{
  swig_type_info *tc;
  /* Pointer values must start with leading underscore */
  if (*c != '_') {
    *ptr = (void *) 0;
    if (strcmp(c,"NULL") == 0) return TCL_OK;
    Tcl_SetResult(interp, (char *) "Type error. Expected a pointer", TCL_STATIC);
    return TCL_ERROR;
  }
  c++;
  c = SWIG_UnpackData(c,ptr,sizeof(void *));
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) {
      Tcl_SetResult(interp, (char *) "Type error. Expected ", TCL_STATIC);
      Tcl_AppendElement(interp, (char *) ty->name);
      return TCL_ERROR;
    }
    *ptr = SWIG_TypeCast(tc,(void *) *ptr);
  }
  return TCL_OK;
}

/* Convert a pointer value */
SWIGRUNTIME(int)
SWIG_ConvertPtr(Tcl_Interp *interp, Tcl_Obj *oc, void **ptr, swig_type_info *ty)
{
  return SWIG_ConvertPtrFromString(interp, Tcl_GetStringFromObj(oc,NULL), ptr, ty);
}

/* Convert a pointer value */
SWIGRUNTIME(char *)
SWIG_PointerTypeFromString(char *c) {
  char d;
  /* Pointer values must start with leading underscore */
  if (*c != '_') {
    return 0;
  }
  c++;
  /* Extract hex value from pointer */
  while (d = *c) {
    if (!(((d >= '0') && (d <= '9')) || ((d >= 'a') && (d <= 'f')))) break;
    c++;
  }
  return c;
}

/* Convert a packed value value */
SWIGRUNTIME(int)
SWIG_ConvertPacked(Tcl_Interp *interp, Tcl_Obj *obj, void *ptr, int sz, swig_type_info *ty, int errors) {
  swig_type_info *tc;
  char  *c;
  
  if (!obj) goto type_error;
  c = Tcl_GetStringFromObj(obj,NULL);
  /* Pointer values must start with leading underscore */
  if (*c != '_') goto type_error;
  c++;
  c = SWIG_UnpackData(c,ptr,sz);
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
  }
  return TCL_OK;

type_error:

  if (errors) {
    if (ty) {
      Tcl_SetResult(interp, (char *) "Type error. Expect ", TCL_STATIC);
      Tcl_AppendElement(interp, (char *) ty->name);
      return TCL_ERROR;
    } else {
      Tcl_SetResult(interp, (char *) "Expected packed data.", TCL_STATIC);
      return TCL_ERROR;
    }
  }
  return TCL_ERROR;
}


/* Take a pointer and convert it to a string */
SWIGRUNTIME(void) 
SWIG_MakePtr(char *c, void *ptr, swig_type_info *ty) {
  *(c++) = '_';
  if (ptr) {
    c = SWIG_PackData(c,&ptr,sizeof(void *));
    strcpy(c,ty->name);
  } else {
    strcpy(c,(char *)"NULL");
  }
}

/* Create a new pointer object */
SWIGRUNTIME(Tcl_Obj *)
SWIG_NewPointerObj(void *ptr, swig_type_info *type) {
  Tcl_Obj *robj;
  char result[512];
  SWIG_MakePtr(result,ptr,type);
  robj = Tcl_NewStringObj(result,-1);
  return robj;
}

SWIGRUNTIME(Tcl_Obj *)
SWIG_NewPackedObj(void *ptr, int sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(type->name)) > 1000) return 0;
  *(r++) = '_';
  r = SWIG_PackData(r,ptr,sz);
  strcpy(r,type->name);
  return Tcl_NewStringObj(result,-1);
}

/* Get arguments */
SWIGRUNTIME(int)
SWIG_GetArgs(Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[], const char *fmt, ...)
{
  int        argno = 0, opt = 0, tempi;
  int        us = 0;
  double     tempd;
  const char *c;
  va_list    ap;
  void      *vptr;
  swig_type_info *ty;

  va_start(ap,fmt);
  for (c = fmt; (*c && (*c != ':')); c++,argno++) {
    if (*c == '|') {
      opt = 1;
      c++;
    }
    if (argno >= (objc-1)) {
      if (!opt) {
	Tcl_SetResult(interp, (char *) "Wrong # args. ", TCL_STATIC);
	goto argerror;
      } else {
	va_end(ap);
	return TCL_OK;
      }
    }
    vptr = va_arg(ap,void *);
    if (vptr) {
      us = 0;
      if (*c == 'u') {
	us = 1;
	c++;
      }
      switch(*c) {
      case 'i':
      case 'l':
      case 'h':
      case 'b':
	if (Tcl_GetIntFromObj(interp,objv[argno+1],&tempi) != TCL_OK) goto argerror;
	if (*c == 'i') *((int *)vptr) = tempi;
	else if (*c == 'l') *((long *)vptr) = tempi;
	else if (*c == 'h') *((short*)vptr) = tempi;
	else if (*c == 'b') *((unsigned char *)vptr) = tempi;
	break;
      case 'f':
      case 'd':
	if (Tcl_GetDoubleFromObj(interp,objv[argno+1],&tempd) != TCL_OK) goto argerror;
	if (*c == 'f') *((float *) vptr) = tempd;
	else if (*c == 'd') *((double*) vptr) = tempd;
	break;
      case 's':
	if (*(c+1) == '#') {
	  int *vlptr = (int *) va_arg(ap, void *);
	  *((char **) vptr) = Tcl_GetStringFromObj(objv[argno+1], vlptr);
	  c++;
	} else {
	  *((char **)vptr) = Tcl_GetStringFromObj(objv[argno+1],NULL);
	}
	break;
      case 'c':
	*((char *)vptr) = *(Tcl_GetStringFromObj(objv[argno+1],NULL));
	break;
      case 'p':
	ty = (swig_type_info *) va_arg(ap, void *);
	if (SWIG_ConvertPtr(interp, objv[argno+1], (void **) vptr, ty) == TCL_ERROR) goto argerror;
	break;
      case 'o':
	*((Tcl_Obj **)vptr) = objv[argno+1];
	break;
      default:
	break;
      }
    }
  }
  if ((objc-1) > argno) {
    Tcl_SetResult(interp, (char *) "Wrong # args.", TCL_STATIC);
    goto argerror;
  }
  va_end(ap);
  return TCL_OK;
  
 argerror:
  {
    char temp[32];
    sprintf(temp,"%d", argno);
    Tcl_AppendResult(interp,strchr(fmt,':'), " argument ", temp, NULL);
    va_end(ap);
    return TCL_ERROR;
  }
}

#endif

typedef int(*swig_wrapper_func)(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
typedef char *(*swig_variable_func)(ClientData, Tcl_Interp *, char *, char *, int);
typedef void(*swig_delete_func)(ClientData);

/* Structure for command table */
typedef struct {
  const char *name;
  int       (*wrapper)(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
  ClientData  clientdata;
} swig_command_info;

/* Structure for variable linking table */
typedef struct {
  const char *name;
  void *addr;
  char * (*get)(ClientData, Tcl_Interp *, char *, char *, int);
  char * (*set)(ClientData, Tcl_Interp *, char *, char *, int);
} swig_var_info;


#ifdef __cplusplus
}
#endif




