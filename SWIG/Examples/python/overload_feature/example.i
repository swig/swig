/* File : example.i */
%module example

%{
#include "example.h"
%}

/* This example shows how to write an overloaded shadow function
   the behaves like C++.  We simply write the disambiguation code
   ourselves below using %feature */

%rename(bar_id) bar(int,double);

%feature("shadow") bar(int) {
def bar(*args):
    if len(args) == 3:
        return apply(_example.Foo_bar_id,args)
    return apply(_example.Foo_bar,args)
}

%include "example.h"







