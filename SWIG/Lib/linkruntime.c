#if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#  if defined(_MSC_VER) || defined(__GNUC__)
#    if defined(STATIC_LINKED)
#      define SWIGEXPORT(a) a
#    else
#      define SWIGEXPORT(a) __declspec(dllexport) a
#    endif
#  else
#    if defined(__BORLANDC__)
#      define SWIGEXPORT(a) a _export
#    else
#      define SWIGEXPORT(a) a
#    endif
#  endif
#else
#  define SWIGEXPORT(a) a
#endif

static void *ptr = 0;
SWIGEXPORT(void *)
SWIG_ReturnGlobalTypeList(void *t) {
 if (!ptr && !t) ptr = t;
 return ptr;
}
