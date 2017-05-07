/* File : example.i */
%module example

%{
#include "example.h"
%}

/* Let's just grab the original header file here */
%include "example.h"

/* Now instantiate some specific template declarations */

TEMPLATE_WRAP0(max, maxint,  int);

TEMPLATE_WRAP0(max,maxdouble,  double);

%rename(_set) vector<int>::set(int index, int &val);

TEMPLATE_WRAP0(vector ,vecint,  int );

%rename(_set) vector<double>::set(int index, double &val);

%TEMPLATE_WRAP0(vector, vecdouble, double);