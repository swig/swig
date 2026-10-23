%module import_stl_c

%import "import_stl_a.i"

// Instantiating a container here, in a module that %imports one already using std_vector.i, needs the definitions
// the %import skipped, as the %include below is a no-op. Lua and Perl cannot yet supply theirs from an %import.
#if !defined(SWIGLUA) && !defined(SWIGPERL)

%{
#include <vector>
#include <stdexcept>
#include <algorithm>
%}

%include <std_vector.i>
%template(VectorDouble) std::vector<double>;

%inline %{
std::vector<double> halve_vector(const std::vector<int>& v) {
  std::vector<double> halved;
  for (size_t i = 0; i < v.size(); ++i)
    halved.push_back(v[i] / 2.0);
  return halved;
}
%}

#endif
