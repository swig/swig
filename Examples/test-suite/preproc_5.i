%module preproc_5

%warnfilter(801) a;	// Ruby, wrong constant name
%warnfilter(801) b;	// Ruby, wrong constant name
%warnfilter(801) c;	// Ruby, wrong constant name
%warnfilter(801) d;	// Ruby, wrong constant name

// Various preprocessor bits of nastiness.


/* Test argument name substitution */
#define foo(x,xx) #x #xx
#define bar(x,xx) x + xx

%constant char *a = foo(hello,world);
%constant int   b = bar(3,4);

// Wrap your brain around this one ;-)

%{
#define cat(x,y) x ## y
%}

#define cat(x,y) x ## y

/* This should expand to cat(1,2);  
   See K&R, p. 231 */

%constant int c = cat(cat(1,2),;)

#define xcat(x,y) cat(x,y)

/* This expands to 123.  See K&R, p. 231 */
%constant int d = xcat(xcat(1,2),3);


