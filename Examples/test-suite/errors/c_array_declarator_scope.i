%module xxx

int g_static[static 3];
int g_const[const 3];
int g_unspecified[*];
int g_list, g_list_unspecified[*];

struct S {
  int m_static[static 3];
  int m_volatile[volatile 2];
  int m_unspecified[*];
};

typedef int t_static[static 3];
typedef int t_unspecified[*];

/* No error for a function parameter */
void f(int n, int a[static 3], int b[const n], int c[*]);
