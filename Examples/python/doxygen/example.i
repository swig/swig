%module example

%{
#include "example.h"
%}

%immutable NumSquares;
%immutable NumCircles;

%include "example.h"

/*! - this instantiation uses type int */
%template(RectangleInt) Rectangle<int>;

/*! - this instantiation uses type int */
%template(MakeRectangleInt) MakeRectangle<int>;

