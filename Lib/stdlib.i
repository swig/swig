//
// $Header$
//
// stdlib.i
// Dave Beazley
// March 24, 1996
// SWIG file for some C stdlib functions
//
/* Revision history
 * $Log$
 * Revision 1.1  2000/01/11 21:15:49  beazley
 * Added files
 *
 * Revision 1.1.1.1  1999/02/28 02:00:53  beazley
 * Swig1.1
 *
 * Revision 1.1  1996/05/22 17:27:01  beazley
 * Initial revision
 *
 */

%module stdlib
%{
#include <stdlib.h>
%}

typedef unsigned int size_t;

double atof(const char *s);
int    atoi(const char *s);
long   atol(const char *s);
int    rand();
void   srand(unsigned int seed);
void  *calloc(size_t nobj, size_t size);
void  *malloc(size_t size);
void  *realloc(void *ptr, size_t size);
void   free(void *ptr);
void   abort(void);
int    system(const char *s);
char  *getenv(const char *name);
int    abs(int n);
long   labs(long n);

