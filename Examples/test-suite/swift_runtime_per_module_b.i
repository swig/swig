%module swift_runtime_per_module_b

// One of two modules linked into the same Swift program (see
// swift_runtime_per_module.list): each must keep its own exception state.

%inline %{
#include <stdexcept>
int value_b() { return 2; }
void throw_b() { throw std::runtime_error("thrown by module b"); }
%}
