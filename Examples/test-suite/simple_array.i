%module simple_array

%{
#if defined __STDC_VERSION__ && __STDC_VERSION__ >= 199901L
# include <stdbool.h>
#elif !defined __cplusplus
/* C89 has no stdbool.h, but the header files of a target language may have included it or defined just bool */
# ifndef bool
#  define bool unsigned char
# endif
# ifndef true
#  define true 1
#  define false 0
# endif
#endif
%}

extern int x[10];
extern double y[7];


%inline %{

struct BarArray {
  int i;
  double d;
};

extern struct BarArray bars[2]; 

int x[10];
double y[7];
struct BarArray bars[2]; 
int xy[2][3];

/* The only bool that SWIG sees here, for which the .h file of the C target language has to include stdbool.h */
bool bool_flag = true;

void
initArray()
{
  int i, n;

  n = sizeof(x)/sizeof(x[0]);
  for(i = 0; i < n; i++) 
    x[i] = i;

  n = sizeof(y)/sizeof(y[0]);
  for(i = 0; i < n; i++) 
    y[i] = ((double) i)/ ((double) n);

  n = sizeof(bars)/sizeof(bars[0]);
  for(i = 0; i < n; i++) {
    bars[i].i = x[i+2];
    bars[i].d = y[i+2];
  }

  return;
}

%}
