/* ruby.swg */
#include "ruby.h"

#define UINT2NUM(v) rb_uint2inum(v)
#define NUM2USHRT(n) NUM2UINT(n)
#define NUM2SHRT(n) (\
    (SHRT_MIN <= NUM2INT(n) && NUM2INT(n) <= SHRT_MAX)\
    ? (short)NUM2INT(n)\
    : (rb_raise(rb_eArgError, "integer %d out of range of `short'",\
               NUM2INT(n)), (short)0)\
)

#ifdef __cplusplus
# define VALUEFUNC(f) ((VALUE (*)(...))f)
# define VOIDFUNC(f) ((void (*)(...))f)
#else
# define VALUEFUNC(f) (f)
# define VOIDFUNC(f) (f)
#endif

