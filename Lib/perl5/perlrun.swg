/* -----------------------------------------------------------------------------
 * perlrun.swg
 *
 * This file contains the runtime support for Perl modules
 * and includes code for managing global variables and pointer
 * type checking.
 * ----------------------------------------------------------------------------- */

/* Common SWIG API */

/* for raw pointers */
#define SWIG_ConvertPtr(obj, pp, type, flags)           SWIG_Perl_ConvertPtrAndOwn(obj, pp, type, flags, 0)
#define SWIG_ConvertPtrAndOwn(obj, pp, type, fl, own)   SWIG_Perl_ConvertPtrAndOwn(obj, pp, type, fl, own)
#define SWIG_NewPointerObjP(ptr, t, flags)              SWIG_Perl_MakePtr(0, ptr, t, flags, arg1)
#define SWIG_NewPointerObj(ptr, t, flags)               SWIG_Perl_MakePtr(0, ptr, t, flags, 0)

/* for raw packed data */
#define SWIG_ConvertPacked(obj, p, s, type)             SWIG_Perl_ConvertPacked(obj, p, s, type)
#define SWIG_NewPackedObj(p, s, type)                   SWIG_Perl_NewPackedObj(p, s, type)

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

#define SWIG_GetModule(clientdata)                      SWIG_Perl_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer)             SWIG_Perl_SetModule(pointer)


/* Error manipulation */

#define SWIG_ErrorType(code)                            SWIG_Perl_ErrorType(code)               
#define SWIG_Error(code, msg)            		sv_setpvf(get_sv("@", GV_ADD), "%s %s", SWIG_ErrorType(code), msg)
#define SWIG_fail                        		goto fail						    

/* Perl-specific SWIG API */

#define SWIG_MakePtr(sv, ptr, type, flags)              SWIG_Perl_MakePtr(sv, ptr, type, flags, 0)
#define SWIG_MakePackedObj(sv, p, s, type)              SWIG_Perl_MakePackedObj(sv, p, s, type)
#define SWIG_SetError(str)                              SWIG_Error(SWIG_RuntimeError, str)


/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

/* Flags for pointer conversions */
/* #define SWIG_POINTER_DISOWN        0x1 */
/* #define SWIG_CAST_NEW_MEMORY       0x2 */
#define SWIG_POINTER_MG            0x4
#define SWIG_POINTER_WR            0x8
/* These Perl specific pointer conversion flags handle two alternate
 * types of native pointer recovery, _MG handles wrapped variables and
 * object attributes, and _WR handles destructors.
 * 
 * TODO: document the shadow object memory layout.
 */

/* Flags for new pointer objects */
/* #define SWIG_POINTER_OWN           0x1 */
#define SWIG_POINTER_CLASS         0x2

/* For backward compatibility only */
#define SWIG_POINTER_EXCEPTION  0

#ifdef __cplusplus
extern "C" {
#endif

#define SWIG_OWNER   SWIG_POINTER_OWN

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

#  ifdef PERL_OBJECT
#    define SWIG_croak_null() SWIG_Perl_croak_null(pPerl)
static void SWIG_Perl_croak_null(CPerlObj *pPerl)
#  else
static void SWIG_croak_null()
#  endif
{
  SV *err = get_sv("@", GV_ADD);
#  if (PERL_VERSION < 6)
  croak("%_", err);
#  else
  if (sv_isobject(err))
    croak(0);
  else
    croak("%s", SvPV_nolen(err));
#  endif
}


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

#define SWIG_PERL_RUNTIME_KEY "swig_runtime_data:" SWIG_RUNTIME_VERSION

typedef struct swig_perl_module_info {
  HV *wrap_cache;
  swig_module_info *module_info;
} swig_perl_module_info;

SWIGINTERN swig_perl_module_info *
SWIG_Perl_RuntimeData(void) {
  static swig_perl_module_info *ptr = 0;

  if (!ptr) {
    SV **ent = hv_fetch(PL_modglobal, SWIG_PERL_RUNTIME_KEY,
        strlen(SWIG_PERL_RUNTIME_KEY), FALSE);
    if (ent && SvOK(*ent))
      ptr = INT2PTR(swig_perl_module_info *, SvIV(*ent));
  }
  return ptr;
}

typedef struct swig_perl_type_ext_var {
  const char *name;
  MGVTBL vtbl;
} swig_perl_type_ext_var;

typedef struct swig_perl_wrap swig_perl_wrap;

typedef struct swig_perl_type_ext {
  const char *name;
  MGVTBL vtbl;
  void (*destroy)(swig_perl_wrap *);
  const int nattr;
  swig_perl_type_ext_var *attr;
} swig_perl_type_ext;

struct swig_perl_wrap {
  HV *stash;
  void *ptr;
  IV refcnt;
  int own;
  swig_type_info *ti;
};

SWIGINTERN void SWIG_Perl_sv_setref(SV *rv, SV *sv, HV *stash) {
  /* this is similar to SvSetSV(rv, sv_2mortal(newRV_inc(sv))) with
   * less heap churn. */
  if (SvROK(rv)) {
    sv_unref(rv);
  } else {
    SvUPGRADE(rv, SVt_RV);
  }
  SvOK_off(rv);
  SvRV_set(rv, sv);
  SvROK_on(rv);
  if (stash) sv_bless(rv, stash);
}

SWIGINTERN HV *SWIG_Perl_WrapTbl(HV *stash) {
  char *name;
  SV *sv;
  HV *wc;

  wc = SWIG_Perl_RuntimeData()->wrap_cache;
  name = HvNAME(stash);
  sv = *hv_fetch(wc, name, strlen(name), TRUE);
  if (!SvOK(sv)) SWIG_Perl_sv_setref(sv, (SV *)newHV(), 0);
  return (HV *)SvRV(sv);
}

SWIGINTERN SV *SWIG_Perl_LookupPtr(HV *stash, void *ptr) {
  SV *tmp = newSViv(PTR2IV(ptr));
  HE *ent = hv_fetch_ent(SWIG_Perl_WrapTbl(stash), tmp, 0, 0);
  /*warn("lookup(%s:%p) %s\n", HvNAME(stash), ptr, ent ? "hit" : "miss");*/
  SvREFCNT_dec(tmp);
  return ent ? HeVAL(ent) : 0;
}

SWIGINTERN void SWIG_Perl_RememberPtr(swig_perl_wrap *wrap, SV *impl) {
  SV *tmp = newSViv(PTR2IV(wrap->ptr));
  SV *ref = newSVsv(impl);
  sv_rvweaken(ref);
  /*warn("store (%s:%p) = %p\n", HvNAME(wrap->stash), wrap->ptr, SvRV(impl));*/
  hv_store_ent(SWIG_Perl_WrapTbl(wrap->stash), tmp, ref, 0);
  SvREFCNT_dec(tmp);
}

SWIGINTERN void SWIG_Perl_ForgetPtr(swig_perl_wrap *wrap) {
  SV *tmp = newSViv(PTR2IV(wrap->ptr));
  /*warn("delete(%s:%p:%d)\n", HvNAME(wrap->stash), wrap->ptr, wrap->refcnt);*/
  hv_delete_ent(SWIG_Perl_WrapTbl(wrap->stash), tmp, G_DISCARD, 0);
  SvREFCNT_dec(tmp);
  if (wrap->ti->clientdata && wrap->own & SWIG_POINTER_OWN) {
    /* not all types have ext */
    /* TODO: allprotected.i had a case where we have an ext but no
     * destructor recorded, that is probably a bug. */
    swig_perl_type_ext *ext = (swig_perl_type_ext *)wrap->ti->clientdata;
    if (ext->destroy) ext->destroy(wrap);
  }
}

SWIGINTERN int
SWIG_Perl_vtbl_svt_free(pTHX_ SV *sv, MAGIC *mg) {
  swig_perl_wrap *wrap = (swig_perl_wrap *)mg->mg_ptr;
  wrap->refcnt--;
  if (wrap->refcnt <= 0) {
    SWIG_Perl_ForgetPtr(wrap);
    /*warn("free(%p)\n", wrap);*/
    /*Safefree(wrap);*/
    free(wrap);
  }
  return 0;
}

SWIGINTERN MGVTBL
SWIG_Perl_default_vtbl = { 0, 0, 0, 0, SWIG_Perl_vtbl_svt_free };

#define SWIG_Perl_VTBL(getf, setf) \
  { getf, setf, 0, 0, SWIG_Perl_vtbl_svt_free }

#define SWIG_Perl_TypeExt(name, destructor, count, attrlist) \
  { name, SWIG_Perl_VTBL(0, 0), destructor, count, attrlist }

SWIGRUNTIME const char *
SWIG_Perl_TypeProxyName(const swig_type_info *type) {
  if (!type)
    return 0;
  else if (type->clientdata)
    return ((swig_perl_type_ext *)type->clientdata)->name;
  else
    return SWIG_TypeName(type);
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
/* calling SWIG_ConvertPtr with ptr == 0 is a request to check if such a
 * conversion is legitimate */
SWIGRUNTIME int
SWIG_Perl_ConvertPtrAndOwn(void *obj, void **ptr,
    swig_type_info *t, int flags, int *own) {
  SV *sv = 0;
  MAGIC *mg = 0;
  swig_perl_wrap *wrap = 0;
  swig_cast_info *tc = 0;

  switch (flags & (SWIG_POINTER_MG | SWIG_POINTER_WR)) {
    /* a typical pointer conversion is to extract a raw pointer out of
     * an SV that represents the pointer, but for certain kinds of
     * class/struct accesses (attributes and destructors) there are
     * smipler, quicker conversions. */
    default:
      return SWIG_ERROR;
    case 0: {
      sv = (SV *)obj;
      if (own)
        *own = 0;
      SvGETMAGIC(sv);
      if (!SvOK(sv)) {
        if (ptr) *ptr = (void *) 0;
        return SWIG_OK;
      }
      if (!SvROK(sv))
        return SWIG_ERROR;
      /* runtime type checks:
       * t == 0 means no typecheck restrictions (void* style)
       * TypeProxyCheck() succeeds on a c/c++ inheritance
       * sv_derived_from succeeds on Perl inheritance
       */
      if (t) {
        tc = SWIG_TypeProxyCheck(sv_reftype(SvRV(sv), 1), t);
        if (!tc && !sv_derived_from(sv, SWIG_Perl_TypeProxyName(t)))
          return SWIG_ERROR;
      } else {
        tc = 0;
      }
      mg = mg_find(SvRV(sv), PERL_MAGIC_ext);
      if (!mg) /* maybe an object, but not one of ours */
        return SWIG_ERROR;
      if (!ptr) /* just a type check request, okay to drop out now */
        return SWIG_OK;
      obj = mg;
    }
    case SWIG_POINTER_MG:
      obj = ((MAGIC *)obj)->mg_ptr;
    case SWIG_POINTER_WR: /* no conversion necessary */
      ;
  }
  wrap = (swig_perl_wrap *)obj;
  if (flags & SWIG_POINTER_DISOWN)
    wrap->own &= ~SWIG_POINTER_OWN;
  if (tc) {
    int newmemory = 0;
    *ptr = SWIG_TypeCast(tc, wrap->ptr, &newmemory);
    if (newmemory == SWIG_CAST_NEW_MEMORY) {
      assert(own); /* badly formed typemap which will lead to a memory leak - it must set and use own to delete *ptr */
      if (own)
        *own = *own | SWIG_CAST_NEW_MEMORY;
    }
  } else {
    *ptr = wrap->ptr;
  }
  return SWIG_OK;
}

SWIGINTERN SV *
SWIG_Perl_WrapVar(SV *sv, MGVTBL *vtbl, swig_perl_wrap *wrap) {
  if (wrap) wrap->refcnt++;
  sv_magicext(sv, 0, PERL_MAGIC_ext, vtbl, (char *)wrap, 0);
  return sv;
}

#if PERL_REVISION > 5 || (PERL_REVISION == 5 && PERL_VERSION >= 9)
#  define PERL_SWIG_PSEUDOHASH 0
#else
#  define PERL_SWIG_PSEUDOHASH 1
#endif

#if PERL_SWIG_PSEUDOHASH
#else /* PERL_SWIG_PSEUDOHASH */
SWIGINTERN void
SWIG_Perl_FindFields(HV *hv, SV *proto, swig_type_info *t) {
  /* this is a helper function for MakePtr, it is analagous to
   * fields::_accessible_keys() looking to populate the placeholders
   * into empty slots in the hash that is about to be locked. */
  IV i;
  SV *tmp;
  AV *isa;
  HV *fields;
  if (strEQ(SvPV_nolen(proto), SWIG_Perl_TypeProxyName(t))) return;
  tmp = newSVpvf("%s::FIELDS", SvPV_nolen(proto));
  fields = get_hv(SvPV_nolen(tmp), 0);
  if (fields) {
    hv_iterinit(fields);
    HE *he;
    while (he = hv_iternext(fields)) {
      hv_store_ent(hv, hv_iterkeysv(he), &PL_sv_placeholder, 0);
    }
  }
  sv_setpvf(tmp, "%s::ISA", SvPV_nolen(proto));
  isa = get_av(SvPV_nolen(tmp), 0);
  if (isa) for (i = 0; i < av_len(isa); i++)
    SWIG_Perl_FindFields(hv, *(av_fetch(isa, i, 0)), t);
  SvREFCNT_dec(tmp);
}
#endif /* PERL_SWIG_PSEUDOHASH */

SWIGINTERN SV *
SWIG_Perl_MakePtr(SV *sv, void *ptr, swig_type_info *t, int flags,
    SV *proto) {
  HV *stash;
  swig_perl_wrap *wrap;
  SV *impl;
  swig_perl_type_ext *ext;
  SV *tmp;

  if (!sv) sv = newSV(0);

  if (!ptr) {
    SvSetSV(sv, &PL_sv_undef);
    return sv;
  }

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
  wrap->own = flags;
  wrap->ti = t;

  if (ext) {
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
     * complicate this wrapper, but it's managable.
     */
    if (proto)
      proto = newSVsv(proto);
    else
      proto = newSVpv(SWIG_Perl_TypeProxyName(t), 0);
#if PERL_SWIG_PSEUDOHASH
    tmp = newSVpvf("%s::FIELDS", SvPV_nolen(proto));
    SWIG_Perl_sv_setref(sv, (SV *)newAV(), gv_stashsv(proto, GV_ADD));
    av_store((AV *)SvRV(sv), 0, newRV_inc((SV *)get_hv(SvPV_nolen(tmp), TRUE)));
    SvREFCNT_dec(tmp);
#else /* PERL_SWIG_PSEUDOHASH */ 
    /* this is compatible with the base.pm and fields.pm pragmas.
     * we end up having to assume some of the guts of fields::new() and
     * Hash::Util::lock_keys() to accomplish this without a call into
     * the interpreter.
     */
    SWIG_Perl_sv_setref(sv, (SV *)newHV(), gv_stashsv(proto, GV_ADD));
    SWIG_Perl_FindFields((HV *)SvRV(sv), proto, t);
#endif /* PERL_SWIG_PSEUDOHASH */ 
    /* populate wrap accessors for attributes coming from c++ */
    if (ext->attr) { /* populate object attribute stubs */
      int i;
      SV *k = newSV(0);
      for (i = 0; i < ext->nattr; i++) {
        sv_setpv(k, ext->attr[i].name);
        SV *v = SWIG_Perl_WrapVar(newSV(0), &ext->attr[i].vtbl, wrap);
#if PERL_SWIG_PSEUDOHASH
        avhv_store_ent((AV *)SvRV(sv), k, v, 0);
#else /* PERL_SWIG_PSEUDOHASH */ 
        hv_store_ent((HV *)SvRV(sv), k, v, 0);
#endif /* PERL_SWIG_PSEUDOHASH */
      }
      SvREFCNT_dec(k);
    }
#if !PERL_SWIG_PSEUDOHASH
    SvREADONLY_on(SvRV(sv));
#endif
    SvREFCNT_dec(proto);
  } else {
    SWIG_Perl_sv_setref(sv, newSV(0), stash);
  }
  sv_magicext(SvRV(sv), 0, PERL_MAGIC_ext, &SWIG_Perl_default_vtbl, (char *)wrap, 0);
#if 0
  warn("WrapNative(0x%p, \"%s\")\n", ptr, SWIG_Perl_TypeProxyName(t));
  do_sv_dump(0, Perl_debug_log, sv, 0, 4, 0, 0);
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
  SV *result = newSV(0);
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
SWIG_Perl_GetModule(void *SWIGUNUSEDPARM(clientdata)) {
  swig_perl_module_info *ptr = SWIG_Perl_RuntimeData();
  if (ptr) return ptr->module_info;
  return 0;
}

SWIGRUNTIME void
SWIG_Perl_SetModule(swig_module_info *module) {
  static swig_perl_module_info info;
 
  info.wrap_cache = newHV();
  info.module_info = module;
  hv_store(PL_modglobal, SWIG_PERL_RUNTIME_KEY,
      strlen(SWIG_PERL_RUNTIME_KEY), newSViv(PTR2IV(&info)), 0);
}

XS(SWIG_Perl_Own) {
  dXSARGS;
  SV *self;
  MAGIC *mg;
  swig_perl_wrap *wrap;

  if (items > 0) {
    self = ST(0);
    if (SvROK(self)) {
      mg = mg_find(SvRV(self), PERL_MAGIC_ext);
      if (mg) {
        wrap = (swig_perl_wrap *)mg->mg_ptr;
        switch(items) {
          case 2:
            if (SvTRUE(ST(1))) {
              wrap->own |= SWIG_POINTER_OWN;
            } else {
              wrap->own &= ~SWIG_POINTER_OWN;
            }
          case 1:
            ST(0) = wrap->own & SWIG_POINTER_OWN ? &PL_sv_yes : &PL_sv_no;
            XSRETURN(1);
        }
      }
    }
  }
  croak("Usage: $obj->_swig_own();");
}

XS(SWIG_Perl_This) {
  dXSARGS;
  SV *self;
  MAGIC *mg;

  if (items == 1) {
    self = ST(0);
    if (SvROK(self)) {
      mg = mg_find(SvRV(self), PERL_MAGIC_ext);
      if (mg) {
        ST(0) = newSViv(PTR2IV(((swig_perl_wrap *)mg->mg_ptr)->ptr));
        XSRETURN(1);
      }
    }
  }
  croak("Usage: $obj->_swig_this();");
}

#ifdef __cplusplus
}
#endif
