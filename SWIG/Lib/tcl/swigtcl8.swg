/*
 * $Header$
 * 
 * swigtcl8.swg
 */

#include <tcl.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Constant table */

#define SWIG_TCL_INT     1
#define SWIG_TCL_FLOAT   2
#define SWIG_TCL_STRING  3
#define SWIG_TCL_POINTER 4
#define SWIG_TCL_BINARY  5

/* Constant information structure */
typedef struct swig_const_info {
    int type;
    char *name;
    long lvalue;
    double dvalue;
    void   *pvalue;
    swig_type_info **ptype;
} swig_const_info;

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
SWIGEXPORT(void)      SWIG_Acquire(void *ptr);
SWIGEXPORT(int)       SWIG_Disown(void *ptr);
SWIGEXPORT(void)      SWIG_InstallConstants(Tcl_Interp *interp, struct swig_const_info constants[]);
SWIGEXPORT(Tcl_Obj *) SWIG_GetConstant(const char *key);

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
  register unsigned char uu = 0;
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

static Tcl_HashTable   swigconstTable;
static int             swigconstTableinit = 0;

/* Install Constants */
SWIGRUNTIME(void)
SWIG_InstallConstants(Tcl_Interp *interp, swig_const_info constants[]) {
  int i;
  Tcl_Obj *obj;
  Tcl_HashEntry *entryPtr;
  int            newobj;

  if (!swigconstTableinit) {
    Tcl_InitHashTable(&swigconstTable, TCL_STRING_KEYS);
    swigconstTableinit = 1;
  }
  for (i = 0; constants[i].type; i++) {
    switch(constants[i].type) {
    case SWIG_TCL_INT:
      obj = Tcl_NewIntObj(constants[i].lvalue);
      break;
    case SWIG_TCL_FLOAT:
      obj = Tcl_NewDoubleObj(constants[i].dvalue);
      break;
    case SWIG_TCL_STRING:
      obj = Tcl_NewStringObj((char *) constants[i].pvalue,-1);
      break;
    case SWIG_TCL_POINTER:
      obj = SWIG_NewPointerObj(constants[i].pvalue, *(constants[i]).ptype);
      break;
    case SWIG_TCL_BINARY:
      obj = SWIG_NewPackedObj(constants[i].pvalue, constants[i].lvalue, *(constants[i].ptype));
      break;
    default:
      obj = 0;
      break;
    }
    if (obj) {
      Tcl_ObjSetVar2(interp,Tcl_NewStringObj(constants[i].name,-1), NULL, obj, TCL_GLOBAL_ONLY);
      entryPtr = Tcl_CreateHashEntry(&swigconstTable, constants[i].name, &newobj);
      Tcl_SetHashValue(entryPtr, (ClientData) obj);
    }
  }
}

SWIGRUNTIME(Tcl_Obj *)
SWIG_GetConstant(const char *key) {
  Tcl_HashEntry *entryPtr;
  if (!swigconstTableinit) return 0;
  entryPtr = Tcl_FindHashEntry(&swigconstTable, key);
  if (entryPtr) {
    return (Tcl_Obj *) Tcl_GetHashValue(entryPtr);
  }
  printf("Searching %s\n", key);
  return 0;
}

/* Get arguments */
SWIGRUNTIME(int)
SWIG_GetArgs(Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[], const char *fmt, ...)
{
  int        argno = 0, opt = 0, tempi;
  double     tempd;
  const char *c;
  va_list    ap;
  void      *vptr;
  Tcl_Obj   *obj = 0;
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
      if (isupper(*c)) {
	obj = SWIG_GetConstant(Tcl_GetStringFromObj(objv[argno+1],0));
	if (!obj) obj = objv[argno+1];
      } else {
	obj = objv[argno+1];
      }
      switch(*c) {
      case 'i': case 'I':
      case 'l': case 'L':
      case 'h': case 'H':
      case 'b': case 'B':
	if (Tcl_GetIntFromObj(interp,obj,&tempi) != TCL_OK) goto argerror;
	if ((*c == 'i') || (*c == 'I')) *((int *)vptr) = tempi;
	else if ((*c == 'l') || (*c == 'L')) *((long *)vptr) = tempi;
	else if ((*c == 'h') || (*c == 'H')) *((short*)vptr) = tempi;
	else if ((*c == 'b') || (*c == 'B')) *((unsigned char *)vptr) = tempi;
	break;
      case 'f': case 'F':
      case 'd': case 'D':
	if (Tcl_GetDoubleFromObj(interp,obj,&tempd) != TCL_OK) goto argerror;
	if ((*c == 'f') || (*c == 'F')) *((float *) vptr) = tempd;
	else if ((*c == 'd') || (*c == 'D')) *((double*) vptr) = tempd;
	break;
      case 's': case 'S':
	if (*(c+1) == '#') {
	  int *vlptr = (int *) va_arg(ap, void *);
	  *((char **) vptr) = Tcl_GetStringFromObj(obj, vlptr);
	  c++;
	} else {
	  *((char **)vptr) = Tcl_GetStringFromObj(obj,NULL);
	}
	break;
      case 'c': case 'C':
	*((char *)vptr) = *(Tcl_GetStringFromObj(obj,NULL));
	break;
      case 'p': case 'P':
	ty = (swig_type_info *) va_arg(ap, void *);
	if (SWIG_ConvertPtr(interp, obj, (void **) vptr, ty) == TCL_ERROR) goto argerror;
	break;
      case 'o': case 'O':
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
    sprintf(temp,"%d", argno+1);
    Tcl_AppendResult(interp,strchr(fmt,':'), " argument ", temp, NULL);
    va_end(ap);
    return TCL_ERROR;
  }
}

/* Object support */
static Tcl_HashTable  swigobjectTable;
static int            swigobjectTableinit = 0;

/* Acquire ownership of a pointer */
SWIGRUNTIME(void)
SWIG_Acquire(void *ptr)
{
  Tcl_HashEntry *entryPtr;
  int newobj;
  if (!swigobjectTableinit) {
    Tcl_InitHashTable(&swigobjectTable, TCL_ONE_WORD_KEYS);
    swigobjectTableinit = 1;
  }
  entryPtr = Tcl_CreateHashEntry(&swigobjectTable, (char *) ptr, &newobj);
}

/* Disown a pointer.  Returns 1 if we owned it to begin with */
SWIGRUNTIME(int)
SWIG_Disown(void *ptr)
{
  Tcl_HashEntry *entryPtr;
  if (!swigobjectTableinit) return 0;
  entryPtr = Tcl_FindHashEntry(&swigobjectTable, (char *) ptr);
  if (entryPtr) {
    Tcl_DeleteHashEntry(entryPtr);
    return 1;
  } 
  return 0;
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




