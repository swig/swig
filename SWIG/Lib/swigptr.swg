/*****************************************************************************
 * $Header$
 *
 * swigptr.swg
 *
 * This file contains supporting code for the SWIG run-time type checking
 * mechanism.  The following functions are available :
 *
 * SWIG_RegisterMapping(char *origtype, char *newtype, void *(*cast)(void *));
 *
 *      Registers a new type-mapping with the type-checker.  origtype is the
 *      original datatype and newtype is an equivalent type.  cast is optional
 *      pointer to a function to cast pointer values between types (this
 *      is typically used to cast pointers from derived classes to base classes in C++)
 *      
 * SWIG_MakePtr(char *buffer, void *ptr, char *typestring);
 *     
 *      Makes a pointer string from a pointer and typestring.  The result is returned
 *      in buffer which is assumed to hold enough space for the result.
 *
 * char * SWIG_GetPtr(char *buffer, void **ptr, char *type)
 *
 *      Gets a pointer value from a string.  If there is a type-mismatch, returns
 *      a character string to the received type.  On success, returns NULL.
 *
 *
 * You can remap these functions by making a file called "swigptr.swg" in
 * your the same directory as the interface file you are wrapping.
 *
 * These functions are normally declared static, but this file can be
 * can be used in a multi-module environment by redefining the symbol
 * SWIGSTATIC.
 *****************************************************************************/

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef SWIG_GLOBAL
#define SWIGSTATIC
#endif

#ifndef SWIGSTATIC
#define SWIGSTATIC static
#endif



/* SWIG pointer structure */

typedef struct SwigPtrType {
  char               *name;               /* Datatype name                  */
  int                 len;                /* Length (used for optimization) */
  void               *(*cast)(void *);    /* Pointer casting function       */
  unsigned short      tag;		  /* Index in SwigPtrTable          */
  struct SwigPtrType *next;               /* Linked list pointer            */
} SwigPtrType;

/* Pointer cache structure */

typedef struct {
  int                 stat;               /* Status (valid) bit             */
  SwigPtrType        *tp;                 /* Pointer to type structure      */
  char                name[256];          /* Given datatype name            */
  char                mapped[256];        /* Equivalent name                */
} SwigCacheType;

/* Some variables  */

static int SwigPtrMax  = 64;           /* Max entries that can be currently held */
                                       /* This value may be adjusted dynamically */
static int SwigPtrN    = 0;            /* Current number of entries              */
static int SwigPtrSort = 0;            /* Status flag indicating sort            */
static int SwigStart[256];             /* Starting positions of types            */

/* Pointer table */
static SwigPtrType **SwigPtrTable = 0;  /* Table containing pointer equivalences  */

/* Cached values */

#define SWIG_CACHESIZE  8
#define SWIG_CACHEMASK  0x7
static SwigCacheType SwigCache[SWIG_CACHESIZE];  
static int SwigCacheIndex = 0;
static int SwigLastCache = 0;

/* Sort comparison function */
static int swigsort(const void *data1, const void *data2) {
	SwigPtrType **d1 = (SwigPtrType **) data1;
	SwigPtrType **d2 = (SwigPtrType **) data2;
	return strcmp((*d1)->name, (*d2)->name);
}

/* Binary Search function */
static int swigcmp(const void *key, const void *data) {
  char *k = (char *) key;
  SwigPtrType **d = (SwigPtrType **) data;
  return strncmp(k,(*d)->name,(*d)->len);
}

/* Register a new datatype with the type-checker */

SWIGSTATIC 
void SWIG_RegisterMapping(char *origtype, char *newtype, void *(*cast)(void *)) {

  int i;
  SwigPtrType *t = 0,*t1;

  /* Allocate the pointer table if necessary */

  if (!SwigPtrTable) {     
    SwigPtrTable = (SwigPtrType **) malloc(SwigPtrMax*sizeof(SwigPtrType *));
    SwigPtrN = 0;
  }
  /* Grow the table */
  if (SwigPtrN >= SwigPtrMax) {
    SwigPtrMax = 2*SwigPtrMax;
    SwigPtrTable = (SwigPtrType **) realloc((char *) SwigPtrTable,
					    SwigPtrMax*sizeof(SwigPtrType *));
  }
  for (i = 0; i < SwigPtrN; i++)
    if (strcmp(SwigPtrTable[i]->name,origtype) == 0) {
      t = SwigPtrTable[i];
      break;
    }
  if (!t) {
    t = SwigPtrTable[SwigPtrN] = malloc(sizeof(SwigPtrType));
    t->name = origtype;
    t->len = strlen(t->name);
    t->cast = 0;
    t->next = 0;
    SwigPtrN++;
  }

  /* Check for existing entry */

  while (t->next) {
    if ((strcmp(t->name,newtype) == 0)) {
      if (cast) t->cast = cast;
      return;
    }
    t = t->next;
  }
  
  /* Now place entry (in sorted order) */

  t1 = (SwigPtrType *) malloc(sizeof(SwigPtrType));
  t1->name = newtype;
  t1->len = strlen(t1->name);
  t1->cast = cast;
  t1->next = 0;            
  t->next = t1;           
  SwigPtrSort = 0;
}

/* Make a pointer value string */

SWIGSTATIC 
void SWIG_MakePtr(char *_c, const void *_ptr, char *type) {
  static char _hex[16] =
  {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
   'a', 'b', 'c', 'd', 'e', 'f'};
  unsigned long _p, _s;
  char _result[20], *_r;    /* Note : a 64-bit hex number = 16 digits */
  _r = _result;
  _p = (unsigned long) _ptr;
  if (_p > 0) {
    while (_p > 0) {
      _s = _p & 0xf;
      *(_r++) = _hex[_s];
      _p = _p >> 4;
    }
    *_r = '_';
    while (_r >= _result)
      *(_c++) = *(_r--);
  } else {
    strcpy (_c, "NULL");
  }
  if (_ptr)
    strcpy (_c, type);
}

/* Define for backwards compatibility */

#define _swig_make_hex   SWIG_MakePtr 

/* Sort table and make cache invalid */

SWIGSTATIC
void SWIG_SortTable()
{
  int i;
  qsort((void *) SwigPtrTable, SwigPtrN, sizeof(SwigPtrType *), swigsort); 
  for (i = 0; i < 256; i++) {
    SwigStart[i] = SwigPtrN;
  }
  for (i = SwigPtrN-1; i >= 0; i--) {
    SwigStart[(int) (SwigPtrTable[i]->name[1])] = i;
  }
  for (i = 255; i >= 1; i--) {
    if (SwigStart[i-1] > SwigStart[i])
      SwigStart[i-1] = SwigStart[i];
  }
  /* Invalidate cache */
  for (i = 0; i < SWIG_CACHESIZE; i++)  
    SwigCache[i].stat = 0;
  /* Put tags */
  for (i = 0; i < SwigPtrN; i++)
    SwigPtrTable[i]->tag = i;
  /* Indicate that everything is sorted */
  SwigPtrSort = 1;
}

/* Look up pointer-type entry in table */
    
SWIGSTATIC
SwigPtrType *SWIG_GetPtrType(char *_t)
{
  int  start, end;
  SwigPtrType **sp;
  if (!SwigPtrSort) SWIG_SortTable();
  start = SwigStart[(int) _t[1]];
  end = SwigStart[(int) _t[1]+1];
  sp = &SwigPtrTable[start];
  /* This can be improved by using binary search instead of linear search. */
  while (start < end) {
    if (swigcmp(_t,sp) == 0) return *sp;
    sp++;
    start++;
  }
  return NULL;
}

/* Cast a pointer if possible */

SWIGSTATIC
char *SWIG_Cast_Str(void *source, char *source_type, void **ptr, char *_t)
{
  char temp_type[256];
  char *name;
  int  i, len;
  SwigPtrType *sp,*tp;
  SwigCacheType *cache;
  int  start, end;
  if (_t) {
    if (strcmp(_t,source_type)) { 
      if (!SwigPtrSort) SWIG_SortTable();
      /* First check cache for matches.  Uses last cache value as starting point */
      cache = &SwigCache[SwigLastCache];
      for (i = 0; i < SWIG_CACHESIZE; i++) {
	if (cache->stat) {
	  if (strcmp(_t,cache->name) == 0) {
	    if (strcmp(source_type,cache->mapped) == 0) {
	      cache->stat++;
	      *ptr = source;
	      if (cache->tp->cast) *ptr = (*(cache->tp->cast))(*ptr);
	      return (char *) 0;
	    }
	  }
	}
	SwigLastCache = (SwigLastCache+1) & SWIG_CACHEMASK;
	if (!SwigLastCache) cache = SwigCache;
	else cache++;
      }
      /* We have a type mismatch.  Will have to look through our type
	 mapping table to figure out whether or not we can accept this datatype */

      sp = SWIG_GetPtrType(_t);
      if (sp!=NULL) {
	name = sp->name;
	len = sp->len;
	tp = sp->next;
	/* Try to find entry for our given datatype */
	while(tp) {
	  /* I don't understand this code */
	  if (tp->len >= 255) {
	    return source_type;
	  }
	  strcpy(temp_type,tp->name);
	  strncat(temp_type,_t+len,255-tp->len);
	  if (strcmp(source_type,temp_type) == 0) {
		  
	    strcpy(SwigCache[SwigCacheIndex].mapped,source_type);
	    strcpy(SwigCache[SwigCacheIndex].name,_t);
	    SwigCache[SwigCacheIndex].stat = 1;
	    SwigCache[SwigCacheIndex].tp = tp;
	    SwigCacheIndex = SwigCacheIndex & SWIG_CACHEMASK;
		  
	    /* Get pointer value */
	    *ptr = source;
	    if (tp->cast) *ptr = (*(tp->cast))(*ptr);
	    return (char *) 0;
	  }
	  tp = tp->next;
	}
      }
      /* Didn't find any sort of match for this data.  
	 Get the pointer value and return the received type */
      *ptr = source;
      return source_type;
    } else {
      /* Found a match on the first try.  Return pointer value */
      *ptr = source;
      return (char *) 0;
    }
  } else {
    /* No type specified.  Good luck */
    *ptr = source;
    return (char *) 0;
  }
}

/* Function for getting a pointer value */
   
SWIGSTATIC 
char *SWIG_GetPtr(char *_c, void **ptr, char *_t)
{
  unsigned long _p;
  _p = 0;

  /* Pointer values must start with leading underscore */
  if (*_c == '_') {
      _c++;
      /* Extract hex value from pointer */
      while (*_c) {
	  if ((*_c >= '0') && (*_c <= '9'))
	    _p = (_p << 4) + (*_c - '0');
	  else if ((*_c >= 'a') && (*_c <= 'f'))
	    _p = (_p << 4) + ((*_c - 'a') + 10);
	  else
	    break;
	  _c++;
      }
      return SWIG_Cast_Str((void *)_p, _c, ptr, _t);
  } else {
    if (strcmp (_c, "NULL") == 0) {
	*ptr = (void *) 0;
	return (char *) 0;
    }
    *ptr = (void *) 0;	
    return _c;
  }
}

#ifdef SWIGGUILE

SWIGSTATIC int swig_tag;

SWIGSTATIC
SCM SWIG_Guile_MakePtr(void *ptr, SwigPtrType *type)
{
  SCM_RETURN_NEWSMOB((((unsigned long)type->tag << 16) | swig_tag),
		     ptr);
}

/* Return 0 if successful. */
SWIGSTATIC
int SWIG_Guile_GetPtr(SCM s, void **result, SwigPtrType *type)
{
  if (SCM_NIMP(s)
      && SCM_TYP16(s) == swig_tag) {
    if (SWIG_Cast_Str((void *) SCM_CDR(s),
		      SwigPtrTable[SCM_CAR(s) >> 16]->name,
		      result, type->name) == NULL) 
      return 0;
  }
  return 1;	
}

/* TRANSITIONAL */
SWIGSTATIC
SCM SWIG_Guile_MakePtr_Str(void *ptr, char *typestring)
{
  return SWIG_Guile_MakePtr(ptr, SWIG_GetPtrType(typestring));
}

SWIGSTATIC
int SWIG_Guile_GetPtr_Str(SCM s, void **result, char *typestring)
{
  if (SCM_NIMP(s)
      && SCM_TYP16(s) == swig_tag) {
    if (SWIG_Cast_Str((void *) SCM_CDR(s),
		      SwigPtrTable[SCM_CAR(s) >> 16]->name,
		      result, typestring) == NULL) 
      return 0;
  }
  return 1;	
}

#endif

/* Compatibility mode */

#define _swig_get_hex  SWIG_GetPtr

#ifdef __cplusplus
}
#endif
