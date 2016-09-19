/* -----------------------------------------------------------------------------
 * dukrun.swg
 *
 * This file contains the runtime support for Duktape modules
 * and includes code for managing global variables and pointer
 * type checking.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------------
 * global swig types
 * ----------------------------------------------------------------------------- */
/* Constant table */
#define SWIG_DUK_INT     1
#define SWIG_DUK_FLOAT   2
#define SWIG_DUK_STRING  3
#define SWIG_DUK_POINTER 4
#define SWIG_DUK_BINARY  5
#define SWIG_DUK_CHAR    6

/* Structure for variable linking table */
typedef struct {
  const char *name;
  duk_c_function get;
  duk_c_function set;
} swig_duk_var_info;

typedef struct swig_duk_method {
  const char *name;
  duk_c_function func;
} swig_duk_method;

/* Constant information structure */
typedef struct {
  int type;
  char *name;
  long lvalue;
  double dvalue;
  void *pvalue;
  swig_type_info **ptype;
} swig_duk_const_info;

typedef struct {
  const char *name;
  duk_c_function getter;
  duk_c_function setter;
} swig_duk_property;

struct swig_duk_class;
/* Can be used to create namespaces. */
typedef struct swig_duk_namespace {
  const char *name;
  duk_function_list_entry *ns_methods;
  swig_duk_property *ns_properties;
  swig_duk_const_info *ns_constants;
  struct swig_duk_class **ns_classes;
  struct swig_duk_namespace **ns_namespaces;
} swig_duk_namespace;

typedef struct swig_duk_class {
  const char *name; /* Name that this class has in Duktape */
  const char *fqname; /* Fully qualified name - Scope + class name */
  swig_type_info   **type;
  duk_c_function  constructor;
  void (*destructor)(void *);
  swig_duk_method   *methods;
  swig_duk_property *properties;
  swig_duk_namespace *cls_static;
  swig_duk_method   *prototype;
  struct swig_duk_class **bases;
  const char **base_names;
} swig_duk_class;

/* this is the struct for wrapping all pointers in SwigDuk
*/
typedef struct {
  swig_type_info   *type;
  bool own;  /* true if owned & must be destroyed */
  void *ptr;
} swig_duk_userdata;

/* this is the struct for wrapping arbitrary packed binary data
(currently it is only used for member function pointers)
the data ordering is similar to swig_duk_userdata, but it is currently not possible
to tell the two structures apart within SWIG, other than by looking at the type
*/
typedef struct {
  swig_type_info   *type;
  bool     own;  /* true if owned & must be destroyed */
  char data[1];  /* arbitary amount of data */    
} swig_duk_rawdata;

SWIGRUNTIME duk_ret_t _wrap_SwigObject_disown(duk_context *ctx)
{
  duk_size_t sz;
  duk_push_this(ctx);
  duk_get_prop_string(ctx, -1, "\xFFprivate");
  swig_duk_userdata *udata = (swig_duk_userdata*)duk_to_fixed_buffer(ctx, -1, &sz);
  udata->own = false;
  duk_pop_n(ctx, 2); /* Clean up stack */
  return 0; // undefined
}

SWIGRUNTIME duk_ret_t _wrap_SwigObject_getCPtr(duk_context *ctx)
{
  duk_size_t sz;
  long result;
  duk_push_this(ctx);
  duk_get_prop_string(ctx, -1, "\xFFprivate");
  swig_duk_userdata *udata = (swig_duk_userdata*)duk_to_fixed_buffer(ctx, -1, &sz);
  duk_pop_n(ctx, 2);

  result = (long)udata->ptr;
  duk_push_number(ctx, (duk_double_t)result);

  return 1;
}

SWIGRUNTIME duk_ret_t _wrap_SwigObject_equals(duk_context *ctx)
{
  bool result;
  duk_size_t sz1, sz2;

  if(duk_get_top(ctx) != 2) {
    duk_push_string(ctx, "Comparison requires two arguments.");
    duk_throw(ctx);
  }

  duk_get_prop_string(ctx, -1, "\xFFprivate");
  swig_duk_userdata *udata = (swig_duk_userdata*)duk_to_fixed_buffer(ctx, -1, &sz1);
  duk_pop(ctx);

  duk_get_prop_string(ctx, -2, "\xFFprivate");
  swig_duk_userdata *udata2 = (swig_duk_userdata*)duk_to_fixed_buffer(ctx, -1, &sz2);
  duk_pop(ctx);

  result = (udata->ptr == udata2->ptr);
  duk_push_boolean(ctx, result);

  return 1;
}

SWIGRUNTIME duk_function_list_entry _SwigObject_functions[] = {
  {
    "disown",_wrap_SwigObject_disown, 0
  },
  {
    "equals",_wrap_SwigObject_equals, 2
  },
  {
    "getCPtr",_wrap_SwigObject_getCPtr, 0
  },
  {
    NULL, NULL, 0
  }
};


/* Common SWIG API */
#define SWIG_NewPointerObj(ctx, ptr, type, owner)       SWIG_duk_NewPointerObj(ctx, (void *)ptr, type, owner)
#define SWIG_ConvertPtr(ctx, obj, ptr, type, flags)    SWIG_duk_ConvertPtr(ctx,obj,ptr,type,flags)
#define SWIG_MustGetPtr(ctx, obj, type,flags, argnum,fnname)  SWIG_duk_MustGetPtr(ctx,obj, type,flags, argnum,fnname)
/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(ctx, obj, ptr, sz, ty)       SWIG_duk_ConvertPacked(ctx, obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ctx, ptr, sz, type)      SWIG_duk_NewPackedObj(ctx, ptr, sz, type)

/* Runtime API */
#define SWIG_MODULE_CLIENTDATA_TYPE duk_context*

/* Contract support */
#define SWIG_contract_assert(expr, msg)  \
  if (!(expr)) { duk_push_string(ctx, (char *) msg); duk_throw(ctx); } else

/* helper #defines */
#define SWIG_fail {duk_throw(ctx);}
#define SWIG_fail_arg(func_name,argnum,type) \
  {duk_push_sprintf(ctx,"Error in %s (arg %d), expected '%s' got '%s'",\
  func_name,argnum,type,SWIG_duk_typename(ctx, argnum));\
  duk_throw(ctx);}
#define SWIG_fail_ptr(func_name,argnum,type) \
  {if (duk_is_object(ctx, argnum)) {\
   duk_get_prop_string(ctx, argnum, "\xFFprivate");\
  }else{\
   duk_dup(ctx, argnum);\
  }\
  duk_push_sprintf(ctx,"Error in %s (arg %d), expected '%s' got '%s'",\
  func_name,argnum,(type && type->str)?type->str:"void*",SWIG_duk_typename(ctx, -1));\
  duk_throw(ctx);}
#define SWIG_check_num_args(func_name,a,b) \
  if (duk_get_top(ctx)<a || duk_get_top(ctx)>b) \
  {duk_push_sprintf(ctx,"Error in %s expected %d..%d args, got %d",func_name,a,b,duk_get_top(ctx));\
  duk_throw(ctx);}

#define SWIG_duk_add_function(ctx,n,f) \
  (duk_pushstring(ctx, n), \
      duk_push_c_function(ctx, f), \
      duk_rawset(ctx,-3))

#define SWIG_duk_add_boolean(ctx,n,b) \
  (duk_push_string(ctx, n), \
  duk_push_boolean(ctx, b)

/* special helper for allowing 'undefined' for usertypes */
#define SWIG_isptrtype(ctx,I) SWIG_duk_isptrtype(ctx, I)

#define SWIG_exception_fail


bool SWIG_duk_isptrtype(duk_context *ctx, duk_idx_t idx) {
    if (duk_is_undefined(ctx, idx)) return true; // NULL pointer
    if (duk_is_object(ctx, idx)) {
        duk_get_prop_string(ctx, idx, "\xFFprivate");
        bool is_fb = duk_is_fixed_buffer(ctx, -1);
        duk_pop(ctx);
        return is_fb;
    }
    return false;
}

/* -----------------------------------------------------------------------------
 * global variable support code
 * ----------------------------------------------------------------------------- */

const char *duk_typename(duk_int_t type) {
  switch(type) {
    case DUK_TYPE_NONE:
      return "Unknown type (invalid index?)";
    case DUK_TYPE_UNDEFINED:
      return "Undefined";
    case DUK_TYPE_NULL:
      return "Null";
    case DUK_TYPE_BOOLEAN:
      return "Boolean";
    case DUK_TYPE_NUMBER:
      return "Number";
    case DUK_TYPE_STRING:
      return "String";
    case DUK_TYPE_OBJECT:
      return "Object";
    case DUK_TYPE_BUFFER:
      return "Buffer";
    case DUK_TYPE_POINTER:
      return "Pointer";
    case DUK_TYPE_LIGHTFUNC:
      return "LightFunc";
  }
  return "Impossible";
}

/* a function to get the typestring of a piece of data */
SWIGRUNTIME const char *SWIG_duk_typename(duk_context *ctx, duk_idx_t idx)
{
  swig_duk_userdata *usr;
  duk_size_t sz;
  if (duk_is_buffer(ctx,idx))
  {
    usr=(swig_duk_userdata*)duk_get_buffer(ctx,idx,&sz);  /* get data */
    if (usr && usr->type && usr->type->str)
      return usr->type->str;
    return "userdata (unknown type)";
  }
  return duk_typename(duk_get_type(ctx, idx));
}

/* -----------------------------------------------------------------------------
 * global variable support code: classes
 * ----------------------------------------------------------------------------- */

SWIGINTERN duk_ret_t JS_veto_set_variable(duk_context *ctx)
{
  duk_push_string(ctx, "Tried to write read-only variable.");
  duk_throw(ctx);
  return duk_get_top(ctx); /* We should never get here, but stifle warning. */
}

/* 
 * Install properties into an object.
 * This asserts that the target object is on the top of the value stack on entry.
 */
SWIGINTERN void
swig_duk_install_properties(
  duk_context *ctx,
  duk_idx_t obj_idx,
  swig_duk_property *properties)
{
  assert(duk_is_object(ctx, obj_idx)); /* This better be the right object! */
  /* The target object is on top of the value stack after each iteration. */
  for(swig_duk_property *prop = properties; (*prop).name != NULL; prop++) {
    #ifdef SWIGRUNTIME_DEBUG
    printf("Installing property: %s\n", prop->name);
    #endif
    duk_push_string(ctx, prop->name);
    duk_push_c_function(ctx, prop->getter, 0 /* nargs */);
    duk_push_c_function(ctx, prop->setter, 1 /* nargs */);
    duk_def_prop(ctx,obj_idx,DUK_DEFPROP_HAVE_GETTER|DUK_DEFPROP_HAVE_SETTER|DUK_DEFPROP_HAVE_CONFIGURABLE);
  }
}

/* creates the swig registry */
SWIGINTERN void SWIG_duk_create_class_registry(duk_context *ctx)
{
  /* create the SWIG registry object */
  duk_set_top(ctx, 0);
  duk_push_global_stash(ctx);
  duk_push_string(ctx, "registry");
  duk_push_object(ctx);
  duk_put_prop(ctx, -3);
  /* The heap stash is at the top of the value stack now. */
}


/* gets the swig registry (or creates it) */
SWIGINTERN void SWIG_duk_get_class_registry(duk_context *ctx) {
  duk_set_top(ctx, 0);
  duk_push_global_stash(ctx);
  duk_get_prop_string(ctx, -1, "registry");
  if (!duk_is_object(ctx,-1))  /* not there */
  {  /* must be first time, so add it */
    duk_pop_n(ctx,1);  /* remove the result */
    SWIG_duk_create_class_registry(ctx);
    /* then get the class registry */
    duk_get_prop_string(ctx, -1, "registry");
  }
}

/* Helper function to get the classes prototype from the register */
SWIGINTERN void SWIG_duk_get_class_prototype(duk_context *ctx,const char *cname)
{
  SWIG_duk_get_class_registry(ctx);  /* get the registry */
  duk_get_prop_string(ctx, -1, cname);  /* get the name */
}


/* -----------------------------------------------------------------------------
 * Class/structure conversion fns
 * ----------------------------------------------------------------------------- */

/* helper to add prototype to new duk object */
SWIGINTERN void SWIG_duk_AddPrototype(duk_context *ctx,swig_type_info *type)
{
  #ifdef SWIGRUNTIME_DEBUG
  printf("Adding prototype!\n");
  #endif
  if (type->clientdata)  /* there is clientdata: so add the prototype */
  {
    #ifdef SWIGRUNTIME_DEBUG
    printf("Adding prototype %s\n", ((swig_duk_class*)type->clientdata)->fqname);
    #endif
    SWIG_duk_get_class_prototype(ctx,((swig_duk_class*)(type->clientdata))->fqname);
    if (duk_is_object(ctx,-1)) {
      // FIXME
      duk_set_prototype(ctx,-2);
    }
    else
    {
      duk_pop_n(ctx,1);
    }
  }
}

/* pushes a new userdata buffer into the duk stack */
SWIGRUNTIME duk_idx_t SWIG_duk_NewPointerObj(duk_context *ctx,void *ptr,swig_type_info *type,bool own)
{
  duk_size_t sz;
  swig_duk_userdata *usr;
  if (!ptr){
    #ifdef SWIGRUNTIME_DEBUG
    printf("WARNING: NewPointerObj returning a NULL pointer.\n");
    #endif
    duk_push_undefined(ctx);
    return 1;
  }
  duk_idx_t obj_idx = duk_push_object(ctx);
  usr=(swig_duk_userdata*)duk_push_fixed_buffer(ctx,sizeof(swig_duk_userdata));  /* get data */
  usr->ptr=ptr;  /* set the ptr */
  usr->type=type;
  usr->own=own;
  duk_put_prop_string(ctx, obj_idx, "\xFFprivate");
  if (type && type->clientdata) {
    duk_push_heapptr(ctx, type->clientdata);
    duk_set_prototype(ctx, obj_idx);
  }
  //SWIG_duk_AddPrototype(ctx,type); /* add prototype */
  return 1;
}


/* 
 * takes a object from the duk stack & converts it into an object of the correct type
 * (if possible)
 */
SWIGRUNTIME int SWIG_duk_ConvertPtr(duk_context *ctx,duk_idx_t obj_idx,void **ptr,swig_type_info *type,int flags)
{
  duk_size_t sz;
  swig_duk_userdata *usr;
  swig_cast_info *cast;
  /* special case: duk undefined => NULL pointer */
  if (duk_is_undefined(ctx, obj_idx)){
    #ifdef SWIGRUNTIME_DEBUG
    printf("Converted a NULL pointer.\n");
    #endif
    *ptr=NULL;
    return SWIG_OK;
  }
  if (duk_get_prop_string(ctx, obj_idx, "\xFFprivate")) {
    if (!duk_is_undefined(ctx, -1)) {
      usr=(swig_duk_userdata*)duk_to_fixed_buffer(ctx, -1, &sz);  /* get data */ 
      duk_pop_n(ctx, 1); /* clean up the stack */
    } else {
      goto sadplace;
    }
  } else {
    goto sadplace;
  }
  if (usr) {
    if (flags & SWIG_POINTER_DISOWN) {
      /* must disown the object */
      usr->own=0;
    }
    if (!type) {
      /* special cast void*, no casting fn */
      *ptr=usr->ptr;
      return SWIG_OK; /* ok */
    }
    cast=SWIG_TypeCheckStruct(usr->type,type); /* performs normal type checking */
    if (cast) {
      int newmemory = 0;
      *ptr=SWIG_TypeCast(cast,usr->ptr,&newmemory);
      assert(!newmemory); /* newmemory handling not yet implemented */
      return SWIG_OK;  /* ok */
    }
  }
  sadplace:
    return SWIG_ERROR;  /* error */
}

/* -----------------------------------------------------------------------------
 * executing Javascript code from within the wrapper
 * ----------------------------------------------------------------------------- */

#ifndef SWIG_DOSTRING_FAIL /* Allows redefining of error function */
#define SWIG_DOSTRING_FAIL(S) fprintf(stderr,"%s\n",S)
#endif
/*
 * Executes a C string in Duktape
 */
SWIGINTERN int 
SWIG_duk_dostring(duk_context *ctx, const char *str) {
  duk_idx_t top, ret;
  if (str==0 || str[0]==0) return 0; /* nothing to do */
  top=duk_get_top(ctx); /* save stack */
  ret = duk_peval_string(ctx, str);
  if (duk_is_eval_error(ctx, ret)) {
    /* Handle eval error */
  }
  duk_set_top(ctx, top); /* restore the stack */
  return 0;
}    

#ifdef __cplusplus
}
#endif

/* ------------------------------ end dukrun.swg  ------------------------------ */
