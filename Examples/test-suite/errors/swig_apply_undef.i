%module xxx

%typemap(in) (char *str, int len) "$1 = 0; $2 = 0;"
%typemap(in) int *CLEARED "$1 = 0;"
%clear int *CLEARED;

%apply (char *str, int len) { (char *buf, int size) };

%apply (float *NOSUCH, int) { (float *f, int n) };
%apply int len { int n };
%apply char *str { char *s };
%apply int *CLEARED { int *c };
%apply float *NOSUCH { float *g };
%apply (float *NOSUCH, float *NOSUCH2) { (float *f, float *g) };
