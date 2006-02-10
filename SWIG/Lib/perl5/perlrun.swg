/***********************************************************************
 * perlrun.swg
 *
 *     This file contains the runtime support for Perl modules
 *     and includes code for managing global variables and pointer
 *     type checking.
 *
 ************************************************************************/
#ifdef PERL_OBJECT
#define SWIG_PERL_OBJECT_DECL CPerlObj *SWIGUNUSEDPARM(pPerl),
#define SWIG_PERL_OBJECT_CALL pPerl,
#else
#define SWIG_PERL_OBJECT_DECL
#define SWIG_PERL_OBJECT_CALL
#endif

/* Common SWIG API */

/* for raw pointers */
#define SWIG_ConvertPtr(obj, pp, type, flags)           SWIG_Perl_ConvertPtr(SWIG_PERL_OBJECT_CALL obj, pp, type, flags)
#define SWIG_NewPointerObj(p, type, flags)              SWIG_Perl_NewPointerObj(SWIG_PERL_OBJECT_CALL p, type, flags)

/* for raw packed data */
#define SWIG_ConvertPacked(obj, p, s, type)             SWIG_Perl_ConvertPacked(SWIG_PERL_OBJECT_CALL obj, p, s, type)
#define SWIG_NewPackedObj(p, s, type)	                SWIG_Perl_NewPackedObj(SWIG_PERL_OBJECT_CALL p, s, type)

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

#define SWIG_MakePtr(sv, ptr, type, flags)              SWIG_Perl_MakePtr(SWIG_PERL_OBJECT_CALL sv, ptr, type, flags)
#define SWIG_MakePackedObj(sv, p, s, type)	        SWIG_Perl_MakePackedObj(SWIG_PERL_OBJECT_CALL sv, p, s, type)
#define SWIG_SetError(str)                              SWIG_Error(SWIG_RuntimeError, str)


#define SWIG_PERL_DECL_ARGS_1(arg1)                     (SWIG_PERL_OBJECT_DECL arg1)
#define SWIG_PERL_CALL_ARGS_1(arg1)                     (SWIG_PERL_OBJECT_CALL arg1)
#define SWIG_PERL_DECL_ARGS_2(arg1, arg2)               (SWIG_PERL_OBJECT_DECL arg1, arg2)
#define SWIG_PERL_CALL_ARGS_2(arg1, arg2)               (SWIG_PERL_OBJECT_CALL arg1, arg2)

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

/* For backward compatibility only */
#define SWIG_POINTER_EXCEPTION  0

#ifdef __cplusplus
extern "C" {
#if 0
} /* cc-mode */
#endif
#endif

#define SWIG_OWNER   SWIG_POINTER_OWN
#define SWIG_SHADOW  SWIG_OWNER << 1

#define SWIG_MAYBE_PERL_OBJECT SWIG_PERL_OBJECT_DECL


#ifdef __cplusplus
/* Needed on some windows machines---since MS plays funny games with the header files under C++ */
#include <math.h>
#include <stdlib.h>
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifndef pTHX_
#define pTHX_
#endif   

#include <string.h>
#ifdef __cplusplus
}
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

/* Note: SwigMagicFuncHack is a typedef used to get the C++ compiler to just shut up already */

#ifdef PERL_OBJECT
#define MAGIC_PPERL  CPerlObj *pPerl = (CPerlObj *) this;
typedef int (CPerlObj::*SwigMagicFunc)(SV *, MAGIC *);

#ifdef __cplusplus
extern "C" {
#endif
typedef int (CPerlObj::*SwigMagicFuncHack)(SV *, MAGIC *);
#ifdef __cplusplus
}
#endif

#define SWIG_MAGIC(a,b) (SV *a, MAGIC *b)
#define SWIGCLASS_STATIC
#else
#define MAGIC_PPERL
#define SWIGCLASS_STATIC static SWIGUNUSED
#ifndef MULTIPLICITY
#define SWIG_MAGIC(a,b) (SV *a, MAGIC *b)
typedef int (*SwigMagicFunc)(SV *, MAGIC *);

#ifdef __cplusplus
extern "C" {
#endif
typedef int (*SwigMagicFuncHack)(SV *, MAGIC *);
#ifdef __cplusplus
}
#endif


#else
#define SWIG_MAGIC(a,b) (struct interpreter *interp, SV *a, MAGIC *b)
typedef int (*SwigMagicFunc)(struct interpreter *, SV *, MAGIC *);
#ifdef __cplusplus
extern "C" {
#endif
typedef int (*SwigMagicFuncHack)(struct interpreter *, SV *, MAGIC *);
#ifdef __cplusplus
}
#endif

#endif
#endif

#if defined(WIN32) && defined(PERL_OBJECT) && !defined(PerlIO_exportFILE)
#define PerlIO_exportFILE(fh,fl) (FILE*)(fh)
#endif


/* Add in functionality missing in older versions of Perl. Much of this is based on Devel-PPPort on cpan. */

#ifndef SvIOK_UV
# define SvIOK_UV(sv)       (SvIOK(sv) && (SvUVX(sv) == SvIVX(sv)))
#endif

#ifndef SvUOK
# define SvUOK(sv)           SvIOK_UV(sv)
#endif

#ifndef PL_markstack_ptr
#  define PL_markstack_ptr Perl_markstack_ptr
#endif

#if !defined(PERL_REVISION) || ((PERL_VERSION < 4) || ((PERL_VERSION == 4) && (PERL_SUBVERSION <= 5)))
#  define PL_sv_undef               sv_undef
#  define PL_na	                    na
#  define PL_errgv                  errgv
#  define PL_sv_no                  sv_no
#  define PL_sv_yes                 sv_yes
#endif

#ifndef IVSIZE
#  ifdef LONGSIZE
#    define IVSIZE LONGSIZE
#  else
#    define IVSIZE 4 /* A bold guess, but the best we can make. */
#  endif
#endif

#ifndef INT2PTR
#  if (IVSIZE == PTRSIZE) && (UVSIZE == PTRSIZE)
#    define PTRV                  UV
#    define INT2PTR(any,d)        (any)(d)
#  else
#    if PTRSIZE == LONGSIZE
#      define PTRV                unsigned long
#    else
#      define PTRV                unsigned
#    endif
#    define INT2PTR(any,d)        (any)(PTRV)(d)
#  endif

#  define NUM2PTR(any,d)  (any)(PTRV)(d)
#  define PTR2IV(p)       INT2PTR(IV,p)
#  define PTR2UV(p)       INT2PTR(UV,p)
#  define PTR2NV(p)       NUM2PTR(NV,p)

#  if PTRSIZE == LONGSIZE
#    define PTR2ul(p)     (unsigned long)(p)
#  else
#    define PTR2ul(p)     INT2PTR(unsigned long,p)
#  endif
#endif /* !INT2PTR */

#ifndef get_sv
#  define get_sv perl_get_sv
#endif


#include <stdlib.h>

SWIGRUNTIME const char *
SWIG_Perl_TypeProxyName(const swig_type_info *type) {
  if (!type) return NULL;
  if (type->clientdata != NULL) {
    return (const char*) type->clientdata;
  } 
  else {
    return type->name;
  }
}

SWIGRUNTIME swig_cast_info *
SWIG_TypeProxyCheck(const char *c, swig_type_info *ty) {
  SWIG_TypeCheck_Template(( (!iter->type->clientdata && (strcmp((char*)iter->type->name, c) == 0)) 
			    || (iter->type->clientdata && (strcmp((char*)iter->type->clientdata, c) == 0))), ty);
}


/* Function for getting a pointer value */

SWIGRUNTIME int
SWIG_Perl_ConvertPtr(SWIG_MAYBE_PERL_OBJECT SV *sv, void **ptr, swig_type_info *_t, int flags) {
  swig_cast_info *tc;
  void *voidptr = (void *)0;
  SV *tsv = 0;
  /* If magical, apply more magic */
  if (SvGMAGICAL(sv))
    mg_get(sv);

  /* Check to see if this is an object */
  if (sv_isobject(sv)) {
    IV tmp = 0;
    tsv = (SV*) SvRV(sv);
    if ((SvTYPE(tsv) == SVt_PVHV)) {
      MAGIC *mg;
      if (SvMAGICAL(tsv)) {
        mg = mg_find(tsv,'P');
        if (mg) {
          sv = mg->mg_obj;
          if (sv_isobject(sv)) {
	    tsv = (SV*)SvRV(sv);
            tmp = SvIV(tsv);
          }
        }
      } else {
        return SWIG_ERROR;
      }
    } else {
      tmp = SvIV(tsv);
    }
    voidptr = INT2PTR(void *,tmp);
  } else if (! SvOK(sv)) {            /* Check for undef */
    *(ptr) = (void *) 0;
    return SWIG_OK;
  } else if (SvTYPE(sv) == SVt_RV) {  /* Check for NULL pointer */
    if (!SvROK(sv)) {
      *(ptr) = (void *) 0;
      return SWIG_OK;
    } else {
      return SWIG_ERROR;
    }
  } else {                            /* Don't know what it is */
    return SWIG_ERROR;
  }
  if (_t) {
    /* Now see if the types match */
    char *_c = HvNAME(SvSTASH(SvRV(sv)));
    tc = SWIG_TypeProxyCheck(_c,_t);
    if (!tc) {
      return SWIG_ERROR;
    }
    *ptr = SWIG_TypeCast(tc,voidptr);
  } else {
    *ptr = voidptr;
  }

  /* 
   *  DISOWN implementation: we need a perl guru to check this one.
   */
  if (tsv && (flags & SWIG_POINTER_DISOWN)) {
    /* 
     *  almost copy paste code from below SWIG_POINTER_OWN setting
     */
    SV *obj = sv;
    HV *stash = SvSTASH(SvRV(obj));
    GV *gv = *(GV**) hv_fetch(stash, "OWNER", 5, TRUE);
    if (isGV(gv)) {
      HV *hv = GvHVn(gv);
      /*
       * To set ownership (see below), a newSViv(1) entry is added. 
       * Hence, to remove ownership, we delete the entry.
       */
      if (hv_exists_ent(hv, obj, 0)) {
	hv_delete_ent(hv, obj, 0, 0);
      }
    }
  }
  return SWIG_OK;
}

SWIGRUNTIME void
SWIG_Perl_MakePtr(SWIG_MAYBE_PERL_OBJECT SV *sv, void *ptr, swig_type_info *t, int flags) {
  if (ptr && (flags & SWIG_SHADOW)) {
    SV *self;
    SV *obj=newSV(0);
    HV *hash=newHV();
    HV *stash;
    sv_setref_pv(obj, (char *) SWIG_Perl_TypeProxyName(t), ptr);
    stash=SvSTASH(SvRV(obj));
    if (flags & SWIG_POINTER_OWN) {
      HV *hv;
      GV *gv=*(GV**)hv_fetch(stash, "OWNER", 5, TRUE);
      if (!isGV(gv))
        gv_init(gv, stash, "OWNER", 5, FALSE);
      hv=GvHVn(gv);
      hv_store_ent(hv, obj, newSViv(1), 0);
    }
    sv_magic((SV *)hash, (SV *)obj, 'P', Nullch, 0);
    SvREFCNT_dec(obj);
    self=newRV_noinc((SV *)hash);
    sv_setsv(sv, self);
    SvREFCNT_dec((SV *)self);
    sv_bless(sv, stash);
  }
  else {
    sv_setref_pv(sv, (char *) SWIG_Perl_TypeProxyName(t), ptr);
  }
}

SWIGRUNTIMEINLINE SV *
SWIG_Perl_NewPointerObj(SWIG_MAYBE_PERL_OBJECT void *ptr, swig_type_info *t, int flags) {
  SV *result = sv_newmortal();
  SWIG_MakePtr(result, ptr, t, flags);
  return result;
}

SWIGRUNTIME void
SWIG_Perl_MakePackedObj(SWIG_MAYBE_PERL_OBJECT SV *sv, void *ptr, int sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(SWIG_Perl_TypeProxyName(type))) > 1000) return;
  *(r++) = '_';
  r = SWIG_PackData(r,ptr,sz);
  strcpy(r,SWIG_Perl_TypeProxyName(type));
  sv_setpv(sv, result);
}

SWIGRUNTIME SV *
SWIG_Perl_NewPackedObj(SWIG_MAYBE_PERL_OBJECT void *ptr, int sz, swig_type_info *type) {
  SV *result = sv_newmortal();
  SWIG_Perl_MakePackedObj(result, ptr, sz, type);
  return result;
}

/* Convert a packed value value */
SWIGRUNTIME int
SWIG_Perl_ConvertPacked(SWIG_MAYBE_PERL_OBJECT SV *obj, void *ptr, int sz, swig_type_info *ty) {
  swig_cast_info *tc;
  const char  *c = 0;

  if ((!obj) || (!SvOK(obj))) return SWIG_ERROR;
  c = SvPV(obj, PL_na);
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


typedef XS(SwigPerlWrapper);
typedef SwigPerlWrapper *SwigPerlWrapperPtr;

/* Structure for command table */
typedef struct {
  const char         *name;
  SwigPerlWrapperPtr  wrapper;
} swig_command_info;

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


/* Structure for variable table */
typedef struct {
  const char   *name;
  SwigMagicFunc   set;
  SwigMagicFunc   get;
  swig_type_info  **type;
} swig_variable_info;

/* Magic variable code */
#ifndef PERL_OBJECT
#define swig_create_magic(s,a,b,c) _swig_create_magic(s,a,b,c)
  #ifndef MULTIPLICITY
     SWIGRUNTIME void _swig_create_magic(SV *sv, char *name, int (*set)(SV *, MAGIC *), int (*get)(SV *,MAGIC *)) 
  #else
     SWIGRUNTIME void _swig_create_magic(SV *sv, char *name, int (*set)(struct interpreter*, SV *, MAGIC *), int (*get)(struct interpreter*, SV *,MAGIC *)) 
  #endif
#else
#  define swig_create_magic(s,a,b,c) _swig_create_magic(pPerl,s,a,b,c)
SWIGRUNTIME void _swig_create_magic(CPerlObj *pPerl, SV *sv, const char *name, int (CPerlObj::*set)(SV *, MAGIC *), int (CPerlObj::*get)(SV *, MAGIC *)) 
#endif
{
  MAGIC *mg;
  sv_magic(sv,sv,'U',(char *) name,strlen(name));
  mg = mg_find(sv,'U');
  mg->mg_virtual = (MGVTBL *) malloc(sizeof(MGVTBL));
  mg->mg_virtual->svt_get = (SwigMagicFuncHack) get;
  mg->mg_virtual->svt_set = (SwigMagicFuncHack) set;
  mg->mg_virtual->svt_len = 0;
  mg->mg_virtual->svt_clear = 0;
  mg->mg_virtual->svt_free = 0;
}


SWIGRUNTIME swig_module_info *
SWIG_Perl_GetModule(void) {
  static void *type_pointer = (void *)0;
  SV *pointer;

  /* first check if pointer already created */
  if (!type_pointer) {
    pointer = get_sv("swig_runtime_data::type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME, FALSE);
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
  pointer = get_sv("swig_runtime_data::type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME, TRUE);
  sv_setiv(pointer, PTR2IV(module));
}

#ifdef __cplusplus
#if 0
{ /* cc-mode */
#endif
}
#endif
