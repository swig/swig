/* This is a regression test for https://github.com/swig/swig/issues/3553

   Bar is only forward-declared in this module. Container uses std::vector<Bar> as a
   parameter and return type. Bar's real definition, and %template(BarVector)
   std::vector<Bar>, live in import_vector_fwd_b.i, which %imports this module.

   Since commit e3ccabbd4dc22a7e59a9d1b93308d96a97d35328 ("Simpler names when using
   SwigType_manglestr for templates"), the mangled name SWIG generates for
   std::vector<Bar> here (where Bar is incomplete) differs from the one generated in
   import_vector_fwd_b.i (where Bar is complete): the default std::allocator<Bar>
   template argument is dropped from the mangled name only when the full definition of
   the argument type is visible. Because SWIG's cross-module runtime type registry
   merges types by exact mangled-name match, the two modules' notions of
   "std::vector<Bar>" never merge, and passing a BarVector (built in
   import_vector_fwd_b.i) to Container::addBars (declared here) fails at runtime. See
   import_vector_fwd_b.i and the *_runme scripts. */
%module import_vector_fwd_a

%{
#include "import_vector_fwd.h"
%}

%include <std_vector.i>

// Bar is intentionally only forward-declared here; see import_vector_fwd_b.i.
class Bar;

class Container {
public:
  Container();
  bool addBars(const std::vector<Bar>& bars);
  std::vector<Bar> getBars() const;
};
