/* -----------------------------------------------------------------------------
 * perlrun.swg
 *
 * This file contains the runtime support for Perl modules
 * and includes code for managing global variables and pointer
 * type checking.
 * ----------------------------------------------------------------------------- */

/* Common SWIG API */

/* for raw pointers */
#define SWIG_ConvertPtr(obj, pp, type, flags) \
    SWIG_Perl_ConvertPtr(obj, pp, type, flags)
#define SWIG_NewPointerObjP(ptr, t, flags) \
    SWIG_Perl_MakePtr(0, ptr, t, flags, proto)
#define SWIG_NewPointerObj(ptr, t, flags) \
    SWIG_Perl_MakePtr(0, ptr, t, flags, 0)

/* for raw packed data */
#define SWIG_ConvertPacked(obj, p, s, type)             SWIG_Perl_ConvertPacked(obj, p, s, type)
#define SWIG_NewPackedObj(p, s, type)	                SWIG_Perl_NewPackedObj(p, s, type)

/* for class or struct pointers */
#define SWIG_ConvertInstance(obj, pptr, type, flags)    SWIG_ConvertPtr(obj, pptr, type, flags)
#define SWIG_NewInstanceObj(ptr, type, flags)           SWIG_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define SWIG_ConvertFunctionPtr(obj, pptr, type)        SWIG_ConvertPtr(obj, pptr, type, 0)
#define SWIG_NewFunctionPtrObj(ptr, type)               SWIG_NewPointerObj(ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define SWIG_ConvertMember(obj, ptr, sz, ty)            SWIG_ConvertPacked(obj, ptr, sz, ty)
#define SWIG_NewMemberObj(ptr, sz, type)                SWIG_NewPackedObj(ptr, sz, type)


/* Runtime API */

#define SWIG_GetModule(clientdata)                      SWIG_Perl_GetModule()
#define SWIG_SetModule(clientdata, pointer)             SWIG_Perl_SetModule(pointer)


/* Error manipulation */

#define SWIG_ErrorType(code)                            SWIG_Perl_ErrorType(code)               
#define SWIG_Error(code, msg)            		sv_setpvf(GvSV(PL_errgv),"%s %s\n", SWIG_ErrorType(code), msg)
#define SWIG_fail                        		goto fail						    

/* Perl-specific SWIG API */

#define SWIG_MakePtr(sv, ptr, type, flags)              SWIG_Perl_MakePtr(sv, ptr, type, flags, 0)
#define SWIG_MakePackedObj(sv, p, s, type)	        SWIG_Perl_MakePackedObj(sv, p, s, type)
#define SWIG_SetError(str)                              SWIG_Error(SWIG_RuntimeError, str)


#define SWIG_PERL_DECL_ARGS_1(arg1)                     (arg1)
#define SWIG_PERL_CALL_ARGS_1(arg1)                     (arg1)
#define SWIG_PERL_DECL_ARGS_2(arg1, arg2)               (arg1, arg2)
#define SWIG_PERL_CALL_ARGS_2(arg1, arg2)               (arg1, arg2)

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

/* For backward compatibility only */
#define SWIG_POINTER_EXCEPTION  0

#ifdef __cplusplus
extern "C" {
#endif

#define SWIG_OWNER   SWIG_POINTER_OWN
#define SWIG_SHADOW  SWIG_OWNER << 1

/* SWIG Perl macros */

/* Macro to declare an XS function */
#ifndef XSPROTO
#   define XSPROTO(name) void name(pTHX_ CV* cv)
#endif

/* Macro to call an XS function */
#ifdef PERL_OBJECT 
#  define SWIG_CALLXS(_name) _name(cv,pPerl) 
#else 
#  ifndef MULTIPLICITY 
#    define SWIG_CALLXS(_name) _name(cv) 
#  else 
#    define SWIG_CALLXS(_name) _name(PERL_GET_THX, cv) 
#  endif 
#endif 

#define SWIGCLASS_STATIC static SWIGUNUSED

/* Workaround for bug in perl 5.6.x croak and earlier */
#if (PERL_VERSION < 8)
#  ifdef PERL_OBJECT
#    define SWIG_croak_null() SWIG_Perl_croak_null(pPerl)
static void SWIG_Perl_croak_null(CPerlObj *pPerl)
#  else
static void SWIG_croak_null()
#  endif
{
  SV *err=ERRSV;
#  if (PERL_VERSION < 6)
  croak("%_", err);
#  else
  if (SvOK(err) && !SvROK(err)) croak("%_", err);
  croak(Nullch);
#  endif
}
#else
#  define SWIG_croak_null() croak(Nullch)
#endif


/* 
   Define how strict is the cast between strings and integers/doubles
   when overloading between these types occurs.
   
   The default is making it as strict as possible by using SWIG_AddCast
   when needed.
   
   You can use -DSWIG_PERL_NO_STRICT_STR2NUM at compilation time to
   disable the SWIG_AddCast, making the casting between string and
   numbers less strict.

   In the end, we try to solve the overloading between strings and
   numerical types in the more natural way, but if you can avoid it,
   well, avoid it using %rename, for example.
*/
#ifndef SWIG_PERL_NO_STRICT_STR2NUM
# ifndef SWIG_PERL_STRICT_STR2NUM
#  define SWIG_PERL_STRICT_STR2NUM
# endif
#endif
#ifdef SWIG_PERL_STRICT_STR2NUM
/* string takes precedence */
#define SWIG_Str2NumCast(x) SWIG_AddCast(x)  
#else
/* number takes precedence */
#define SWIG_Str2NumCast(x) x
#endif



#include <stdlib.h>

typedef struct swig_perl_type_ext_var {
  const char *name;
  MGVTBL vtbl;
} swig_perl_type_ext_var;
typedef struct swig_perl_type_ext {
  const char *name;
  MGVTBL vtbl;
  const int nattr;
  swig_perl_type_ext_var *attr;
} swig_perl_type_ext;
typedef struct swig_perl_wrap {
  HV *stash;
  void *ptr;
  IV refcnt;
} swig_perl_wrap;
SWIGINTERN HV *SWIG_Perl_OwnerTbl(HV *stash) {
  GV *gv = *(GV **)hv_fetch(stash, "OWNER", 5, TRUE);
  if (!isGV(gv))
    gv_init(gv, stash, "OWNER", 5, FALSE);
  return GvHVn(gv);
}
SWIGINTERN SV *SWIG_Perl_LookupPtr(HV *stash, void *ptr) {
  HE *ent = hv_fetch_ent(SWIG_Perl_OwnerTbl(stash),
      sv_2mortal(newSViv(PTR2IV(ptr))), 0, 0);
  /*warn("lookup(%s:%p) %s\n", HvNAME(stash), ptr, ent ? "hit" : "miss");*/
  return ent ? HeVAL(ent) : 0;
}
SWIGINTERN void SWIG_Perl_RememberPtr(swig_perl_wrap *wrap, SV *impl) {
  SV *ref = newSVsv(impl);
  sv_rvweaken(ref);
  /*warn("store (%s:%p) = %p\n", HvNAME(wrap->stash), wrap->ptr, SvRV(impl));*/
  hv_store_ent(SWIG_Perl_OwnerTbl(wrap->stash),
    sv_2mortal(newSViv(PTR2IV(wrap->ptr))), ref, 0);
}
SWIGINTERN void SWIG_Perl_ForgetPtr(swig_perl_wrap *wrap) {
  /*warn("delete(%s:%p)\n", HvNAME(wrap->stash), wrap->ptr);*/
  hv_delete_ent(SWIG_Perl_OwnerTbl(wrap->stash),
    sv_2mortal(newSViv(PTR2IV(wrap->ptr))), 0, 0);
}
SWIGINTERN int
SWIG_Perl_vtbl_svt_free(pTHX_ SV *sv, MAGIC *mg) {
  swig_perl_wrap *wrap = (swig_perl_wrap *)mg->mg_ptr;
  wrap->refcnt--;
  if(wrap->refcnt <= 0) {
    SWIG_Perl_ForgetPtr(wrap);
    /*warn("free(%p)\n", wrap);*/
    /*Safefree(wrap);*/
    free(wrap);
  }
  return 0;
}
#define SWIG_Perl_VTBL(getf, setf) \
  { getf, setf, 0, 0, SWIG_Perl_vtbl_svt_free }
SWIGINTERN MGVTBL
SWIG_Perl_default_vtbl = { 0, 0, 0, 0, SWIG_Perl_vtbl_svt_free };
#define SWIG_Perl_TypeExt(name, count, attrlist) \
  { name, SWIG_Perl_VTBL(0, 0), count, attrlist }

SWIGRUNTIME const char *
SWIG_Perl_TypeProxyName(const swig_type_info *type) {
  if (!type) return NULL;
  if (!type->clientdata) return type->name;
  return ((swig_perl_type_ext *)type->clientdata)->name;
}

/* Identical to SWIG_TypeCheck, except for strcmp comparison */
SWIGRUNTIME swig_cast_info *
SWIG_TypeProxyCheck(const char *c, swig_type_info *ty) {
  if (ty) {
    swig_cast_info *iter = ty->cast;
    while (iter) {
	  const char *tpn = SWIG_Perl_TypeProxyName(iter->type);
      if ( tpn && strcmp(tpn, c) == 0) {
        if (iter == ty->cast)
          return iter;
        /* Move iter to the top of the linked list */
        iter->prev->next = iter->next;
        if (iter->next)
          iter->next->prev = iter->prev;
        iter->next = ty->cast;
        iter->prev = 0;
        if (ty->cast) ty->cast->prev = iter;
        ty->cast = iter;
        return iter;
      }
      iter = iter->next;
    }
  }
  return 0;
}

/* wrapping & unwrapping native opaque pointers */

SWIGRUNTIME int
SWIG_Perl_ConvertMg(MAGIC *mg, void **ptr, swig_type_info *t, int flags) {
  swig_perl_wrap *wrap = (swig_perl_wrap *)mg->mg_ptr;
  if(flags & SWIG_POINTER_DISOWN)
    SWIG_Perl_ForgetPtr(wrap);
  /* TODO: other flags? */
  *ptr = wrap->ptr;
  return SWIG_OK;
}
SWIGRUNTIME int
SWIG_Perl_ConvertPtr(SV *sv, void **ptr, swig_type_info *_t, int flags) {
  swig_cast_info *tc;
  void *voidptr = (void *)0;
  MAGIC *mg;

  SvGETMAGIC(sv);
  if (!SvOK(sv)) {
    *ptr = (void *) 0;
    return SWIG_OK;
  }
  if (!SvROK(sv))
    return SWIG_ERROR;
  /* runtime type checks:
   * _t == 0 means no typecheck restrictions (void* style)
   * TypeProxyCheck() succeeds on a c/c++ inheritance
   * sv_derived_from succeeds on Perl inheritance
   */
  if (_t) {
    const char *c = HvNAME(SvSTASH(SvRV(sv)));
    tc = SWIG_TypeProxyCheck(c, _t);
    if(!tc && !sv_derived_from(sv, SWIG_Perl_TypeProxyName(_t)))
    return SWIG_ERROR;
  } else tc = 0;
  mg = mg_find(SvRV(sv), PERL_MAGIC_ext);
  if (!mg)
    return SWIG_ERROR;
  SWIG_Perl_ConvertMg(mg, &voidptr, _t, flags);
  if (tc) {
    /* TODO: implement newmemory */
    int newmemory = 0;
    *ptr = SWIG_TypeCast(tc, voidptr, &newmemory);
    assert(!newmemory);
  } else {
    *ptr = voidptr;
  }
  return SWIG_OK;
}

SWIGINTERN SV *
SWIG_Perl_WrapVar(SV *sv, MGVTBL *vtbl, swig_perl_wrap *wrap) {
  if(wrap) wrap->refcnt++;
  sv_magicext(sv, 0, PERL_MAGIC_ext, vtbl, (char *)wrap, 0);
  return sv;
}

SWIGINTERN SV *
SWIG_Perl_MakePtr(SV *sv, void *ptr, swig_type_info *t, int flags,
    SV *proto) {
  HV *stash;
  swig_perl_wrap *wrap;
  SV *impl;
  swig_perl_type_ext *ext;
  MGVTBL *vtbl;

  if (!sv) sv = newSV(0);

  if (!ptr) {
    SvSetSV(sv, &PL_sv_undef);
    return sv;
  }
  if (!proto)
    proto = sv_2mortal(newSVpv(SWIG_Perl_TypeProxyName(t), 0));

  stash = gv_stashpv(SWIG_Perl_TypeProxyName(t), GV_ADD);

  if ((impl = SWIG_Perl_LookupPtr(stash, ptr))) {
    SvSetSV(sv, impl);
    return sv;
  }
  ext = (swig_perl_type_ext *)t->clientdata;

  /*Newx(wrap, 1, swig_perl_wrap);*/
  wrap = (swig_perl_wrap *)malloc(sizeof(swig_perl_wrap));
  wrap->stash = stash;
  wrap->ptr = ptr;
  wrap->refcnt = 1;

  if(flags & SWIG_SHADOW && ext) {
    /* pointer_reference.i for sample of shadow set without ext */

    /* So many object models out there...
     * Class::Accessor?  Class::Struct?  Class::Std?  Class::Closure?
     * There certainly is more than one way to do it!
     *
     * But those are all CPAN modules, when we look at core perl we
     * find just the "fields" pragma.  Pros: compile time checks for
     * attribute validity when objects are typed; unsurprising
     * inheritance mechanism for end users.  Cons: constructor has no
     * XS api yet, implementation switch from avhv to hv in v5.9.0.
     * The good points are compelling for SWIG users, the bad points
     * complicate this wrapper, but it's managable. */
    dSP;
    I32 count;

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    XPUSHs(proto);
    PUTBACK;
    count = call_pv("fields::new", G_SCALAR);
    assert(count == 1);
    SPAGAIN;
    impl = POPs;
    PUTBACK;

    SvSetSV(sv, impl);

    FREETMPS;
    LEAVE;

    sv_2mortal(SvRV(sv));
    vtbl = &ext->vtbl;
    if(ext->attr) { /* populate object attribute stubs */
      int i;
      for(i = 0; i < ext->nattr; i++) {
        SV *k = sv_2mortal(newSVpv(ext->attr[i].name, 0));
        SV *v = SWIG_Perl_WrapVar(newSV(0), &ext->attr[i].vtbl, wrap);
#if PERL_REVISION > 5 || (PERL_REVISION == 5 && PERL_VERSION >= 9)
        /* obj is a hash */
        hv_store_ent((HV *)SvRV(sv), k, v, 0);
#else
        /* obj is a pseudo-hash */
        avhv_store_ent((AV *)SvRV(sv), k, v, 0);
#endif
      }
    }
  } else {
    SV *tmp = sv_newmortal();
    newSVrv(tmp, SWIG_Perl_TypeProxyName(t));
    SvSetSV(sv, tmp);
  }
  vtbl = &SWIG_Perl_default_vtbl;
  sv_magicext(SvRV(sv), 0, PERL_MAGIC_ext, vtbl, (char *)wrap, 0);
#if 0
      /*warn("WrapNative(0x%p, \"%s\")\n", ptr, SWIG_Perl_TypeProxyName(t));*/
      /* sv_dump(sv);
      do_sv_dump(0, Perl_debug_log, sv, 0, 4, 0, 0);
      warn("}");*/
#endif
  SWIG_Perl_RememberPtr(wrap, sv);
  return sv;
}

/* Function for getting a pointer value */

SWIGRUNTIME void
SWIG_Perl_MakePackedObj(SV *sv, void *ptr, int sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(SWIG_Perl_TypeProxyName(type))) > 1000) return;
  *(r++) = '_';
  r = SWIG_PackData(r,ptr,sz);
  strcpy(r,SWIG_Perl_TypeProxyName(type));
  sv_setpv(sv, result);
}

SWIGRUNTIME SV *
SWIG_Perl_NewPackedObj(void *ptr, int sz, swig_type_info *type) {
  SV *result = sv_newmortal();
  SWIG_Perl_MakePackedObj(result, ptr, sz, type);
  return result;
}

/* Convert a packed value value */
SWIGRUNTIME int
SWIG_Perl_ConvertPacked(SV *obj, void *ptr, int sz, swig_type_info *ty) {
  swig_cast_info *tc;
  const char  *c = 0;

  if ((!obj) || (!SvOK(obj))) return SWIG_ERROR;
  c = SvPV_nolen(obj);
  /* Pointer values must start with leading underscore */
  if (*c != '_') return SWIG_ERROR;
  c++;
  c = SWIG_UnpackData(c,ptr,sz);
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) return SWIG_ERROR;
  }
  return SWIG_OK;
}


/* Macros for low-level exception handling */
#define SWIG_croak(x)    { SWIG_Error(SWIG_RuntimeError, x); SWIG_fail; }


typedef XSPROTO(SwigPerlWrapper);
typedef SwigPerlWrapper *SwigPerlWrapperPtr;

/* Information for constant table */

#define SWIG_INT     1
#define SWIG_FLOAT   2
#define SWIG_STRING  3
#define SWIG_POINTER 4
#define SWIG_BINARY  5

/* Constant information structure */
typedef struct swig_constant_info {
    int              type;
    const char      *name;
    long             lvalue;
    double           dvalue;
    void            *pvalue;
    swig_type_info **ptype;
} swig_constant_info;


SWIGRUNTIME swig_module_info *
SWIG_Perl_GetModule(void) {
  static void *type_pointer = (void *)0;
  SV *pointer;

  /* first check if pointer already created */
  if (!type_pointer) {
    pointer = get_sv("swig_runtime_data::type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME, FALSE | GV_ADDMULTI);
    if (pointer && SvOK(pointer)) {
      type_pointer = INT2PTR(swig_type_info **, SvIV(pointer));
    }
  }

  return (swig_module_info *) type_pointer;
}

SWIGRUNTIME void
SWIG_Perl_SetModule(swig_module_info *module) {
  SV *pointer;

  /* create a new pointer */
  pointer = get_sv("swig_runtime_data::type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME, TRUE | GV_ADDMULTI);
  sv_setiv(pointer, PTR2IV(module));
}

XS(SWIG_Perl_This) {
  dXSARGS;
  SV *self;
  MAGIC *mg;

  if (items != 1)
    SWIG_croak("Usage: $obj->this();");
  self = ST(0);
  if (!SvROK(self))
    SWIG_croak("self not an object");
  mg = mg_find(SvRV(self), PERL_MAGIC_ext);
  if (!mg)
    SWIG_croak("self not magical");
  ST(0) = newSViv(PTR2IV(((swig_perl_wrap *)mg->mg_ptr)->ptr));
  XSRETURN(1);
fail:
  SWIG_croak_null();
}
XS(SWIG_Perl_Disown) {
  dXSARGS;
  SV *self;
  MAGIC *mg;

  if (items != 1)
    SWIG_croak("Usage: $obj->DISOWN()");
  self = ST(0);
  if (!SvROK(self))
    SWIG_croak("self not an object");
  mg = mg_find(SvRV(self), PERL_MAGIC_ext);
  if (!mg)
    SWIG_croak("self not magical");
  SWIG_Perl_ForgetPtr(((swig_perl_wrap *)mg->mg_ptr));
  XSRETURN(0);
fail:
  SWIG_croak_null();
}
XS(SWIG_Perl_Acquire) {
  dXSARGS;
  SV *self;
  MAGIC *mg;

  if (items != 1)
    SWIG_croak("Usage: $obj->ACQUIRE()");
  self = ST(0);
  if (!SvROK(self))
    SWIG_croak("self not an object");
  mg = mg_find(SvRV(self), PERL_MAGIC_ext);
  if (!mg)
    SWIG_croak("self not magical");
  SWIG_Perl_RememberPtr(((swig_perl_wrap *)mg->mg_ptr), self);
  XSRETURN(0);
fail:
  SWIG_croak_null();
}

#ifdef __cplusplus
}
#endif
