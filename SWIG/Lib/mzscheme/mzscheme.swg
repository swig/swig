/* -*-c-*- */

/* SWIG pointer structure */

#ifdef __cplusplus
extern "C" {
#endif

struct SwigCast {
  struct SwigPtrType *type;		  /* Type in SwigPtrTbl             */
  void               *(*cast)(void *);    /* Pointer casting function       */
  struct SwigCast    *next;		  /* Linked list pointer            */
};

struct SwigPtrType {
  const char         *name;               /* Datatype name                  */
  const char	     *prettyname;         /* Pretty datatype name           */
  struct SwigCast    *cast;		  /* List of compatible types       */
};

struct swig_proxy {
    Scheme_Type type;
    SwigPtrType *ptrtype;
    void *object;
};

/* Pointer table */
static SwigPtrType **SwigPtrTbl = 0;    /* Sorted table */
static int SwigPtrMax  = 64;            /* Max entries that can be held */
                                        /* (may be adjusted dynamically) */
static int SwigPtrN    = 0;             /* Current number of entries */
static int SwigPtrSort = 0;             /* Status flag indicating sort */

/* Sort comparison function */
static int
swigsort (const void *data1, const void *data2)
{
  SwigPtrType *type1 = * (SwigPtrType **) data1;
  SwigPtrType *type2 = * (SwigPtrType **) data2;
  return strcmp(type1->name, type2->name);
}

/* Register a new datatype with the type-checker */
SWIGSTATIC SwigPtrType *
SWIG_RegisterType (const char *type, const char *prettyname)
{
  int i;
  struct SwigPtrType **t;

  /* Allocate the pointer table if necessary */
  if (!SwigPtrTbl) {
    SwigPtrTbl = (SwigPtrType **) malloc(SwigPtrMax*sizeof(SwigPtrType *));
    SwigPtrN = 0;
  }
  /* Grow the table if necessary */
  if (SwigPtrN >= SwigPtrMax) {
    SwigPtrMax = 2*SwigPtrMax;
    SwigPtrTbl = (SwigPtrType **) realloc((char *) SwigPtrTbl,
					  SwigPtrMax*sizeof(SwigPtrType *));
  }
  /* Look up type */
  for (i = 0; i < SwigPtrN; i++)
    if (strcmp(SwigPtrTbl[i]->name,type) == 0) {
      if (prettyname!=NULL)
	SwigPtrTbl[i]->prettyname = prettyname;
      return SwigPtrTbl[i];
    }
  t = SwigPtrTbl + SwigPtrN;
  *t = (SwigPtrType *) malloc(sizeof(SwigPtrType));
  (*t)->name = type;
  (*t)->prettyname = prettyname;
  (*t)->cast = NULL;
  SwigPtrN++;
  SwigPtrSort = 0; 
  return *t;
}

/* Register two data types and their mapping with the type checker. */
SWIGSTATIC void
SWIG_RegisterMapping (const char *origtype, const char *newtype, void *(*cast)(void *))
{
  struct SwigPtrType *t = SWIG_RegisterType(origtype, NULL);

  if (newtype!=NULL) {
    struct SwigPtrType *t1 = SWIG_RegisterType(newtype, NULL);
    struct SwigCast *c;
    /* Check for existing cast */
    for (c = t->cast; c && c->type!=t1; c=c->next) /* nothing */;
    if (c) {
      if (cast) c->cast = cast;
    }
    else {
      c = (struct SwigCast *) malloc(sizeof(struct SwigCast));
      c->type = t1;
      c->cast = cast;
      c->next = t->cast;
      t->cast = c;
    }
  }
}

/* Sort table */

static void
SWIG_SortTable (void)
{
  qsort ((void *) SwigPtrTbl, SwigPtrN, sizeof(struct SwigPtrTbl *), swigsort);
  /* Indicate that everything is sorted */
  SwigPtrSort = 1;
}

/* Look up pointer-type entry in table */

static int
swigcmp (const void *key, const void *data)
{
  char *k = (char *) key;
  SwigPtrType *t = *(SwigPtrType **) data;
  return strcmp(k, t->name);
}

static SwigPtrType *
SWIG_GetPtrType (const char *_t)
{
  SwigPtrType **result;
  if (!SwigPtrSort) SWIG_SortTable();
  result = (SwigPtrType **) bsearch(_t, SwigPtrTbl, SwigPtrN,
				    sizeof(SwigPtrType *), swigcmp);
  if (result!=NULL) return *result;
  else return NULL;
}

/* Cast a pointer if possible; returns 1 if successful */

static int
SWIG_Cast (void *source, SwigPtrType *source_type,
	   void **ptr, SwigPtrType *dest_type)
{
  if (dest_type != source_type) {
    /* We have a type mismatch.  Will have to look through our type
       mapping table to figure out whether or not we can accept this
       datatype.  */
    struct SwigCast *c;
    for (c = dest_type->cast;
	 c && c->type!=source_type; c = c->next) /* nothing */;
    if (c) {
      /* Get pointer value. */
      if (c->cast) *ptr = (*(c->cast))(source);
      else *ptr = source;
      return -1;
    }
    /* Didn't find any sort of match for this data.
       Get the pointer value and return false.  */
    *ptr = source;
    return 0;
  } else {
    /* Found a match on the first try.  Return pointer value.  */
    *ptr = source;
    return -1;
  }
}

/* Function for getting a pointer value */

static Scheme_Type swig_type;
int swig_initialized_p = 0;

SWIGSTATIC Scheme_Object *
SWIG_MakePtr(void *c_pointer, swig_type_info *type) {
    struct swig_proxy *new_proxy;
    new_proxy = (struct swig_proxy *) scheme_malloc(sizeof(struct swig_proxy));
    new_proxy->type = swig_type;
    new_proxy->ptrtype = type->ptrtype;
    new_proxy->object = (void *) c_pointer;
    return (Scheme_Object *) new_proxy;
}

/* Return 0 if successful. */
SWIGSTATIC int
SWIG_GetPtr(Scheme_Object *s, void **result, swig_type_info *type)
{
  if (SCHEME_NULLP(s)) {
    *result = NULL;
    return 0;
  }
  else if (SCHEME_TYPE(s) == swig_type) {
    struct swig_proxy *proxy = (struct swig_proxy *) s;
    if (type) {
      return !SWIG_Cast(proxy->object, proxy->ptrtype,
			result, type->ptrtype);
    }
    else {
      *result = proxy->object;
      return 0;
    }
  }
  return -1;
}

SWIGSTATIC void *
SWIG_MustGetPtr_ (Scheme_Object *s,  swig_type_info *type,
		  int argnum, const char *func_name,
		  int argc, Scheme_Object **argv)
{
  void *result;
  if (SWIG_GetPtr(s, &result, type) != 0) {
    /* type mismatch */
    scheme_wrong_type(func_name, type->str ? type->str : "void *", argnum, argc, argv);
  }
  return result;
}

SWIGSTATIC
void SWIG_RegisterTypes(swig_type_info **table,
			swig_type_info **init)
{
  if (!swig_initialized_p) {
    swig_type = scheme_make_type((char *) "swig");
    swig_initialized_p = 1;
  }
  for (; *init; table++, init++) {
    swig_type_info *type = *table = *init;
    const char *origname = type->name;
    /* Register datatype itself and store pointer back */
    type->ptrtype = SWIG_RegisterType(origname, type->str);
    /* Register compatible types */
    for (type++; type->name; type++)
      SWIG_RegisterMapping(origname, type->name, type->converter);
  }    
}


/* Dynamic pointer casting. Down an inheritance hierarchy */
SWIGSTATIC swig_type_info * 
SWIG_TypeDynamicCast(swig_type_info *ty, void **ptr) 
{
  swig_type_info *lastty = ty;
  if (!ty || !ty->dcast) return ty;
  while (ty && (ty->dcast)) {
     ty = (*ty->dcast)(ptr);
     if (ty) lastty = ty;
  }
  return lastty;
}

static Scheme_Object *
swig_package_values(int num, Scheme_Object **values)
{
    /* ignore first value if void */
    if (num > 0 && SCHEME_VOIDP(values[0]))
	num--, values++;
    if (num == 0) return scheme_void;
    else if (num == 1) return values[0];
    else return scheme_values(num, values);
}

static void *
swig_malloc(size_t size, const char *func_name)
{
  void *p = malloc(size);
  if (p == NULL) {
    scheme_signal_error("swig-memory-error");
  }
  else return p;
}

#ifdef __cplusplus
}
#endif

