#include "cpp_atomic_namespaced_class/cpp_atomic_namespaced_class_proxy.h"

int main(int argc, const char *argv[])
{
    myNamespace_MyClass *mc;
    mc = new_myNamespace_MyClass();

    delete_myNamespace_MyClass(mc);

    return 0;
}
