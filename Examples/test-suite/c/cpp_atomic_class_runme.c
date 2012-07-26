#include "cpp_atomic_class/cpp_atomic_class_proxy.h"

int main(int argc, const char *argv[])
{
    MyClass *mc;
    mc = new_MyClass();

    delete_MyClass(mc);

    return 0;
}
