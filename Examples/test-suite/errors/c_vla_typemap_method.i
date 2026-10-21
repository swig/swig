%module xxx

%feature("autodoc", "2");

%typemap(typecheck) char [*] "$1 = ($1_dim0) > 0;"
%typemap(in, numinputs=0) int [*] "$1 = 0; /* $1_dim0 */"
%typemap(default) short [*] "$1 = 0; /* $1_dim0 */"
%typemap(arginit) long [*] "$1 = 0; /* $1_size */"
%typemap(doc) double [*] "$1_name: $1_dim0 doubles"
%typemap(in, doc="$1_dim0 floats") float [*] "$1 = 0;"

/* No error for typemaps that run after the size is converted or that do not use it */
%typemap(in) unsigned [*] "$1 = 0; /* $1_dim0 */"
%typemap(check) unsigned [*] "/* $1_dim0 */"
%typemap(argout) unsigned [*] "/* $1_dim0 */"
%typemap(freearg) unsigned [*] "/* $1_dim0 */"
%typemap(typecheck) unsigned [*] "$1 = 1;"

void chars(int n, char s[n]);
void ints(int n, int a[n]);
void shorts(int n, short h[n]);
void longs(int n, long l[n]);
void doubles(int n, double d[n]);
void floats(int n, float f[n]);
void unsigneds(int n, unsigned u[n]);
