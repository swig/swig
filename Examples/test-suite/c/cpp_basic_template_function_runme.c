#include <assert.h>
#include "cpp_basic_template_function/cpp_basic_template_function_wrap.h"

int main() {
    assert(_wrap_GetMaxInt(3, 5) == 5);
    
    return 0;
}
