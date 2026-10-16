%module xxx

%typemap(in) int [*] (int temp[$1_dim0]) "$1 = temp;"
%typemap(in) double [*] (size_t size = $1_dim0) "$1 = 0;"

void ints(int n, int a[n]);
void doubles(int n, double d[n]);
