/* -----------------------------------------------------------------------------
 * perl5.swg
 *
 * Perl5 runtime library
 * $Header$
 * ----------------------------------------------------------------------------- */

#define SWIGPERL
#define SWIGPERL5
#ifdef __cplusplus
/* Needed on some windows machines---since MS plays funny
   games with the header files under C++ */
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
#define SWIG_CALLXS(_name) _name(cv,pPerl) 
#else 
#ifndef MULTIPLICITY 
#define SWIG_CALLXS(_name) _name(cv) 
#else 
#define SWIG_CALLXS(_name) _name(PERL_GET_THX, cv) 
#endif 
#endif 

/* Macros for low-level exception handling */
#define SWIG_fail      goto fail
#define SWIG_croak(x)  { if ((_swigerr = (const char *) x)) goto fail; }
#define SWIG_MAX_ERRMSG 256

/* Note: SwigMagicFuncHack is a typedef used to get the C++
   compiler to just shut up already */

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
#ifndef PL_sv_yes
#define PL_sv_yes sv_yes
#endif
#ifndef PL_sv_undef
#define PL_sv_undef sv_undef
#endif
#ifndef PL_na
#define PL_na na
#endif
#endif

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef SWIG_NOINCLUDE

#ifndef PERL_OBJECT
extern int SWIG_ConvertPtr(SV *, void **, swig_type_info *, int flags);
extern void SWIG_MakePtr(SV *, void *, swig_type_info *, int flags);
#else
extern int _SWIG_ConvertPtr(CPerlObj *, SV *, void **, swig_type_info *,int flags);
extern void _SWIG_MakePtr(CPerlObj *, SV *, void *, swig_type_info *, int flags);
#define SWIG_ConvertPtr(a,b,c,d) _SWIG_ConvertPtr(pPerl,a,b,c,d)
#define SWIG_MakePtr(a,b,c,d) _SWIG_MakePtr(pPerl,a,b,c,d)
#endif

#else

/* Function for getting a pointer value */

#ifndef PERL_OBJECT
SWIGRUNTIME(int) 
SWIG_ConvertPtr(SV *sv, void **ptr, swig_type_info *_t, int flags)
#else
#define SWIG_ConvertPtr(a,b,c,d) _SWIG_ConvertPtr(pPerl,a,b,c,d)
SWIGRUNTIME(int)
_SWIG_ConvertPtr(CPerlObj *pPerl, SV *sv, void **ptr, swig_type_info *_t, int flags)
#endif
{
  char *_c;
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
          SV *rsv = mg->mg_obj;
          if (sv_isobject(rsv)) {
            tmp = SvIV((SV*)SvRV(rsv));
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
    _c = HvNAME(SvSTASH(SvRV(sv)));
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
#ifndef PERL_OBJECT
SWIGRUNTIME(void) 
SWIG_MakePtr(SV *sv, void *ptr, swig_type_info *t,int flags)
#else
#define SWIG_MakePtr(a,b,c,d) _SWIG_MakePtr(pPerl,a,b,c,d)
SWIGRUNTIME(void)
_SWIG_MakePtr(CPerlObj *pPerl, SV *sv, void *ptr, swig_type_info *t, int flags)
#endif
{
  sv_setref_pv(sv, (char *) t->name, ptr);
}

#endif

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
       static void _swig_create_magic(SV *sv, char *name, int (*set)(SV *, MAGIC *), int \
(*get)(SV *,MAGIC *)) { 
  #else 
       static void _swig_create_magic(SV *sv, char *name, int (*set)(struct interpreter*,\
 SV *, MAGIC *), int (*get)(struct interpreter*, SV *,MAGIC *)) { 
  #endif 
#else
#define swig_create_magic(s,a,b,c) _swig_create_magic(pPerl,s,a,b,c)
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





