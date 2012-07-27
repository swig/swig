#include "cpp_basic_class/cpp_basic_class_proxy.h"

int main(int argc, const char *argv[])
{
    MyClass *mc;
    mc = new_MyClass();

    delete_MyClass(mc);

    return 0;
}
