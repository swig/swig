/***********************************************************************
 * chickenrun.swg
 *
 *     This file contains the runtime support for CHICKEN modules
 *     and includes code for managing global variables and pointer
 *     type checking.
 *
 * Author : Jonah Beckford
 * Derived from - file   : pyrun.swg
 * Derived from - author : David Beazley (beazley@cs.uchicago.edu)
 ************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

#ifdef C_SIXTY_FOUR
# define WORDS_PER_FLONUM              2
#else
# define WORDS_PER_FLONUM              4
#endif

/* Flags for pointer conversion */

#define SWIG_POINTER_EXCEPTION     0x1

#define C_swig_is_bool(x) C_truep (C_booleanp (x))
#define C_swig_is_char(x) C_truep (C_charp (x))
#define C_swig_is_fixnum(x) C_truep (C_fixnump (x))
#define C_swig_is_flonum(x) (C_truep (C_blockp (x)) && C_truep (C_flonump (x)))
#define C_swig_is_string(x) (C_truep (C_blockp (x)) && C_truep (C_stringp (x)))
#define C_swig_is_vector(x) (C_truep (C_blockp (x)) && C_truep (C_vectorp (x)))
#define C_swig_is_list(x) (C_truep (C_i_listp (x)))
#define C_swig_is_tagged_ptr(x) (C_truep (C_blockp (x)) && C_truep (C_taggedpointerp (x)))
#define C_swig_is_tag_struct(x) (C_truep (C_blockp (x)) && C_truep (C_structurep (x)) && (C_header_size (x) >= 3))
#define C_swig_is_ptr(x) (C_truep (C_blockp (x)) && C_truep (C_pointerp (x)))

enum {
  SWIG_BARF1_BAD_ARGUMENT_TYPE /* 1 arg */,
  SWIG_BARF1_ARGUMENT_NULL /* 1 arg */
};

typedef struct swig_chicken_clientdata {
  void*  literal_frame;
  C_word tag;
} swig_chicken_clientdata;

#ifdef SWIG_NOINCLUDE

SWIGEXPORT(char *)         swig_make_string (C_word string);
SWIGEXPORT(char *)         swig_make_string2 (char *data, int len);
SWIGEXPORT(void)           swig_barf (int code, C_char *msg, ...) C_noret;
SWIGEXPORT(void)           swig_panic (C_char *msg) C_noret;
SWIGEXPORT(int)            swig_convert_ptr(C_word , void **, 
					    swig_type_info *, int);
SWIGEXPORT(int)            swig_convert_packed(C_word , void *, int sz,
					       swig_type_info *, int);
SWIGEXPORT(char *)         swig_pack_data(char *c, void *, int);
SWIGEXPORT(char *)         swig_unpack_data(char *c, void *, int);
SWIGEXPORT(C_word)         swig_new_pointer_obj(void *, swig_type_info *,
						int own);
SWIGEXPORT(C_word)         swig_new_packed_obj(void *, int sz, 
					       swig_type_info *);

#else

/* Allocate a zero-terminated string. No error-checking. */
SWIGRUNTIME(char *)
swig_make_string2 (char *data, int len)
{
  char *ret;
  if (data == NULL) return NULL;
  ret = (char *) malloc (len + 1);
  strncpy (ret, data, len);
  ret [len] = 0;
  return ret;
}

/* Allocate a zero-terminated string. No error-checking. */
SWIGRUNTIME(char *)
swig_make_string (C_word string)
{
  return swig_make_string2 (C_c_string (string), 
			    C_header_size (string));
}

SWIGRUNTIME(void) swig_panic (C_char *) C_noret;
SWIGRUNTIME(void)
swig_panic (C_char *msg)
{
  C_word *a = C_alloc (C_SIZEOF_STRING (strlen (msg)));
  C_word scmmsg = C_string2 (&a, msg);
  C_halt (scmmsg);
  exit (5); /* should never get here */
}

SWIGRUNTIME(void) swig_barf (int, C_char *, ...) C_noret;
SWIGRUNTIME(void)
swig_barf (int code, C_char *msg, ...)
{
  char *errorhook = C_text("\003syserror-hook");
  C_word *a = C_alloc (C_SIZEOF_STRING (strlen (errorhook)));
  C_word err = C_intern2 (&a, errorhook);
  int c = -1;
  int i, barfval;
  va_list v;

  
  C_temporary_stack = C_temporary_stack_bottom;
  err = C_block_item(err, 0);

  if(C_immediatep (err))
    swig_panic (C_text ("`##sys#error-hook' is not defined"));

  switch (code) {
  case SWIG_BARF1_BAD_ARGUMENT_TYPE:
    barfval = C_BAD_ARGUMENT_TYPE_ERROR;
    c = 1;
    break;
  case SWIG_BARF1_ARGUMENT_NULL:
    barfval = C_BAD_ARGUMENT_TYPE_ERROR;
    c = 1;
    break;
  default:
    swig_panic (C_text (msg));
  };

  if(c > 0 && !C_immediatep (err)) {
    C_save (C_fix (barfval));

    i = c;
    if (i) {
      C_word *b = C_alloc (C_SIZEOF_STRING (strlen (msg)));
      C_word scmmsg = C_string2 (&b, msg);
      C_save (scmmsg);
      i--;
    }

    va_start (v, msg);

    while(i--)
      C_save (va_arg (v, C_word));

    va_end (v);
    C_do_apply (c + 1, err, 
		C_SCHEME_UNDEFINED);  /* <- no continuation is passed:
					 '##sys#error-hook' may not
					 return! */
  }
  else if (msg) {
    swig_panic (msg);
  }
  else {
    swig_panic (C_text ("unspecified panic"));
  }
}

/* Pack binary data into a string */
SWIGRUNTIME(char *)
swig_pack_data(char *c, void *ptr, int sz) {
  static char hex[17] = "0123456789abcdef";
  int i;
  unsigned char *u = (unsigned char *) ptr;
  register unsigned char uu;
  for (i = 0; i < sz; i++,u++) {
    uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}

/* Unpack binary data from a string */
SWIGRUNTIME(char *)
swig_unpack_data(char *c, void *ptr, int sz) {
  register unsigned char uu = 0;
  register int d;
  unsigned char *u = (unsigned char *) ptr;
  int i;
  for (i = 0; i < sz; i++, u++) {
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    *u = uu;
  }
  return c;
}

/* Convert a pointer value */
SWIGRUNTIME(int)
swig_convert_ptr(C_word obj, void **ptr, swig_type_info *ty, int flags) {
  swig_type_info *tc;
#ifdef SWIG_POINTER_AS_STRING
  char  *s;
  char  *c;

  if (obj == C_SCHEME_FALSE) {
    *ptr = 0;
    return 0;
  }
  c = s = 0;
  if (!(C_swig_is_string (obj))) goto type_error;
  s = c = swig_make_string (obj);
  if (!c) goto type_error;
  /* Pointer values must start with leading underscore */
  if (*c != '_') goto type_error;
  c++;
  c = swig_unpack_data (c,ptr,sizeof(void *));

  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
    *ptr = SWIG_TypeCast(tc,(void*) *ptr);
  }

  free (s);
#else
  C_word tag;
  C_word tag_ptr;

  if (obj == C_SCHEME_FALSE) {
    *ptr = 0;
    return 0;
  }
  if (!(C_swig_is_tagged_ptr (obj))) goto type_error;
  *ptr = (void*) C_pointer_address (obj);
  if (ty) {
    tag = C_block_item (obj, 1);
    if (!(C_swig_is_tag_struct (tag))) goto type_error;
    tag_ptr = C_block_item (tag, 3);
    if (!(C_swig_is_ptr (tag_ptr))) goto type_error;
    tc = (swig_type_info *) C_pointer_address (tag_ptr);
    if (!tc) goto type_error;
    *ptr = SWIG_TypeCast(tc,(void*) *ptr);
  }
#endif

  return 0;

type_error:
#ifdef SWIG_POINTER_AS_STRING
  if (s) { free (s); }
#endif
  if (flags & SWIG_POINTER_EXCEPTION) {
    if (ty) {
      char *temp = (char *) malloc(64+strlen(ty->name));
      sprintf(temp,"Type error. Expected %s", ty->name);
      swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, temp);
      free((char *) temp);
    } else {
      swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Expected a pointer");
    }
  }
  return -1;
}

/* Convert a packed value */
SWIGRUNTIME(int)
swig_convert_packed(C_word obj, void *ptr, int sz, swig_type_info *ty, int flags) {
  swig_type_info *tc;
  char  *c;
  char  *s;

  if (!C_swig_is_string (obj)) goto type_error;
  s = c = swig_make_string (obj);
  /* Pointer values must start with leading underscore */
  if (!c || *c != '_') goto type_error;
  c++;
  c = swig_unpack_data(c,ptr,sz);
  if (ty) {
    tc = SWIG_TypeCheck(c,ty);
    if (!tc) goto type_error;
  }
  free (s);
  return 0;

type_error:
  free (s);
  if (flags) {
    if (ty) {
      char *temp = (char *) malloc(64+strlen(ty->name));
      sprintf(temp,"Type error. Expected %s", ty->name);
      swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, temp);
      free((char *) temp);
    } else {
      swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, "Expected a pointer");
    }
  }
  return -1;
}

#define SWIG_STRLEN_PACKED_OBJ(obj_sz,name) (2*obj_sz+1+strlen(name))
#define SWIG_ALLOCSZ_PACKED_OBJ(obj_sz,name) (C_SIZEOF_STRING (SWIG_STRLEN_PACKED_OBJ (obj_sz,name)))
/* #define SWIG_ALLOCSZ_POINTER(name) SWIG_ALLOCSZ_PACKED_OBJ(sizeof(void*),name) */
#define SWIG_ALLOCSZ_POINTER(name) 3

/* Create a new pointer object. 'a' should be a pointer to some
   C_alloc result with SWIG_ALLOCSZ_POINTER (type->name) room */
SWIGRUNTIME(C_word)
swig_new_pointer_obj(void *ptr, C_word **a, swig_type_info *type) {
  if (ptr == NULL)
    return C_SCHEME_FALSE;
#ifdef SWIG_POINTER_AS_STRING
  {
    char result[1024];
    char *r = result;
    *(r++) = '_';
    r = swig_pack_data(r,&ptr,sizeof(void *));
    strcpy(r,type->name);
    return C_string2 (a, result);
  }
#else
  {
    /* similar to C_mpointer */
    C_word *p = *a,
      *p0 = p;

    *(p++) = C_TAGGED_POINTER_TAG;
    *((void **)(p++)) = ptr;
    C_mutate ((C_word*)(p++), 
	      ((swig_chicken_clientdata*) type->clientdata)->tag);
    *a = p;
    return (C_word)p0;
  }
#endif
}

/* 'a' should be a pointer to some C_alloc result with
   SWIG_ALLOCSZ_PACKED_OBJ (sz,type->name) room */
SWIGRUNTIME(C_word)
swig_new_packed_obj (void *ptr, C_word **a, int sz, swig_type_info *type) {
  char result[1024];
  char *r = result;
  if (SWIG_STRLEN_PACKED_OBJ (sz, type->name) > 1000) return 0;
  *(r++) = '_';
  r = swig_pack_data(r,ptr,sz);
  strcpy(r,type->name);
  return C_string2 (a, result);
}

/* Standard Chicken function */
static void C_fcall swig_tr2(C_proc2 k) C_regparm C_noret;
static void C_fcall swig_tr2(C_proc2 k) {
  C_word t1=C_pick(0);
  C_word t0=C_pick(1);
  C_adjust_stack(-2);
  (k)(2,t0,t1);
}

/* Standard Chicken function */
static void C_fcall swig_tr2r(C_proc2 k) C_regparm C_noret;
static void C_fcall swig_tr2r(C_proc2 k) {
  int n;
  C_word *a,t2;
  C_word t1=C_pick(0);
  C_word t0=C_pick(1);
  C_adjust_stack(-2);
  n=C_rest_count(0);
  a=C_alloc(n*3);
  t2=C_restore_rest(a,n);
  (k)(t0,t1,t2);
}

#endif

#ifdef __cplusplus
}
#endif
