%module preproc_predefined_stdc

// Test handling of -std=c23

// __STDC__ should still have value 1.
#ifndef __STDC__
# error __STDC__ not defined at SWIG-time
#endif
#if __STDC__-0 != 1
# error __STDC__ value not 1 at SWIG-time
#endif

// __cplusplus should not be defined.
#ifdef __cplusplus
# error __cplusplus defined at SWIG-time but should not be
#endif

// __STDC_VERSION__ should be suitably defined.
#ifndef __STDC_VERSION__
# error __STDC_VERSION__ not defined at SWIG-time
#endif
#if __STDC_VERSION__ != 202311L
# error __STDC_VERSION__ value not 202311L at SWIG-time
#endif
