%module xxx

// Pointer arithmetic is not deduced, as SWIG would otherwise deduce the type pointed to.
int g = 1;
int *pg = &g;
int *&rpg = pg;
int arr[3];
const char *gs = "abc";
auto p1 = pg + 1;
auto p2 = 1 + rpg;
auto p3 = arr + 1;
auto p4 = (pg + 1);
auto p5 = (int *)0 + 1;
auto p6 = pg - pg;
auto p7 = gs + 1;

// Deduced: not pointer arithmetic.
auto ok1 = pg != 0;
auto ok2 = pg ? 1 : 2;
auto ok3 = (const int *)pg;
auto ok4 = *(int *)pg;
auto ok5 = &(int &)g;
