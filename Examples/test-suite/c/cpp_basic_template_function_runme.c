#include <assert.h>

#define SWIG_DEFINE_WRAPPER_ALIASES
#include "cpp_basic_template_function/cpp_basic_template_function_wrap.h"

int main() {
    assert(GetMaxInt(3, 5) == 5);
    
    return 0;
}
