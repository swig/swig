/* File : example.c */
#include <stdio.h>
#include "example.h"

shape::shape() { }

shape::~shape() { }

bool shape::cover( double x, double y ) { return false; }

void draw_shape_coverage( shape *s, int div_x, int div_y ) {
    double i,j;

    for( i = 0; i < 1.0; i += 1.0 / ((float)div_y) ) {
	for( j = 0; j < 1.0; j += 1.0 / ((float)div_x) ) {
	    if( s->cover( j,i ) ) putchar( 'x' ); else putchar( ' ' );
	}
	printf( "\n" );
    }
}
