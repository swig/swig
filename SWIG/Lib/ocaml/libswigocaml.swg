#include <stdio.h>
#include <stdlib.h>
#include "libswigocaml.h"
/* Ocaml runtime support ... not much here yet */

void *nullptr = 0;
oc_bool isnull( void *v ) { return v ? 0 : 1; }
void *get_char_ptr( char *str ) { return str; }
void *make_ptr_array( int size ) {
    return (void *)malloc( sizeof( void * ) * size );
}
void *get_ptr( void *arrayptr, int elt ) {
    return ((void **)arrayptr)[elt];
}
void set_ptr( void *arrayptr, int elt, void *elt_v ) {
  ((void **)arrayptr)[elt] = elt_v;
}
void *offset_ptr( void *p, int n ) { return ((char *)p) + n; }
