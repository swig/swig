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

#include <string.h>
#ifdef __cplusplus
}
#endif

#ifdef PERL_OBJECT
#define MAGIC_PPERL  CPerlObj *pPerl = (CPerlObj *) this;
#define MAGIC_CAST   (int (CPerlObj::*)(SV *, MAGIC *))
#define SWIGCLASS_STATIC 
#else
#define MAGIC_PPERL
#define MAGIC_CAST
#define SWIGCLASS_STATIC static
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
extern int SWIG_ConvertPtr(SV *, void **, _swig_type_info *);
extern void SWIG_MakePtr(SV *, void *, _swig_type_info *);
#else
extern int _SWIG_ConvertPtr(CPerlObj *, SV *, void **, _swig_type_info *);
extern void _SWIG_MakePtr(CPerlObj *, SV *, void *, _swig_type_info *);
#define SWIG_ConvertPtr(a,b,c) _SWIG_ConvertPtr(pPerl,a,b,c)
#define SWIG_MakePtr(a,b,c) _SWIG_MakePtr(pPerl,a,b,c)
#endif

#endif

/* Function for getting a pointer value */

#ifndef PERL_OBJECT
SWIGSTATICRUNTIME(int) 
SWIG_ConvertPtr(SV *sv, void **ptr, _swig_type_info *_t)
#else
#define SWIG_ConvertPtr(a,b,c) _SWIG_GetConvert(pPerl,a,b,c)
SWIGSTATICRUNTIME(int)
_SWIG_ConvertPtr(CPerlObj *pPerl, SV *sv, void **ptr, _swig_type_info *_t)
#endif
{
  char *_c;
  _swig_type_info *tc;
  IV   tmp;

  /* If magical, apply more magic */
  if (SvGMAGICAL(sv))
    mg_get(sv);

  /* Check to see if this is an object */
  if (sv_isobject(sv)) {
    SV *tsv = (SV*) SvRV(sv);
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
    if (!_t) {
      *(ptr) = (void *) tmp;
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
      *ptr = (void *) tmp;
      return -1;
    }
    *ptr = SWIG_TypeCast(tc,(void *)tmp);
    return 0;
  }
  *ptr = (void *) tmp;
  return 0;
}
#ifndef PERL_OBJECT
SWIGSTATICRUNTIME(void) 
SWIG_MakePtr(SV *sv, void *ptr, _swig_type_info *t)
#else
#define SWIG_MakePtr(a,b,c) _SWIG_MakePtr(pPerl,a,b,c)
SWIGSTATICRUNTIME(int *)
_SWIG_MakePtr(CPerlObj *pPerl, SV *sv, void *ptr, _swig_type_info *t)
#endif
{
  sv_setref_pv(sv, t->name, ptr);
}

/* Magic variable code */
#ifndef PERL_OBJECT
#define swig_create_magic(s,a,b,c) _swig_create_magic(s,a,b,c)
static void _swig_create_magic(SV *sv, char *name, int (*set)(SV *, MAGIC *), int (*get)(SV *,MAGIC *)) {
#else
#define swig_create_magic(s,a,b,c) _swig_create_magic(pPerl,s,a,b,c)
static void _swig_create_magic(CPerlObj *pPerl, SV *sv, char *name, int (CPerlObj::*set)(SV *, MAGIC *), int (CPerlObj::*get)(SV *, MAGIC *)) {
#endif
  MAGIC *mg;
  sv_magic(sv,sv,'U',name,strlen(name));
  mg = mg_find(sv,'U');
  mg->mg_virtual = (MGVTBL *) malloc(sizeof(MGVTBL));
  mg->mg_virtual->svt_get = get;
  mg->mg_virtual->svt_set = set;
  mg->mg_virtual->svt_len = 0;
  mg->mg_virtual->svt_clear = 0;
  mg->mg_virtual->svt_free = 0;
}

#ifdef __cplusplus
}
#endif






