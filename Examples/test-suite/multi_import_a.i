/* This was reported in Bug #1735931 */

%module multi_import_a

#ifndef SWIGGO
%import multi_import_d.i
#endif
%import "multi_import_b.i"

%{
#include "multi_import.h"
%}

class ZZZ : public XXX
{
public:
   int testz();
};
