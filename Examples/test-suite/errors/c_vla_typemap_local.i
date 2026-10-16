%module xxx

%typemap(in) int [*] (int temp[$1_dim0]) "$1 = temp;"
%typemap(in) double [*] (size_t size = $1_dim0) "$1 = 0;"

void ints(int n, int a[n]);
void doubles(int n, double d[n]);

/* A fixed size dimension of a multidimensional variable length array can be used */
%typemap(in) double [*][*] (double row[$1_dim1]) "$1 = 0;"
%typemap(in) int [*][ANY] (int row[$1_dim1]) "$1 = 0;"

void grid(int r, int c, double m[r][c]);
void fixed_columns(int r, int m[r][4]);
