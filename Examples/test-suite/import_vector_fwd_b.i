/* See import_vector_fwd_a.i for the full explanation of this regression test.

   This module %imports import_vector_fwd_a.i (which only forward-declares Bar) and
   supplies the real definition of Bar, plus %template(BarVector) std::vector<Bar>. */
%module import_vector_fwd_b

%{
#include "import_vector_fwd.h"
%}

// %include <std_vector.i> must come before %import "import_vector_fwd_a.i": once a.i
// (pulled in via %import) has %include'd std_vector.i, SWIG treats the file as already
// processed and won't re-emit its raw runtime code (e.g. the SWIG_exception macro on
// some targets) into this module's own wrapper, causing target-language compile errors.
%include <std_vector.i>

%import "import_vector_fwd_a.i"

class Bar {
public:
  Bar();
  Bar(std::string name);
  std::string name() const;
};

%template(BarVector) std::vector<Bar>;
