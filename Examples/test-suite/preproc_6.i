%module preproc_6
 
%warnfilter(801) a; /* Ruby, wrong constant name */
%warnfilter(801) b; /* Ruby, wrong constant name */
%warnfilter(801) c; /* Ruby, wrong constant name */
%warnfilter(801) d; /* Ruby, wrong constant name */

#define add(a, b) (a + b)
#define times(a, b) (a * b)
#define op(x) x(1, 5)
 
/* expand to (1 + 5) */
%constant int a = op(add);
/* expand to (1 * 5) */
%constant int b = op(times);
/* expand to ((1 + 5) * 5) */
%constant int c = times(add(1, 5), 5);
/* expand to ((1 + 5) * 5) */
%constant int d = times(op(add), 5);                 
