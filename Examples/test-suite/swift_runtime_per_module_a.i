%module swift_runtime_per_module_a

// One of two modules linked into the same Swift program (see
// swift_runtime_per_module.list): each must keep its own exception state.

%inline %{
#include <stdexcept>
int value_a() { return 1; }
void throw_a() { throw std::runtime_error("thrown by module a"); }
%}
