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
SWIGEXPORT(int) SWIG_ConvertPtrFromString(Tcl_Interp *, char *, void **, _swig_type_info *);
SWIGEXPORT(int) SWIG_ConvertPtr(Tcl_Interp *, Tcl_Obj *, void **, _swig_type_info *);
SWIGEXPORT(void) SWIG_MakePtr(char *, void *, _swig_type_info *);
SWIGEXPORT(Tcl_Obj *) SWIG_NewPointerObj(void *, _swig_type_info *);
SWIGEXPORT(int) SWIG_GetArgs(Tcl_Interp *, int, Tcl_Obj *CONST [], const char *, ...);
SWIGEXPORT(char *) SWIG_PointerTypeFromString(char *c);
#else

/* Convert a pointer value */
SWIGSTATICRUNTIME(int)
SWIG_ConvertPtrFromString(Tcl_Interp *interp, char *c, void **ptr, _swig_type_info *ty)
{
  unsigned long p;
  register int d;
  _swig_type_info *tc;
  p = 0;
  /* Pointer values must start with leading underscore */
  if (*c != '_') {
    *ptr = (void *) 0;
    if (strcmp(c,"NULL") == 0) return TCL_OK;
  }
  c++;
  /* Extract hex value from pointer */
  while (d = *c) {
    if ((d >= '0') && (d <= '9'))
      p = (p << 4) + (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      p = (p << 4) + (d - ('a'-10));
    else
      break; 
    c++;
  }
  *ptr = (void *) p;
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) {
      Tcl_SetResult(interp,"Type error. Expected ", TCL_STATIC);
      Tcl_AppendElement(interp, ty->name);
      return TCL_ERROR;
    }
    *ptr = SWIG_TypeCast(tc,p);
  }
  return TCL_OK;
}


/* Convert a pointer value */
SWIGSTATICRUNTIME(int)
SWIG_ConvertPtr(Tcl_Interp *interp, Tcl_Obj *oc, void **ptr, _swig_type_info *ty)
{
  return SWIG_ConvertPtrFromString(interp, Tcl_GetStringFromObj(oc,NULL), ptr, ty);
}


/* Convert a pointer value */
SWIGSTATICRUNTIME(char *)
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

/* Take a pointer and convert it to a string */
SWIGSTATICRUNTIME(void) 
SWIG_MakePtr(char *c, void *ptr, _swig_type_info *ty) {
  static char hex[17] = "0123456789abcdef";
  unsigned long p, s;
  char result[24], *r; 
  r = result;
  p = (unsigned long) ptr;
  if (p > 0) {
    while (p > 0) {
      s = p & 0xf;
      *(r++) = hex[s];
      p = p >> 4;
    }
    *r = '_';
    while (r >= result)
      *(c++) = *(r--);
    strcpy (c, ty->name);
  } else {
    strcpy (c, "NULL");
  }
}

/* Create a new pointer object */
SWIGSTATICRUNTIME(Tcl_Obj *)
SWIG_NewPointerObj(void *ptr, _swig_type_info *type) {
  char result[256];
  Tcl_Obj *robj;
  SWIG_MakePtr(result,ptr,type);
  robj = Tcl_NewStringObj(result,-1);
  return robj;
}

/* Get arguments */
SWIGSTATICRUNTIME(int)
SWIG_GetArgs(Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[], const char *fmt, ...)
{
  int        argno = 0, opt = 0, tempi;
  int        us = 0;
  double     tempd;
  const char *c;
  va_list    ap;
  void      *vptr;
  _swig_type_info *ty;

  va_start(ap,fmt);
  for (c = fmt; (*c && (*c != ':')); c++,argno++) {
    if (*c == '|') {
      opt = 1;
      c++;
    }
    if (argno >= (objc-1)) {
      if (!opt) {
	Tcl_SetResult(interp,"Wrong # args. ", TCL_STATIC);
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
	ty = (_swig_type_info *) va_arg(ap, void *);
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
    Tcl_SetResult(interp,"Wrong # args.", TCL_STATIC);
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

/* Structure for command table */
typedef struct {
  const char *name;
  int       (*wrapper)(ClientData, Tcl_Interp *, int, Tcl_Obj *CONST []);
  ClientData  clientdata;
} _swig_command_info;

/* Structure for variable linking table */
typedef struct {
  const char *name;
  void *addr;
  char * (*get)(ClientData, Tcl_Interp *, char *, char *, int);
  char * (*set)(ClientData, Tcl_Interp *, char *, char *, int);
} _swig_var_info;


#ifdef __cplusplus
}
#endif

