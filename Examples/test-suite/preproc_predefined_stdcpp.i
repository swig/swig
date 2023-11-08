%module preproc_predefined_stdcpp

// Test handling of -std=c++23

// __STDC__ should still have value 1.
#ifndef __STDC__
# error __STDC__ not defined at SWIG-time
#endif
#if __STDC__-0 != 1
# error __STDC__ value not 1 at SWIG-time
#endif

// __STDC_VERSION__ should not be defined.
#ifdef __STDC_VERSION__
# error __STDC_VERSION__ defined at SWIG-time but should not be
#endif

// __cplusplus should be suitably defined.
#ifndef __cplusplus
# error __cplusplus not defined at SWIG-time
#endif
#if __cplusplus != 202302L
# error __cplusplus value not 202302L at SWIG-time
#endif
