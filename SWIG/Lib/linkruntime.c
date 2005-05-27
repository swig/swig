# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(STATIC_LINKED)
#     define SWIGEXPORT
#   else
#     define SWIGEXPORT __declspec(dllexport)
#   endif
# else

static void *ptr = 0;
SWIGEXPORT void *
SWIG_ReturnGlobalTypeList(void *t) {
 if (!ptr && !t) ptr = t;
 return ptr;
}
