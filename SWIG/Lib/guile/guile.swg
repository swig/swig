/* -*- c -*-
 * -----------------------------------------------------------------------
 * swig_lib/guile/guile.swg
 *
 * Guile configuration file.
 * ----------------------------------------------------------------------- */

/* SWIG pointer structure */

struct SwigPtrType {
  char               *name;               /* Datatype name                  */
  char		     *prettyname;         /* Pretty datatype name           */
  int                 len;                /* Length (used for optimization) */
  void               *(*cast)(void *);    /* Pointer casting function       */
  unsigned short      tag;		  /* Index in SwigPtrTable          */
  struct SwigPtrType *next;               /* Linked list pointer            */
};

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
static SwigPtrType *SwigPtrList = 0;    /* Table containing types and
					   equivalences; items will only be appended */
static SwigPtrType **SwigPtrTbl = 0;    /* Sorted indirect table; items will
					   be inserted */

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

  if (!SwigPtrList) {
    SwigPtrList = (SwigPtrType *) malloc(SwigPtrMax*sizeof(SwigPtrType));
    SwigPtrTbl = (SwigPtrType **) malloc(SwigPtrMax*sizeof(SwigPtrType *));
    SwigPtrN = 0;
  }
  /* Grow the table */
  if (SwigPtrN >= SwigPtrMax) {
    SwigPtrMax = 2*SwigPtrMax;
    SwigPtrList = (SwigPtrType *) realloc((char *) SwigPtrList,
					  SwigPtrMax*sizeof(SwigPtrType));
    SwigPtrTbl = (SwigPtrType **) realloc((char *) SwigPtrList,
					  SwigPtrMax*sizeof(SwigPtrType *));
  }
  for (i = 0; i < SwigPtrN; i++)
    if (strcmp(SwigPtrList[i].name,origtype) == 0) {
      t = &SwigPtrList[i];
      break;
    }
  if (!t) {
#if 0
    fprintf(stderr, "New type: %s\n", origtype);
#endif
    t = SwigPtrTbl[SwigPtrN] = &SwigPtrList[SwigPtrN];
    t->name = origtype;
    t->prettyname = NULL;
    t->len = strlen(t->name);
    t->cast = 0;
    t->next = 0;
    t->tag = SwigPtrN;
    SwigPtrN++;
    SwigPtrSort = 0;
  }

  if (newtype!=NULL) {
    /* Check for existing entry */

    while (t->next) {
      if ((strcmp(t->name,newtype) == 0)) {
	if (cast) t->cast = cast;
	return;
      }
      t = t->next;
    }

    /* FIXME: List of compatible types subject to change */
    /* Now place entry (in sorted order) */

    t1 = (SwigPtrType *) malloc(sizeof(SwigPtrType));
    t1->name = newtype;
    t1->prettyname = NULL;
    t1->len = strlen(t1->name);
    t1->cast = cast;
    t1->next = 0;
    t->next = t1;
  }
}

/* Make a pointer value string */

  /* OBSOLESCENT */
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

/* Sort table and make cache invalid */

static
void SWIG_SortTable()
{
  int i;
  qsort((void *) SwigPtrTbl, SwigPtrN, sizeof(SwigPtrType *), swigsort);
  for (i = 0; i < 256; i++) {
    SwigStart[i] = SwigPtrN;
  }
  for (i = SwigPtrN-1; i >= 0; i--) {
    SwigStart[(int) (SwigPtrTbl[i]->name[1])] = i;
  }
  for (i = 255; i >= 1; i--) {
    if (SwigStart[i-1] > SwigStart[i])
      SwigStart[i-1] = SwigStart[i];
  }
  /* Invalidate cache */
  for (i = 0; i < SWIG_CACHESIZE; i++)
    SwigCache[i].stat = 0;
  /* Indicate that everything is sorted */
  SwigPtrSort = 1;
}

/* Look up pointer-type entry in table */

static
SwigPtrType *SWIG_GetPtrType(char *_t)
{
  int  start, end;
  SwigPtrType **sp;
  if (!SwigPtrSort) SWIG_SortTable();
  start = SwigStart[(int) _t[1]];
  end = SwigStart[(int) _t[1]+1];
  sp = &SwigPtrTbl[start];
  /* This can be improved by using binary search instead of linear search. */
  while (start < end) {
    if (swigcmp(_t,sp) == 0) return *sp;
    sp++;
    start++;
  }
  return NULL;
}

/* Cast a pointer if possible */

static
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

/* OBSOLESCENT */
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

static unsigned long swig_tag = 0;

SWIGSTATIC
SCM SWIG_Guile_MakePtr(void *ptr, SwigPtrType *type)
{
  if (ptr==NULL) return SCM_EOL;
  SCM_RETURN_NEWSMOB((((unsigned long)type->tag << 16) | swig_tag),
		     ptr);
}

/* TRANSITIONAL */
SWIGSTATIC
SCM SWIG_Guile_MakePtr_Str(void *ptr, char *typestring, char *prettytypestring)
{
  SwigPtrType *type = SWIG_GetPtrType(typestring);
  if (type == NULL) {
    SWIG_RegisterMapping(typestring, NULL, NULL);
    type = SWIG_GetPtrType(typestring);
    if (type == NULL) {
      fprintf(stderr, "SWIG_Guile_MakePtr_Str: bailing out\n");
      abort();
    }
  }
  if (type->prettyname == NULL) type->prettyname = prettytypestring;
  return SWIG_Guile_MakePtr(ptr, type);
}

/* TRANSITIONAL */
SWIGSTATIC
int SWIG_Guile_GetPtr_Str(SCM s, void **result, char *typestring)
{
  if (SCM_NULLP(s)) {
    *result = NULL;
    return 0;
  }
  else if (SCM_NIMP(s)
	   && (unsigned long) SCM_TYP16(s) == swig_tag) {
    if (SWIG_Cast_Str((void *) SCM_CDR(s),
		      SwigPtrList[SCM_CAR(s) >> 16].name,
		      result, typestring) == NULL)
      return 0;
  }
  return 1;
}

/* Return 0 if successful. */
SWIGSTATIC
int SWIG_Guile_GetPtr(SCM s, void **result, SwigPtrType *type)
{
  return SWIG_Guile_GetPtr_Str(s, result, type->name);
}

/* Init */

static
int print_swig(SCM swig_smob, SCM port, scm_print_state *pstate)
{
  char buf[16];
  scm_puts("#<swig ", port);
  if (SwigPtrList[SCM_CAR(swig_smob) >> 16].prettyname != NULL)
    scm_puts(SwigPtrList[SCM_CAR(swig_smob) >> 16].prettyname, port);
  else scm_puts(SwigPtrList[SCM_CAR(swig_smob) >> 16].name, port);
  sprintf(buf, " 0x%lx>", SCM_CDR(swig_smob));
  scm_puts(buf, port);
  /* non-zero means success */
  return 1;
}

static
SCM equalp_swig(SCM A, SCM B)
{
  if (SCM_CAR(A) == SCM_CAR(B)
      && SCM_CDR(A) == SCM_CDR(B))
    return SCM_BOOL_T;
  else return SCM_BOOL_F;
}

SWIGSTATIC
void SWIG_Guile_Init()
{
  if (swig_tag == 0) {
    swig_tag = scm_make_smob_type_mfpe("swig", 0, NULL, NULL,
				       print_swig, equalp_swig);
  }
}

#ifdef __cplusplus
}
#endif

/* guile.swg ends here */
