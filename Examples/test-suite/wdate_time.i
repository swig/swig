%module wdate_time

/* No actual source code, just to test the -Wdate-time command line option.
   As SWIG does not replace __TIME__, __DATE__ and __TIMESTAMP__ it has no
   effect for SWIG processing. */

%{
/* Provide timestamps as macros for the (realistic?) case that they are not
   provided by the C preprocessor. */

#ifndef __TIME__
#define __TIME__  "23:37:02"
#endif
#ifndef __DATE__
#define __TIME__  "Aug 28 2015"
#endif
#ifndef __TIMESTAMP__
#define __TIMESTAMP__  "Fri Aug 28 23:37:02 2015"
#endif
%}

%inline %{
const char macro_time[] = __TIME__;
const char macro_date[] = __DATE__;
const char macro_timestamp[] = __TIMESTAMP__;
%}
