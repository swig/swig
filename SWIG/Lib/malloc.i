//
// $Header$
//
// malloc.i
// Dave Beazley
// March 24, 1996
// SWIG file for memory management functions
// (also contained in stdlib.i)
//
/* Revision History
 * $Log$
 * Revision 1.1.4.1  2002/05/04 12:42:02  beazley
 * Removed deprecated %section directive.
 *
 * Revision 1.1  2000/01/11 21:15:48  beazley
 * Added files
 *
 * Revision 1.1.1.1  1999/02/28 02:00:53  beazley
 * Swig1.1
 *
 * Revision 1.1  1996/05/22 17:27:01  beazley
 * Initial revision
 *
 */

%module malloc
%{
#include <stdlib.h>
%}

void  *calloc(unsigned nobj, unsigned size);
/* Returns a pointer to a space for an array of nobj objects, each with
   size bytes.   Returns NULL if the request can't be satisfied. 
   Initializes the space to zero bytes. */

void  *malloc(unsigned size);
/* Returns a pointer to space for an object of size bytes.  Returns NULL
   upon failure. */

void  *realloc(void *ptr, unsigned size);
/* Changes the size of the object pointed to by ptr to size bytes. 
   The contents will be unchanged up the minimum of the old and new
   sizes.  Returns a pointer to the new space of NULL upon failure,
   in which case *ptr is unchanged. */

void   free(void *ptr);
/* Deallocates the space pointed to by ptr.  Does nothing if ptr is NULL.
   ptr must be a space previously allocated by calloc, malloc, or realloc. */

