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
  void               *(*cast)(void *);    /* Pointer casting function       */
  unsigned short      tag;		  /* Index in SwigPtrTable          */
  struct SwigPtrType *next;               /* Linked list pointer            */
};

/* Some variables  */

static int SwigPtrMax  = 64;            /* Max entries that can be held */
                                        /* (may be adjusted dynamically) */
static int SwigPtrN    = 0;             /* Current number of entries */
static int SwigPtrSort = 0;             /* Status flag indicating sort */

/* Pointer table */
static SwigPtrType *SwigPtrList = 0;    /* Table containing types and
					   equivalences; items will only
                                           be appended */
static size_t *SwigPtrTbl = 0;          /* Sorted indirect table; items will
					   be inserted */

/* Sort comparison function */
static int
swigsort (const void *data1, const void *data2)
{
  size_t index1 = * (size_t *) data1;
  size_t index2 = * (size_t *) data2;
  return strcmp(SwigPtrList[index1].name, SwigPtrList[index2].name);
}

/* Register a new datatype with the type-checker */

SWIGSTATIC void
SWIG_RegisterMapping (char *origtype, char *newtype, void *(*cast)(void *))
{
  int i;
  SwigPtrType *t = 0,*t1;

  /* Allocate the pointer table if necessary */

  if (!SwigPtrList) {
    SwigPtrList = (SwigPtrType *) malloc(SwigPtrMax*sizeof(SwigPtrType));
    SwigPtrTbl = (size_t *) malloc(SwigPtrMax*sizeof(size_t));
    SwigPtrN = 0;
  }
  /* Grow the table */
  if (SwigPtrN >= SwigPtrMax) {
    SwigPtrMax = 2*SwigPtrMax;
    SwigPtrList = (SwigPtrType *) realloc((char *) SwigPtrList,
					  SwigPtrMax*sizeof(SwigPtrType));
    SwigPtrTbl = (size_t *) realloc((char *) SwigPtrTbl,
				    SwigPtrMax*sizeof(size_t));
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
    SwigPtrTbl[SwigPtrN] = SwigPtrN;
    t = &SwigPtrList[SwigPtrN];
    t->name = origtype;
    t->prettyname = NULL;
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
    t1->cast = cast;
    t1->next = 0;
    t->next = t1;
  }
}

/* Sort table */

static void
SWIG_SortTable (void)
{
  int i;
  qsort ((void *) SwigPtrTbl, SwigPtrN, sizeof(size_t), swigsort);
  /* Indicate that everything is sorted */
  SwigPtrSort = 1;
}

/* Look up pointer-type entry in table */

static int
swigcmp (const void *key, const void *data)
{
  char *k = (char *) key;
  size_t index = *(size_t *)data;
  return strcmp(k, SwigPtrList[index].name);
}

static SwigPtrType *
SWIG_GetPtrType (const char *_t)
{
  int  start, end;
  size_t *result;
  if (!SwigPtrSort) SWIG_SortTable();
  result = bsearch(_t, SwigPtrTbl, SwigPtrN, sizeof(size_t), swigcmp);
  if (result!=NULL) return SwigPtrList+*result;
  else return NULL;
}

/* Cast a pointer if possible */

static char *
SWIG_Cast_Str (void *source, char *source_type, void **ptr, char *_t)
{
  char temp_type[256];
  char *name;
  int  i, len;
  SwigPtrType *sp,*tp;
  int  start, end;
  if (_t) {
    if (strcmp(_t,source_type)) {
      if (!SwigPtrSort) SWIG_SortTable();

      /* We have a type mismatch.  Will have to look through our type
	 mapping table to figure out whether or not we can accept this
         datatype.  */

      sp = SWIG_GetPtrType(_t);
      if (sp!=NULL) {
	name = sp->name;
	tp = sp->next;
	/* Try to find entry for our given datatype.  */
	while(tp) {
	  if (strcmp(source_type, tp->name) == 0) {
	    /* Get pointer value.  */
	    *ptr = source;
	    if (tp->cast) *ptr = (*(tp->cast))(*ptr);
	    return (char *) 0;
	  }
	  tp = tp->next;
	}
      }
      /* Didn't find any sort of match for this data.
	 Get the pointer value and return the received type.  */
      *ptr = source;
      return source_type;
    } else {
      /* Found a match on the first try.  Return pointer value.  */
      *ptr = source;
      return (char *) 0;
    }
  } else {
    /* No type specified.  Good luck!  */
    *ptr = source;
    return (char *) 0;
  }
}

/* Function for getting a pointer value */

static unsigned long swig_tag = 0;

SWIGSTATIC SCM
SWIG_Guile_MakePtr (void *ptr, _swig_type_info *type)
{
  if (ptr==NULL) return SCM_EOL;
  SCM_RETURN_NEWSMOB((((unsigned long)type->ptrtype->tag << 16) | swig_tag),
		     ptr);
}

static int
SWIG_Guile_GetPtr_Str (SCM s, void **result, char *typestring)
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
SWIGSTATIC int
SWIG_Guile_GetPtr(SCM s, void **result, _swig_type_info *type)
{
  /* FIXME: Use native typechecking w/o string-compares */
  return SWIG_Guile_GetPtr_Str(s, result, type->name);
}

/* Init */

static int
print_swig (SCM swig_smob, SCM port, scm_print_state *pstate)
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

static SCM
equalp_swig (SCM A, SCM B)
{
  if (SCM_CAR(A) == SCM_CAR(B)
      && SCM_CDR(A) == SCM_CDR(B))
    return SCM_BOOL_T;
  else return SCM_BOOL_F;
}

SWIGSTATIC void
SWIG_Guile_Init (void)
{
  if (swig_tag == 0) {
    swig_tag = scm_make_smob_type_mfpe("swig", 0, NULL, NULL,
				       print_swig, equalp_swig);
  }
}

/* Convert datatype table */

SWIGSTATIC
void SWIG_Guile_RegisterTypes(_swig_type_info **table)
{
  for (; *table; table++) {
    _swig_type_info *type = *table;
    char *origname = type->name;
    /* Register datatype itself */
    SWIG_RegisterMapping(origname, 0, 0);
    /* Store pointer to actual type */
    type->ptrtype = SWIG_GetPtrType(origname);
    /* Register compatible types */
    for (type++; type->name; type++)
      SWIG_RegisterMapping(origname, type->name, type->converter);
  }    
}

#ifdef __cplusplus
}
#endif

/* guile.swg ends here */
