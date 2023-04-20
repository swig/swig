%module multi_import_d

%constant int myval = 1234;

%{
#include "multi_import.h"
%}

class WWW {
  public:
    void nullop() const;
};
