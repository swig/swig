%module lib_cmalloc

%warnfilter(801) sizeof_int;    /* Ruby, wrong constant name */
%warnfilter(801) sizeof_double; /* Ruby, wrong constant name */
%warnfilter(801) sizeof_intp;   /* Ruby, wrong constant name */

%include "cmalloc.i"

%allocators(int);
%allocators(double);
%allocators(void);
%allocators(int *, intp);
