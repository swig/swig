/* -*- c -*-
 * -----------------------------------------------------------------------
 * swig_lib/guile/guile.swg
 *
 * Guile configuration file.
 * ----------------------------------------------------------------------- */

/* SWIG pointer structure */

struct SwigCast {
  unsigned short      type;		  /* Index into SwigPtrTbl          */
  void               *(*cast)(void *);    /* Pointer casting function       */
  struct SwigCast    *next;		  /* Linked list pointer            */
};

struct SwigPtrType {
  char               *name;               /* Datatype name                  */
  char		     *prettyname;         /* Pretty datatype name           */
  unsigned short      tag;		  /* Index in SwigPtrTable          */
  struct SwigCast    *cast;		  /* List of compatible types       */
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
SWIGSTATIC size_t
SWIG_RegisterType (char *type, char *prettyname)
{
  int i;

  /* Allocate the pointer table if necessary */
  if (!SwigPtrList) {
    SwigPtrList = (SwigPtrType *) malloc(SwigPtrMax*sizeof(SwigPtrType));
    SwigPtrTbl = (size_t *) malloc(SwigPtrMax*sizeof(size_t));
    SwigPtrN = 0;
  }
  /* Grow the table if necessary */
  if (SwigPtrN >= SwigPtrMax) {
    SwigPtrMax = 2*SwigPtrMax;
    SwigPtrList = (SwigPtrType *) realloc((char *) SwigPtrList,
					  SwigPtrMax*sizeof(SwigPtrType));
    SwigPtrTbl = (size_t *) realloc((char *) SwigPtrTbl,
				    SwigPtrMax*sizeof(size_t));
  }
  /* Look up type */
  for (i = 0; i < SwigPtrN; i++)
    if (strcmp(SwigPtrList[i].name,type) == 0) {
      if (prettyname!=NULL)
	SwigPtrList[i].prettyname = prettyname;
      return i;
    }
  {
    struct SwigPtrType *t;
    size_t tag;
#if 0
    fprintf(stderr, "New type: %s\n", type);
#endif
    tag = SwigPtrTbl[SwigPtrN] = SwigPtrN;
    t = &SwigPtrList[tag];
    t->name = type;
    t->prettyname = prettyname;
    t->tag = SwigPtrN;
    t->cast = NULL;
    SwigPtrN++;
    SwigPtrSort = 0; 
    return tag;
  }
}

/* Register two data types and their mapping with the type checker. */
SWIGSTATIC void
SWIG_RegisterMapping (char *origtype, char *newtype, void *(*cast)(void *))
{
  int i;
  size_t t = SWIG_RegisterType(origtype, NULL);

  if (newtype!=NULL) {
    size_t t1 = SWIG_RegisterType(newtype, NULL);
    struct SwigCast *c;
    /* Check for existing cast */
    for (c = SwigPtrList[t].cast; c && c->type!=t1; c=c->next) /* nothing */;
    if (c) {
      if (cast) c->cast = cast;
    }
    else {
      c = (struct SwigCast *) malloc(sizeof(struct SwigCast));
      c->type = t1;
      c->cast = cast;
      c->next = SwigPtrList[t].cast;
      SwigPtrList[t].cast = c;
    }
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

/* Cast a pointer if possible; returns 1 if successful */

static int
SWIG_Cast (void *source, size_t source_type,
	   void **ptr, size_t dest_type)
{
  if (dest_type != source_type) {
    /* We have a type mismatch.  Will have to look through our type
       mapping table to figure out whether or not we can accept this
       datatype.  */
    struct SwigCast *c;
    for (c = SwigPtrList[source_type].cast;
	 c && c->type!=dest_type; c = c->next) /* nothing */;
    if (c) {
      /* Get pointer value. */
      if (c->cast) *ptr = (*(c->cast))(source);
      else *ptr = source;
      return 1;
    }
    /* Didn't find any sort of match for this data.
       Get the pointer value and return false.  */
    *ptr = source;
    return 0;
  } else {
    /* Found a match on the first try.  Return pointer value.  */
    *ptr = source;
    return 1;
  }
}

/* Function for getting a pointer value */

static unsigned long swig_tag = 0;

SWIGSTATIC SCM
SWIG_Guile_MakePtr (void *ptr, _swig_type_info *type)
{
  if (ptr==NULL) return SCM_EOL;
  SCM_RETURN_NEWSMOB((((unsigned long)type->tag << 16) | swig_tag),
		     ptr);
}

/* Return 0 if successful. */
SWIGSTATIC int
SWIG_Guile_GetPtr(SCM s, void **result, _swig_type_info *type)
{
  if (SCM_NULLP(s)) {
    *result = NULL;
    return 0;
  }
  else if (SCM_NIMP(s)
	   && (unsigned long) SCM_TYP16(s) == swig_tag) {
    if (type) 
      return !SWIG_Cast((void *) SCM_CDR(s),
			SCM_CAR(s) >> 16,
			result, type->tag);
    else {
      *result = (void *) SCM_CDR(s);
      return 0;
    }
  }
  return 1;
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
    /* Register datatype itself and store pointer back */
    type->tag = SWIG_RegisterType(origname, type->str);
    /* Register compatible types */
    for (type++; type->name; type++)
      SWIG_RegisterMapping(origname, type->name, type->converter);
  }    
}

#ifdef __cplusplus
}
#endif

/* guile.swg ends here */
