/* This was reported in Bug #1735931 */

%module multi_import_a

%import multi_import_d.i
%import "multi_import_b.i"

%{
#include "multi_import.h"
%}

class ZZZ : public XXX
{
public:
   int testz();
};

%inline %{
void use_www_a(const WWW& w) {w.nullop();}
%}
