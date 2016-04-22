#include "cpp_basic_namespaced_class/cpp_basic_namespaced_class_wrap.h"

int main(int argc, const char *argv[])
{
    myNamespace_MyClass *mc;
    mc = myNamespace_MyClass_new();

    myNamespace_MyClass_delete(mc);

    return 0;
}
