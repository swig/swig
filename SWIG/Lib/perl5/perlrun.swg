/* ---------------------------------------------------------------------- -*- c -*-
 * perl5.swg
 *
 * Perl5 runtime library
 * $Header$
 * ----------------------------------------------------------------------------- */

#define SWIGPERL
#define SWIGPERL5
#ifdef __cplusplus
/* Needed on some windows machines---since MS plays funny games with the header files under C++ */
#include <math.h>
#include <stdlib.h>
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

/* Get rid of free and malloc defined by perl */
#undef free
#undef malloc

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

/* Contract support */

#define SWIG_contract_assert(expr,msg) if (!(expr)) { SWIG_croak(msg); } else

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
#define SWIGCLASS_STATIC static
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

/* Modifications for newer Perl 5.005 releases */

#if !defined(PERL_REVISION) || ((PERL_REVISION >= 5) && ((PERL_VERSION < 5) || ((PERL_VERSION == 5) && (PERL_SUBVERSION < 50))))
#  ifndef PL_sv_yes
#    define PL_sv_yes sv_yes
#  endif
#  ifndef PL_sv_undef
#    define PL_sv_undef sv_undef
#  endif
#  ifndef PL_na
#    define PL_na na
#  endif
#endif

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#define SWIG_OWNER 1
#define SWIG_SHADOW 2

/* Common SWIG API */

#ifdef PERL_OBJECT
#  define SWIG_ConvertPtr(obj, pp, type, flags) \
     SWIG_Perl_ConvertPtr(pPerl, obj, pp, type, flags)
#  define SWIG_NewPointerObj(p, type, flags) \
     SWIG_Perl_NewPointerObj(pPerl, p, type, flags)
#  define SWIG_MakePackedObj(sv, p, s, type)	\
     SWIG_Perl_MakePackedObj(pPerl, sv, p, s, type)
#  define SWIG_ConvertPacked(obj, p, s, type, flags) \
     SWIG_Perl_ConvertPacked(pPerl, obj, p, s, type, flags)

#else
#  define SWIG_ConvertPtr(obj, pp, type, flags) \
     SWIG_Perl_ConvertPtr(obj, pp, type, flags)
#  define SWIG_NewPointerObj(p, type, flags) \
     SWIG_Perl_NewPointerObj(p, type, flags)
#  define SWIG_MakePackedObj(sv, p, s, type)	\
     SWIG_Perl_MakePackedObj(sv, p, s, type )
#  define SWIG_ConvertPacked(obj, p, s, type, flags) \
     SWIG_Perl_ConvertPacked(obj, p, s, type, flags)
#endif

/* Perl-specific API */
#ifdef PERL_OBJECT
#  define SWIG_MakePtr(sv, ptr, type, flags) \
     SWIG_Perl_MakePtr(pPerl, sv, ptr, type, flags)
#  define SWIG_SetError(str) \
     SWIG_Perl_SetError(pPerl, str)
#else
#  define SWIG_MakePtr(sv, ptr, type, flags) \
     SWIG_Perl_MakePtr(sv, ptr, type, flags)
#  define SWIG_SetError(str) \
     SWIG_Perl_SetError(str)
#  define SWIG_SetErrorSV(str) \
     SWIG_Perl_SetErrorSV(str)
#endif

#define SWIG_SetErrorf SWIG_Perl_SetErrorf


#ifdef PERL_OBJECT
#  define SWIG_MAYBE_PERL_OBJECT CPerlObj *pPerl,
#else
#  define SWIG_MAYBE_PERL_OBJECT
#endif

/* load the swig_runtime_list_handle variable from the interpreter */
static void SWIG_Perl_LookupTypePointer() {
  SV *pointer;

  /* first check if pointer already created */
  pointer = get_sv("swig_runtime_data::type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME, FALSE);
  if (pointer && SvOK(pointer)) {
    swig_type_list_handle = INT2PTR(swig_type_info **, SvIV(pointer));
  } else {
    /* create a new pointer */
    pointer = get_sv("swig_runtime_data::type_pointer" SWIG_RUNTIME_VERSION SWIG_TYPE_TABLE_NAME, TRUE);
    sv_setiv(pointer, PTR2IV(swig_type_list_handle));
  }
}

static swig_type_info *
SWIG_Perl_TypeCheckRV(SWIG_MAYBE_PERL_OBJECT SV *rv, swig_type_info *ty) {
  swig_type_info *s;
  if (!ty) return 0;        /* Void pointer */
  s = ty->next;             /* First element always just a name */
  do {
    if (sv_derived_from(rv, (char *) s->name)) {
      if (s == ty->next) return s;
      /* Move s to the top of the linked list */
      s->prev->next = s->next;
      if (s->next) {
        s->next->prev = s->prev;
      }
      /* Insert s as second element in the list */
      s->next = ty->next;
      if (ty->next) ty->next->prev = s;
      ty->next = s;
      s->prev = ty;
      return s;
    }
    s = s->next;
  } while (s && (s != ty->next));
  return 0;
}

/* Function for getting a pointer value */

static int
SWIG_Perl_ConvertPtr(SWIG_MAYBE_PERL_OBJECT SV *sv, void **ptr, swig_type_info *_t, int flags) {
  swig_type_info *tc;
  void *voidptr = (void *)0;

  /* If magical, apply more magic */
  if (SvGMAGICAL(sv))
    mg_get(sv);

  /* Check to see if this is an object */
  if (sv_isobject(sv)) {
    SV *tsv = (SV*) SvRV(sv);
    IV tmp = 0;
    if ((SvTYPE(tsv) == SVt_PVHV)) {
      MAGIC *mg;
      if (SvMAGICAL(tsv)) {
        mg = mg_find(tsv,'P');
        if (mg) {
          sv = mg->mg_obj;
          if (sv_isobject(sv)) {
            tmp = SvIV((SV*)SvRV(sv));
          }
        }
      } else {
        return -1;
      }
    } else {
      tmp = SvIV((SV*)SvRV(sv));
    }
    voidptr = (void *)tmp;
    if (!_t) {
      *(ptr) = voidptr;
      return 0;
    }
  } else if (! SvOK(sv)) {            /* Check for undef */
    *(ptr) = (void *) 0;
    return 0;
  } else if (SvTYPE(sv) == SVt_RV) {  /* Check for NULL pointer */
    *(ptr) = (void *) 0;
    if (!SvROK(sv))
      return 0;
    else
      return -1;
  } else {                            /* Don't know what it is */
    *(ptr) = (void *) 0;
    return -1;
  }
  if (_t) {
    /* Now see if the types match */
    char *_c = HvNAME(SvSTASH(SvRV(sv)));
    tc = SWIG_TypeCheck(_c,_t);
    if (!tc) {
      *ptr = voidptr;
      return -1;
    }
    *ptr = SWIG_TypeCast(tc,voidptr);
    return 0;
  }
  *ptr = voidptr;
  return 0;
}

static void
SWIG_Perl_MakePtr(SWIG_MAYBE_PERL_OBJECT SV *sv, void *ptr, swig_type_info *t, int flags) {
  if (ptr && (flags & SWIG_SHADOW)) {
    SV *self;
    SV *obj=newSV(0);
    HV *hash=newHV();
    HV *stash;
    sv_setref_pv(obj, (char *) t->name, ptr);
    stash=SvSTASH(SvRV(obj));
    if (flags & SWIG_OWNER) {
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
    sv_setref_pv(sv, (char *) t->name, ptr);
  }
}

static SWIGINLINE SV *
SWIG_Perl_NewPointerObj(SWIG_MAYBE_PERL_OBJECT void *ptr, swig_type_info *t, int flags) {
  SV *result = sv_newmortal();
  SWIG_MakePtr(result, ptr, t, flags);
  return result;
}

static void
  SWIG_Perl_MakePackedObj(SWIG_MAYBE_PERL_OBJECT SV *sv, void *ptr, int sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if ((2*sz + 1 + strlen(type->name)) > 1000) return;
  *(r++) = '_';
  r = SWIG_PackData(r,ptr,sz);
  strcpy(r,type->name);
  sv_setpv(sv, result);
}

/* Convert a packed value value */
static int
SWIG_Perl_ConvertPacked(SWIG_MAYBE_PERL_OBJECT SV *obj, void *ptr, int sz, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  const char  *c = 0;

  if ((!obj) || (!SvOK(obj))) return -1;
  c = SvPV(obj, PL_na);
  /* Pointer values must start with leading underscore */
  if (*c != '_') return -1;
  c++;
  c = SWIG_UnpackData(c,ptr,sz);
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) return -1;
  }
  return 0;
}

static SWIGINLINE void
SWIG_Perl_SetError(SWIG_MAYBE_PERL_OBJECT const char *error) {
  if (error) sv_setpv(perl_get_sv("@", TRUE), error);
}

static SWIGINLINE void
SWIG_Perl_SetErrorSV(SWIG_MAYBE_PERL_OBJECT SV *error) {
  if (error) sv_setsv(perl_get_sv("@", TRUE), error);
}

static void
SWIG_Perl_SetErrorf(const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  sv_vsetpvfn(perl_get_sv("@", TRUE), fmt, strlen(fmt), &args, Null(SV**), 0, Null(bool*));
  va_end(args);
}

/* Macros for low-level exception handling */
#define SWIG_fail       goto fail
#define SWIG_croak(x)   { SWIG_SetError(x); goto fail; }
#define SWIG_croakSV(x) { SWIG_SetErrorSV(x); goto fail; }
/* most preprocessors do not support vararg macros :-( */
/* #define SWIG_croakf(x...) { SWIG_SetErrorf(x); goto fail; } */


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

#ifdef __cplusplus
}
#endif

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
     static void _swig_create_magic(SV *sv, char *name, int (*set)(SV *, MAGIC *), int (*get)(SV *,MAGIC *)) {
  #else
     static void _swig_create_magic(SV *sv, char *name, int (*set)(struct interpreter*, SV *, MAGIC *), int (*get)(struct interpreter*, SV *,MAGIC *)) {
  #endif
#else
#  define swig_create_magic(s,a,b,c) _swig_create_magic(pPerl,s,a,b,c)
static void _swig_create_magic(CPerlObj *pPerl, SV *sv, const char *name, int (CPerlObj::*set)(SV *, MAGIC *), int (CPerlObj::*get)(SV *, MAGIC *)) {
#endif
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





