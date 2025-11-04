#ifdef QUICKJS_USE_LIBC_MALLOC
%include <typemaps/cmalloc.swg>
#else
// use quickjs malloc
/* 
 * Same functionality as tyepamps/cmalloc.swg,
 * except that quickjs malloc is used (allows
 * tracking of memory leaks).
 * 
 * %malloc(TYPE [, NAME = TYPE])
 * %calloc(TYPE [, NAME = TYPE])
 * %realloc(TYPE [, NAME = TYPE])
 * %free(TYPE [, NAME = TYPE])
 * %allocators(TYPE [,NAME = TYPE])
 *
 * Creates functions for allocating/reallocating memory.
 *
 * TYPE *malloc_NAME(size_t nbytes = sizeof(TYPE);
 * TYPE *calloc_NAME(size_t nobj=1, size_t size=sizeof(TYPE));
 * TYPE *realloc_NAME(TYPE *ptr, size_t nbytes);
 * void free_NAME(TYPE *ptr);
 */

%{
SWIGINTERN void *swig_js_calloc(JSContext *ctx, size_t nmemb, size_t size)
{
  return js_mallocz(ctx, nmemb*size);
}
%}

%typemap (in,numinputs=0) JSContext *ctx {$1=ctx;}

%define %malloc(TYPE,NAME...)
#if #NAME != ""
%rename(malloc_##NAME) js_malloc(JSContext *ctx, size_t nbytes);
#else
%rename(malloc_##TYPE) js_malloc(JSContext *ctx, size_t nbytes);
#endif

#if #TYPE != "void"
%typemap(default) size_t nbytes "$1 = (size_t) sizeof(TYPE);"
#endif
TYPE *js_malloc(JSContext *ctx, size_t nbytes);
%typemap(default) size_t nbytes;
%enddef

%define %calloc(TYPE,NAME...)
#if #NAME != ""
%rename(calloc_##NAME) swig_js_calloc(JSContext *ctx, size_t nmemb, size_t nbytes);
#else
%rename(calloc_##TYPE) swig_js_calloc(JSContext *ctx, size_t nmemb, size_t nbytes);
#endif

#if #TYPE != "void"
%typemap(default) size_t nbytes "$1 = (size_t) sizeof(TYPE);"
%typemap(default) size_t nmemb "$1 = 1;"
#endif
TYPE *swig_js_calloc(JSContext *ctx, size_t nmemb, size_t nbytes);
%typemap(default) size_t nbytes;
%typemap(default) size_t nmemb;
%enddef


%define %realloc(TYPE,NAME...)
#if #NAME != ""
%rename(realloc_##NAME) js_realloc(JSContext *ctx, TYPE *ptr, size_t sz);
#else
%rename(realloc_##TYPE) js_realloc(JSContext *ctx, TYPE *ptr, size_t sz);
#endif
#if #TYPE != "void"
%typemap(default) size_t sz "$1 = (size_t) sizeof(TYPE);"
#else
%typemap(default) size_t sz "$1 = 1;"
#endif
TYPE *js_realloc(JSContext *ctx, TYPE *ptr, size_t sz);
%typemap(default) size_t sz;
%enddef

%define %free(TYPE,NAME...)
#if #NAME != ""
%rename(free_##NAME) js_free(JSContext *ctx, TYPE *ptr);
#else
%rename(free_##TYPE) js_free(JSContext *ctx, TYPE *ptr);
#endif
void js_free(JSContext *ctx, TYPE *ptr);
%enddef

%define %sizeof(TYPE,NAME...)
#if #NAME != ""
%constant size_t sizeof_##NAME = sizeof(TYPE);
#else
%constant size_t sizeof_##TYPE = sizeof(TYPE);
#endif
%enddef

%define %allocators(TYPE,NAME...)
%malloc(TYPE,NAME)
%calloc(TYPE,NAME)
%realloc(TYPE,NAME)
%free(TYPE,NAME)
#if #TYPE != "void"
%sizeof(TYPE,NAME)
#endif
%enddef
#endif

