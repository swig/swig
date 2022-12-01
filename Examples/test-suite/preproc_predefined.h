/* This list will need updating when new target languages are added. */
#if (0\
  +defined(SWIGCSHARP)\
  +defined(SWIGD)\
  +defined(SWIGGO)\
  +defined(SWIGGUILE)\
  +defined(SWIGJAVA)\
  +defined(SWIGJAVASCRIPT)\
  +defined(SWIGLUA)\
  +defined(SWIGMZSCHEME)\
  +defined(SWIGOCAML)\
  +defined(SWIGOCTAVE)\
  +defined(SWIGPERL)\
  +defined(SWIGPHP)\
  +defined(SWIGPYTHON)\
  +defined(SWIGR)\
  +defined(SWIGRUBY)\
  +defined(SWIGSCILAB)\
  +defined(SWIGTCL)\
  +defined(SWIGXML)\
  ) != 1
# ifdef SWIG
#  error Did not detect exactly one target-language-specific macro defined at SWIG time.
# else
#  error Did not detect exactly one target-language-specific macro defined in the generated wrapper.
# endif
#endif
