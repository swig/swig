/* File : example.i */

%module example

%{
#include "example.h"
%}

%include <boost_shared_ptr.i>
%shared_ptr(Foo);
%include "example.h"



