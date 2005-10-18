%insert(runtime) %{
#include <ruby.h>

/* Ruby 1.7 defines NUM2LL(), LL2NUM() and ULL2NUM() macros */
#ifndef NUM2LL
#define NUM2LL(x) NUM2LONG((x))
#endif
#ifndef LL2NUM
#define LL2NUM(x) INT2NUM((long) (x))
#endif
#ifndef ULL2NUM
#define ULL2NUM(x) UINT2NUM((unsigned long) (x))
#endif

/* Ruby 1.7 doesn't (yet) define NUM2ULL() */
#ifndef NUM2ULL
#ifdef HAVE_LONG_LONG
#define NUM2ULL(x) rb_num2ull((x))
#else
#define NUM2ULL(x) NUM2ULONG(x)
#endif
#endif

/*
 * Need to be very careful about how these macros are defined, especially
 * when compiling C++ code or C code with an ANSI C compiler.
 *
 * VALUEFUNC(f) is a macro used to typecast a C function that implements
 * a Ruby method so that it can be passed as an argument to API functions
 * like rb_define_method() and rb_define_singleton_method().
 *
 * VOIDFUNC(f) is a macro used to typecast a C function that implements
 * either the "mark" or "free" stuff for a Ruby Data object, so that it
 * can be passed as an argument to API functions like Data_Wrap_Struct()
 * and Data_Make_Struct().
 */
 
#ifdef __cplusplus
#  ifndef RUBY_METHOD_FUNC /* These definitions should work for Ruby 1.4.6 */
#    define PROTECTFUNC(f) ((VALUE (*)()) f)
#    define VALUEFUNC(f) ((VALUE (*)()) f)
#    define VOIDFUNC(f)  ((void (*)()) f)
#  else
#    ifndef ANYARGS /* These definitions should work for Ruby 1.6 */
#      define PROTECTFUNC(f) ((VALUE (*)()) f)
#      define VALUEFUNC(f) ((VALUE (*)()) f)
#      define VOIDFUNC(f)  ((RUBY_DATA_FUNC) f)
#    else /* These definitions should work for Ruby 1.7+ */
#      define PROTECTFUNC(f) ((VALUE (*)(VALUE)) f)
#      define VALUEFUNC(f) ((VALUE (*)(ANYARGS)) f)
#      define VOIDFUNC(f)  ((RUBY_DATA_FUNC) f)
#    endif
#  endif
#else
#  define VALUEFUNC(f) (f)
#  define VOIDFUNC(f) (f)
#endif

/* Don't use for expressions have side effect */
#ifndef RB_STRING_VALUE
#define RB_STRING_VALUE(s) (TYPE(s) == T_STRING ? (s) : (*(volatile VALUE *)&(s) = rb_str_to_str(s)))
#endif
#ifndef StringValue
#define StringValue(s) RB_STRING_VALUE(s)
#endif
#ifndef StringValuePtr
#define StringValuePtr(s) RSTRING(RB_STRING_VALUE(s))->ptr
#endif
#ifndef StringValueLen
#define StringValueLen(s) RSTRING(RB_STRING_VALUE(s))->len
#endif
#ifndef SafeStringValue
#define SafeStringValue(v) do {\
    StringValue(v);\
    rb_check_safe_str(v);\
} while (0)
#endif

#ifndef HAVE_RB_DEFINE_ALLOC_FUNC
#define rb_define_alloc_func(klass, func) rb_define_singleton_method((klass), "new", VALUEFUNC((func)), -1)
#define rb_undef_alloc_func(klass) rb_undef_method(CLASS_OF((klass)), "new")
#endif

%}

%runtime "swigrun.swg"       /* Common C API type-checking code */
%runtime "rubytracking.swg"  /* API for tracking C++ classes to Ruby objects */
%runtime "rubyrun.swg"
%runtime "rubyapi.swg"
