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
    void (*delete_fn)( value );
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
SWIG_Cast (void *source, void **ptr) {
    *ptr = source;
    return 0;
}

/* Function for getting a pointer value */

static int swig_type;

static void generic_delete_fn( value v ) {
    struct swig_proxy *new_proxy;

    new_proxy = (struct swig_proxy *)(&Field(v,1));
    if( new_proxy->delete_fn ) new_proxy->delete_fn( v );
}

static struct custom_operations makeptr_custom_ops = {
    "SWIG-Wrapped Object",
    generic_delete_fn,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default
};

static value _wrap_delete_void( value v ) {
    return Val_unit;
}

SWIGSTATIC value
SWIG_MakePtr(void *c_pointer, swig_type_info *type, 
	     void *delete_fn) {
    struct swig_proxy *new_proxy;
    CAMLlocal1(v);

    v = alloc_custom(&makeptr_custom_ops,sizeof(struct swig_proxy),0,1);
    new_proxy = (struct swig_proxy *)(&Field(v,1));
    new_proxy->delete_fn = (void (*)(value)) delete_fn;
    new_proxy->object = (void *) c_pointer;
    return v;
}

/* Return 0 if successful. */
SWIGSTATIC int
SWIG_GetPtr(value v, void **result, swig_type_info *type)
{
    struct swig_proxy *proxy = (struct swig_proxy *)(&Field(v,1));

    if (type) {
	return !SWIG_Cast(proxy->object, result);
    }
    else {
	*result = proxy->object;
	return 0;
    }
    return -1;
}

SWIGSTATIC void *
SWIG_MustGetPtr_ (value s, swig_type_info *type, int argnum)
{
    void *result;
    
    if (SWIG_GetPtr(s, &result, type) != 0) {
	/* type mismatch */
	failwith("Type mismatch");
    }

    return result;
}

static value
swig_package_values(int num, value tuple)
{
    if (num == 0) return Val_unit;
    else if (num == 1) return Field(tuple,0);
    else return tuple;
}

static void *
swig_malloc(size_t size, const char *func_name)
{
    void *p;
    CAMLlocal1(v);

    v = alloc_string(size);
    p = String_val(v);

    if (p == NULL) {
	failwith("swig-memory-error");
    }
    else return p;
}

#ifdef __cplusplus
}
#endif

