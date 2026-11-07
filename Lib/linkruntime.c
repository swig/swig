#ifndef SWIGEXPORT
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(STATIC_LINKED)
#     define SWIGEXPORT
#   else
#     define SWIGEXPORT __declspec(dllexport)
#   endif
# else
#   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#     define SWIGEXPORT __attribute__ ((visibility("default")))
#   else
#     define SWIGEXPORT
#   endif
# endif
#endif

/* Empty type table that modules splice themselves into; compile with the 'swig -external-runtime' header included. */
static swig_module_info swig_global_type_list = { 0, 0, &swig_global_type_list, 0, 0, 0 };

SWIGEXPORT void *
SWIG_ReturnGlobalTypeList(void *t) {
  (void)t;
  return &swig_global_type_list;
}
