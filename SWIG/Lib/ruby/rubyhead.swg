/* ruby.swg */
/* Implementation : RUBY */
#define SWIGRUBY 1

#include "ruby.h"

#define NUM2USHRT(n) NUM2UINT(n)
#define NUM2SHRT(n) (\
    (SHRT_MIN <= NUM2INT(n) && NUM2INT(n) <= SHRT_MAX)\
    ? (short)NUM2INT(n)\
    : (rb_raise(rb_eArgError, "integer %d out of range of `short'",\
               NUM2INT(n)), (short)0)\
)

#ifdef __cplusplus
#  if defined(_WIN32) && defined(_MSC_VER)
#    define VALUEFUNC(f) ((VALUE (*)())f)
#    define VOIDFUNC(f) ((void (*)(void *))f)
#  else
#    define VALUEFUNC(f) ((VALUE (*)(...))f)
#    define VOIDFUNC(f) ((void (*)(...))f)
#  endif
#else
# define VALUEFUNC(f) (f)
# define VOIDFUNC(f) (f)
#endif

typedef struct {
  VALUE  klass;
  void  (*destroy)(void *);
} swig_class;

  
  
